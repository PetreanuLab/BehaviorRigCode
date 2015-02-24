// WriteDigitalDataData.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"

//Matlab signature
//%% function sampsPerChanWritten = writeDigitalData(task, writeData, timeout, autoStart, numSampsPerChan)
//%   writeData: Data to write to the Channel(s) of this Task. Supplied as matrix, whose columns represent Channels.
//%              Data should be of one of types: uint8,uint16,uint32,logical, or double.
//%              Data of logical/double type should be supplied as a separate value per line (bit), so that number or rows should equal (# samples) x (# lines/Channel). 
//%                  If multiple Channels are present, (# lines/Channel) value corresponds to Channel with largest # lines.
//%              Data of type uint8/16/32 is supplied to write only one value per sample (per Channel), with the value specifying each of the lines (bits) in a Channel.
//%                  If Channel in Task are 'port-based', the data type used should contain as many bits as the largest port in the Task.
//%                  If Channel in Task are 'line-based', the data type used should contain as many bits as the line in Task belonging to the largest port.
//%                  If Task contains multiple Channels, then the largest data type required by any Channel must be used for all Channels.
//%                  Note that data for 'line-based' Channels must be arranged in uint8/16/32 value according to the bit/line number 
//%                    (e.g. bit 7 for line 7, even if line 7 is only line in Channel), and NOT by the order/number of lines in the Channel. 
//%                    Bits in the supplied value corresponding to lines not included in Channel are simply ignored.                                      
//%
//%   timeout: (OPTIONAL - Default: 'inf') Time, in seconds, to wait for function to complete read. If 'inf' or < 0, then function will wait indefinitely. A value of 0 indicates to try once to write the submitted samples. If this function successfully writes all submitted samples, it does not return an error. Otherwise, the function returns a timeout error and returns the number of samples actually written.
//%   autoStart: (OPTIONAL) Logical value specifies whether or not this function automatically starts the task if you do not start it. 
//%              If empty/omitted, true is assumed when writeData is logical/double and false is assumed when writeData is uint8/16/32.
//%   numSampsPerChan: (OPTIONAL) Specifies number of samples per channel to write. If omitted/empty, the number of samples is inferred from number of rows in writeData array. 
//%
//%   sampsPerChanWritten: The actual number of samples per channel successfully written to the buffer.
//%



//Static variables
bool32 dataLayout = DAQmx_Val_GroupByChannel; //This forces DAQ toolbox like ordering, i.e. each Channel corresponds to a column


//Gateway routine
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	//General vars
	char errMsg[512];

	//Read input arguments
	float64 timeout;
	bool writeDigitalLines;
	uInt32 bytesPerChan;
	int numSampsPerChan;
	bool32 autoStart;

	TaskHandle taskID = (TaskHandle)mxGetScalar(mxGetProperty(prhs[0],0, "taskID"));
	mxClassID writeDataClassID = mxGetClassID(prhs[1]);

	//int numLinesPerChan = (int) mxGetPr(mxGetProperty(prhs[0],0,"numLinesCached")); //Gets number of lines associated with channel


	if ((writeDataClassID == mxLOGICAL_CLASS) || (writeDataClassID == mxDOUBLE_CLASS))
		writeDigitalLines = true;
	else
		writeDigitalLines = false;


	if (writeDigitalLines)
		DAQmxGetWriteDigitalLinesBytesPerChan(taskID,&bytesPerChan); //This actually returns the number of bytes required to represent one sample of Channel data
	
	if ((nrhs < 3) || mxIsEmpty(prhs[2]))
		timeout = DAQmx_Val_WaitInfinitely;
	else
	{
		timeout = (float64) mxGetScalar(prhs[2]);
		if (mxIsInf(timeout) || (timeout < 0))
			timeout = DAQmx_Val_WaitInfinitely;
	}		

	if ((nrhs < 4) || mxIsEmpty(prhs[3]))
	{
		if (writeDigitalLines)
			autoStart = true;
		else
			autoStart = false;
	}
	else
		autoStart = (bool32) mxGetScalar(prhs[3]);


	mwSize numRows = mxGetM(prhs[1]);
	if ((nrhs < 5) || mxIsEmpty(prhs[4]))
		if (writeDigitalLines)
		{
			numSampsPerChan = numRows / bytesPerChan;
		}
		else 
			numSampsPerChan = numRows;
	else
		numSampsPerChan = (int) mxGetScalar(prhs[4]);


	//Verify correct input length

	//Write data
	int32 sampsWritten;
	int32 status;


	switch (writeDataClassID)
	{	
		case mxUINT32_CLASS:
			status = DAQmxWriteDigitalU32(taskID, numSampsPerChan, autoStart, timeout, dataLayout, (uInt32*) mxGetData(prhs[1]), &sampsWritten, NULL);
		break;

		case mxUINT16_CLASS:
			status = DAQmxWriteDigitalU16(taskID, numSampsPerChan, autoStart, timeout, dataLayout, (uInt16*) mxGetData(prhs[1]), &sampsWritten, NULL);
		break;

		case mxUINT8_CLASS:
			status = DAQmxWriteDigitalU8(taskID, numSampsPerChan, autoStart, timeout, dataLayout, (uInt8*) mxGetData(prhs[1]), &sampsWritten, NULL);
		break;

		case mxDOUBLE_CLASS:
		case mxLOGICAL_CLASS:
			{
				if (numRows < (numSampsPerChan * bytesPerChan))
					mexErrMsgTxt("Supplied writeData argument must have at least (numSampsPerChan x numBytesPerChannel) rows.");
				else if (writeDataClassID == mxLOGICAL_CLASS)
					status = DAQmxWriteDigitalLines(taskID, numSampsPerChan, autoStart, timeout, dataLayout, (uInt8*) mxGetData(prhs[1]), &sampsWritten, NULL);
				else //mxDOUBLE_CLASS
				{
					//Convert DOUBLE data to LOGICAL values
					double *writeDataRaw = mxGetPr(prhs[1]);
					mwSize numElements = mxGetNumberOfElements(prhs[1]);

					uInt8 *writeData = (uInt8 *)mxCalloc(numElements,sizeof(uInt8));					

					for (unsigned int i=0;i<numElements;i++)
					{
						if (writeDataRaw[i] != 0)
							writeData[i] = 1;
					}
					status = DAQmxWriteDigitalLines(taskID, numSampsPerChan, autoStart, timeout, dataLayout, writeData, &sampsWritten, NULL);

					mxFree(writeData);
				}
			}

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




