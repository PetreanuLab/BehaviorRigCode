// WriteAnalogData.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"


//Matlab signature
//sampsPerChanWritten = WriteAnalogData(task, writeData, timeout, numSampsPerChan)
//	task: A DAQmx.Task object handle
//  writeData:  Data to write to the Channel(s) of this Task. Samples are arranged in rows and Channels in columns. Data should be of type uint8, uint16, or uint32, and sufficiently long to encompass number of lines for channel. 
//				Data can be either 'scaled' (of type double and specified in the units of each Channel) or 'native' (of integer type, of the appropriate class for the Task device(s)' Channels)
//  timeout: (OPTIONAL) Time, in seconds, to wait for function to complete read. Default value is 'inf'. If 'inf' or < 0, then function will wait indefinitely. A value of 0 indicates to try once to write the submitted samples. If this function successfully writes all submitted samples, it does not return an error. Otherwise, the function returns a timeout error and returns the number of samples actually written.
//	autoStart: (OPTIONAL) Logical value specifies whether or not this function automatically starts the task if you do not start it. If omitted/empty, 'false' is assumed.
//	numSampsPerChan: (OPTIONAL) Specifies number of samples per channel to write. If omitted/empty, the number of rows in the writeData array will be written. 
//
//	sampsPerChanWritten: The actual number of samples per channel successfully written to the buffer.


//Gateway routine
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	//General vars
	char errMsg[512];

	//Read input arguments
	float64 timeout;
	int numSampsPerChan;
	bool32 autoStart;

	TaskHandle taskID = (TaskHandle)mxGetScalar(mxGetProperty(prhs[0],0, "taskID"));

	if ((nrhs < 3) || mxIsEmpty(prhs[2]))
		timeout = 10.0;
	else
	{
		timeout = (float64) mxGetScalar(prhs[2]);
		if (mxIsInf(timeout))
			timeout = DAQmx_Val_WaitInfinitely;
	}

	if ((nrhs < 4) || mxIsEmpty(prhs[3]))
		autoStart = false;
	else
		autoStart = (bool32) mxGetScalar(prhs[3]);

	size_t numRows = mxGetM(prhs[1]);
	if ((nrhs < 5) || mxIsEmpty(prhs[4]))
		numSampsPerChan = numRows;
	else
		numSampsPerChan = (int) mxGetScalar(prhs[4]);

	//Verify correct input length

	//Write data
	int32 sampsWritten;
	bool32 dataLayout = DAQmx_Val_GroupByChannel; //This forces DAQ toolbox like ordering
	int32 status;


	switch (mxGetClassID(prhs[1]))
	{	
		case mxUINT16_CLASS:
			status = DAQmxWriteBinaryU16(taskID, numSampsPerChan, autoStart, timeout, dataLayout, (uInt16*) mxGetData(prhs[1]), &sampsWritten, NULL);
		break;

		case mxINT16_CLASS:
			status = DAQmxWriteBinaryI16(taskID, numSampsPerChan, autoStart, timeout, dataLayout, (int16*) mxGetData(prhs[1]), &sampsWritten, NULL);
		break;

		case mxDOUBLE_CLASS:
			status = DAQmxWriteAnalogF64(taskID, numSampsPerChan, autoStart, timeout, dataLayout, (float64*) mxGetData(prhs[1]), &sampsWritten, NULL);
		break;

		default:
			sprintf(errMsg,"Class of supplied writeData argument (%s) is not valid", mxGetClassName(prhs[1]));
			mexErrMsgTxt(errMsg);
	}

	//Handle output arguments
	plhs[0] = mxCreateDoubleScalar(0);	
	double *sampsPerChanWritten = mxGetPr(plhs[0]);
	int32 driverErrorStringSize;
	char *driverErrorString;

	if (!status)
	{
		//mexPrintf("Successfully wrote %d samples of data\n", sampsWritten);		
		*sampsPerChanWritten = (double)sampsWritten;
	}
	else //Write failed
	{
		//Display DAQmx error string
		driverErrorStringSize = DAQmxGetErrorString(status,NULL,0); //Gets size of buffer
		driverErrorString = (char *)mxCalloc(driverErrorStringSize,sizeof(char));
		DAQmxGetErrorString(status,driverErrorString,driverErrorStringSize);
		sprintf(errMsg, "DAQmx Error (%d) encountered in %s: %s\n", status, mexFunctionName(), driverErrorString);
		mexErrMsgTxt(errMsg); //This automatically frees allocated memory
	}

}




