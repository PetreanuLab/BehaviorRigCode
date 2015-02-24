// ReadAnalogData.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"

#define MAXVARNAMESIZE 64

//Matlab signature
//[sampsRead, outputData] = ReadAnalogData(task, numSampsPerChan, outBufVarOrSampsPerChan, outputFormat, timeout)
//task: A DAQmx.Task object handle
//numSampsPerChan: (OPTIONAL) Specifies number of samples per channel to read. If omitted/empty, value of 'inf' is used. If 'inf' or < 0, then all available samples are read, up to the size of the output array.
//outputFormat: (OPTIONAL) One of {'native','scaled'}. If omitted/empty, 'scaled' is assumed. Indicate native unscaled format and double scaled format, respectively. 
//timeout: (OPTIONAL) Time, in seconds, to wait for function to complete read. If omitted/empty, value of 'inf' is used. If 'inf' or < 0, then function will wait indefinitely. 
//outputVarOrSize: (OPTIONAL) Either name of preallocated MATLAB variable into which to store read data, or the size in samples of the output variable to create (to be returned as outputData argument).
//
//sampsRead: Number of samples actually read
//outputData: Array of output data with samples arranged in rows and channels in columns. This value is not output if outputVarOrSize is a string specifying a preallocated output variable.


//Helper functions
void handleDAQmxError(int32 status, const char *functionName)
{
	int32 errorStringSize;
	char *errorString;

	//Display DAQmx error string
	//TODO: Compare with using mexErrMsgTxt() instead
	errorStringSize = DAQmxGetErrorString(status,NULL,0); //Gets size of buffer
	errorString = (char *)mxCalloc(errorStringSize,sizeof(char));
	DAQmxGetErrorString(status,errorString,errorStringSize);
	mexPrintf("DAQmx Error (%d) encountered in %s: %s\n", status, functionName, errorString);
	mxFree(errorString);
}

//Gateway routine
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	//Read input arguments
	char outputFormat[10];
	char outputVarName[MAXVARNAMESIZE];
	int	outputVarSampsPerChan;
	double timeout;
	int numSampsPerChan;
	bool outputData; //Indicates whether to return an outputData argument

	TaskHandle taskID = (TaskHandle)mxGetScalar(mxGetProperty(prhs[0],0, "taskID"));
	mxClassID rawDataClass = mxGetClassID(mxGetProperty(prhs[0],0,"rawDataArrayAI")); //Stored in MCOS Task object as an empty array of the desired class!

	//Handle input arguments
	if ((nrhs < 2) || mxIsEmpty(prhs[1]) || mxIsInf(mxGetScalar(prhs[1])))
		numSampsPerChan = DAQmx_Val_Auto;
	else
		numSampsPerChan = (int) mxGetScalar(prhs[1]);
	
	if ((nrhs < 3) || mxIsEmpty(prhs[2]))
		strcpy_s(outputFormat,"scaled");
	else
		mxGetString(prhs[2], outputFormat, 10);

	if ((nrhs < 4) || mxIsEmpty(prhs[3]) || mxIsInf(mxGetScalar(prhs[3])))
		timeout = DAQmx_Val_WaitInfinitely;
	else
		timeout = mxGetScalar(prhs[3]);


	if ((nrhs < 5) || mxIsEmpty(prhs[4]))
	{
		outputData = true;
		outputVarSampsPerChan = numSampsPerChan; //If value is DAQmx_Val_Auto, then the # of samples available will be queried before allocting array
	}
	else
	{
		outputData = mxIsNumeric(prhs[4]);
		if (outputData)
		{
			if (nlhs < 2)
				mexErrMsgTxt("There must be two output arguments specified if a preallocated MATLAB variable is not specified");
			outputVarSampsPerChan = (int) mxGetScalar(prhs[4]);
		}
		else
			mxGetString(prhs[4], outputVarName, MAXVARNAMESIZE);
	}


	//Determine output data type
	mxClassID outputDataClass;
	char errorMessage[30];
	if (!_strcmpi(outputFormat,"scaled"))
		outputDataClass = mxDOUBLE_CLASS;
	else if (!_strcmpi(outputFormat,"native"))
		outputDataClass = rawDataClass;
	else
	{
		sprintf_s(errorMessage,"Unrecognized output format: %s\n",outputFormat);
		mexErrMsgTxt(errorMessage);
	}
		

	//Determin # of output channels
	uInt32 numChannels; 
	DAQmxGetReadNumChans(taskID, &numChannels); //Reflects number of channels in Task, or the number of channels specified by 'ReadChannelsToRead' property
	
	//Determine output buffer/size (creating if needed)
	mxArray *outputDataBuf;
	void *outputDataPtr;
	int32 status;

	//float64 *outputDataPtr;
	if (outputData)
	{
		if (outputVarSampsPerChan == DAQmx_Val_Auto)
		{
			status = DAQmxGetReadAvailSampPerChan(taskID, (uInt32 *)&outputVarSampsPerChan);
			if (status)
			{
				handleDAQmxError(status, mexFunctionName());
				return;
			}
		}

		outputDataBuf = mxCreateNumericMatrix(outputVarSampsPerChan,numChannels,outputDataClass,mxREAL);
	}
	else
	{
		outputDataBuf = mexGetVariable("caller", outputVarName);
		outputVarSampsPerChan = mxGetM(outputDataBuf);
		//TODO: Add check to ensure WS variable is of correct class
	}

	outputDataPtr = mxGetData(outputDataBuf);

	//Read data
	int32 numSampsRead;
	bool32 fillMode = DAQmx_Val_GroupByChannel; //Arrange data by channel, so that columns correspond to channels given MATLAB's column-major data format

	if (outputDataClass == mxDOUBLE_CLASS) //'scaled' 
		status = DAQmxReadAnalogF64(taskID, numSampsPerChan, timeout, fillMode, (float64*) outputDataPtr, outputVarSampsPerChan * numChannels, &numSampsRead, NULL);
	else //'raw'
	{
		switch (outputDataClass)
		{
			case mxINT16_CLASS:
				status = DAQmxReadBinaryI16(taskID, numSampsPerChan, timeout, fillMode, (int16*) outputDataPtr, outputVarSampsPerChan * numChannels, &numSampsRead, NULL);
				break;
			case mxINT32_CLASS:
				status = DAQmxReadBinaryI32(taskID, numSampsPerChan, timeout, fillMode, (int32*) outputDataPtr, outputVarSampsPerChan * numChannels, &numSampsRead, NULL);
				break;
			case mxUINT16_CLASS:
				status = DAQmxReadBinaryU16(taskID, numSampsPerChan, timeout, fillMode, (uInt16*) outputDataPtr, outputVarSampsPerChan * numChannels, &numSampsRead, NULL);
				break;
			case mxUINT32_CLASS:
				status = DAQmxReadBinaryU32(taskID, numSampsPerChan, timeout, fillMode, (uInt32*) outputDataPtr, outputVarSampsPerChan * numChannels, &numSampsRead, NULL);
				break;
		}
	}

	//Return output data
	double *sampsReadOutput;
	plhs[0] = mxCreateDoubleScalar(0);	
	sampsReadOutput = mxGetPr(plhs[0]);

	if (!status)
	{
		//mexPrintf("Successfully read %d samples of data\n", numSampsRead);		
		*sampsReadOutput = (double)numSampsRead;

		if (outputData)
		{
			if (nlhs >= 1)
				plhs[1] = outputDataBuf;
			else
				mxDestroyArray(outputDataBuf); //If you don't read out, all the reading was done for naught
		}
		else
			mexPutVariable("caller", outputVarName, outputDataBuf);

	}
	else //Read failed
		handleDAQmxError(status, mexFunctionName());

}

