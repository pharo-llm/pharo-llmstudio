Class {
	#name : 'LLMTimeoutError',
	#superclass : 'LLMError',
	#instVars : [
		'timeoutSeconds'
	],
	#category : 'LLM-LLMStudio-Errors',
	#package : 'LLM-LLMStudio',
	#tag : 'Errors'
}

{ #category : 'instance creation' }
LLMTimeoutError class >> seconds: anInteger [

	^ self new
		  timeoutSeconds: anInteger;
		  messageText: 'Request timed out after ' , anInteger printString , ' seconds';
		  yourself
]

{ #category : 'accessing' }
LLMTimeoutError >> timeoutSeconds [

	^ timeoutSeconds
]

{ #category : 'accessing' }
LLMTimeoutError >> timeoutSeconds: anInteger [

	timeoutSeconds := anInteger
]
