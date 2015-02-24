// RegisterDoneCallback.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"


//Matlab signature
//status = RegisterDoneCallback(taskObj,registerTF)
// registerTF: (OPTIONAL) Logical value indicating if 'true', to register the Done Event and, if 'false', to unregister the Done Event. If empty/omitted, value 'true' is assumed.


//DEFINES
#define MAXNUMTASKS 100
#define MAXNUMCALLBACKS 10
#define MAXCALLBACKNAMELENGTH 256
#define MAXFIELDNAMELENGTH 64


typedef struct{
	//char callbackFuncNames[MAXNUMCALLBACKS][MAXCALLBACKNAMELENGTH];
	TaskHandle taskHandle; //serves as key value for search/sort
	mxArray *callbackFuncHandles[MAXNUMCALLBACKS];
	mxArray *taskObjHandle;
	int readDataIndex;
	int numCallbacks;
} CallbackData;

//Variable declarations -- these variables will persist beyond the MEX call
//static CallbackData *callbackData[MAXNUMREGISTRATIONS]; //An array of pointer
static int numRegisteredTasks; //count of number of uniquely labelled Tasks that have been added
static CallbackData *callbackDataRecords[MAXNUMTASKS];
static mxArray *eventArray; //Placeholder for empty array to pass as event argument to callback


//MEX Exit function
static void cleanUp(void)
{
	for (int i=0; i<numRegisteredTasks; i++)
		mxFree((void*)callbackDataRecords[i]);
}

//The Callback
static int32 CVICALLBACK callbackWrapper(TaskHandle taskHandle, int32 status, void *callbackData)
{
	mxArray *mException;
	mxArray *rhs[3];
	CallbackData *cbData = (CallbackData*)callbackData;

	//Initialize src/event arguments that will be passed to /all/ callbacks
	rhs[1] = cbData->taskObjHandle;
	rhs[2] = eventArray;
	
	for (int i=0; i<cbData->numCallbacks; i++)
	{
		//mException = mexCallMATLABWithTrap(0,NULL,0,0,cbData->callbackFuncNames[i]); //TODO -- pass arguments!
		rhs[0] = cbData->callbackFuncHandles[i];
		mException = mexCallMATLABWithTrap(0,NULL,3,rhs,"feval"); //TODO -- pass arguments!
		if (!mException)
			continue;
		else
		{
			char *errorString = (char*)mxCalloc(256,sizeof(char));
			mxGetString(mxGetProperty(mException, 0, "message"),errorString, MAXCALLBACKNAMELENGTH);
			mexPrintf("ERROR in Done Event callback of Task object: %s\n", errorString);
			mxFree(errorString);
			return 1;
		}
	}

	return 0;
}


//Gateway routine
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	//Shared vars
	int32 (*funcPtr)(TaskHandle, int32, void*) = callbackWrapper;
	int32 status;
	bool32 registerTF;
	bool32 newTask=false;

	//Initialize empty Array, if not done so already
	if (eventArray==NULL)
	{
		mexLock();
		mexAtExit(cleanUp);

		eventArray = mxCreateStructMatrix(0, 0, 0, 0);
		mexMakeArrayPersistent(eventArray);
	}

	//Parse input arguments
	const mxArray *task = prhs[0];
	TaskHandle taskID = (TaskHandle)mxGetScalar(mxGetProperty(task,0,"taskID"));
	mxArray *callbackFuncs = mxGetProperty(task,0,"doneEventCallbacks");
	if ((nrhs < 2) || mxIsEmpty(prhs[1]))
		registerTF = true;
	else
		registerTF = (bool32) mxGetScalar(prhs[1]);
		
	if (registerTF)
	{
		bool found = false;
		CallbackData *currCBData;

		//Determine if Task has already been added
		for (int i=0;i<numRegisteredTasks;i++)
		{
			if (callbackDataRecords[i]->taskHandle == taskID)
			{
				found=true;
				currCBData = callbackDataRecords[i];
				break;
			}			
		}

		//CallbackData *currCBData = (CallbackData *)bsearch(&queryRecordPtr, callbackDataRecords, numRegisteredTasks, sizeof(CallbackData*), callbackDataCompareFnc);

		//Add new callbackData record if none has been added for this Task
		if (!found)
		{
			currCBData = (CallbackData*)mxCalloc(1,sizeof(CallbackData));	
			mexMakeMemoryPersistent((void*)currCBData); //Need to store the callbackData beyond the MEX call. (Would malloc() accomplish this? might it allow the data to then get deleted with Task? or might this happen anyway?)
			newTask=true;

			currCBData->taskHandle = taskID; 
		}

		//Pack callbackData structure
		int numCallbacks = mxGetNumberOfElements(callbackFuncs); //A vectorial cell array is assumed
		if (numCallbacks > MAXNUMCALLBACKS)
			mexErrMsgTxt("Exceeded the maximum allowed number of callback functions.");

		//mxArray *callbackNameCell, *callbackDataCell;
		//mwSize dims[2] = {1,0};
		for (int i=0;i<numCallbacks;i++)
		{
			//Pack callbackFuncs
			currCBData->callbackFuncHandles[i] = mxDuplicateArray(mxGetCell(callbackFuncs,i)); //Vectorial cell array is assumed		
			mexMakeArrayPersistent(currCBData->callbackFuncHandles[i]);
		}

		//Store Task object handle
		currCBData->taskObjHandle = mxDuplicateArray(task);
		mexMakeArrayPersistent(currCBData->taskObjHandle);

	    //Store other callback data for this Task
		currCBData->numCallbacks = numCallbacks;

		//Register callback function	
		status = DAQmxRegisterDoneEvent(taskID, DAQmx_Val_SynchronousEventCallbacks, funcPtr, currCBData);

		//Updgrade count and callbackData record if successful; free allocated memory if not
		if (!status) 
		{
			if (newTask)
			{
				callbackDataRecords[numRegisteredTasks] = currCBData;
				numRegisteredTasks++;
				//qsort(callbackDataRecords, numRegisteredTasks, sizeof(CallbackData*), callbackDataCompareFnc);
			}
		}
		else
			mxFree(currCBData);
	}
	else //Handle Event 'unregistration'
		status = DAQmxRegisterDoneEvent(taskID, DAQmx_Val_SynchronousEventCallbacks, 0, 0);


	//Return output arguments
	plhs[0] = mxCreateDoubleScalar(0);
	*mxGetPr(plhs[0]) = (double)status; 
}
