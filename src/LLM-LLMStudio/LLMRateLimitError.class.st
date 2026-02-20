Class {
	#name : 'LLMRateLimitError',
	#superclass : 'LLMApiError',
	#instVars : [
		'retryAfterSeconds'
	],
	#category : 'LLM-LLMStudio-Errors',
	#package : 'LLM-LLMStudio',
	#tag : 'Errors'
}

{ #category : 'instance creation' }
LLMRateLimitError class >> retryAfter: anInteger [

	^ self new
		  retryAfterSeconds: anInteger;
		  statusCode: 429;
		  messageText: 'Rate limit exceeded. Retry after ' , anInteger printString , ' seconds';
		  yourself
]

{ #category : 'accessing' }
LLMRateLimitError >> retryAfterSeconds [

	^ retryAfterSeconds
]

{ #category : 'accessing' }
LLMRateLimitError >> retryAfterSeconds: anInteger [

	retryAfterSeconds := anInteger
]
