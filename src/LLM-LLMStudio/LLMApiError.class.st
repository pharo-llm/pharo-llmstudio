Class {
	#name : 'LLMApiError',
	#superclass : 'LLMError',
	#instVars : [
		'statusCode',
		'responseBody'
	],
	#category : 'LLM-LLMStudio-Errors',
	#package : 'LLM-LLMStudio',
	#tag : 'Errors'
}

{ #category : 'instance creation' }
LLMApiError class >> statusCode: anInteger body: aString [

	^ self new
		  statusCode: anInteger;
		  responseBody: aString;
		  messageText: 'API error: ' , anInteger printString , ' - ' , aString;
		  yourself
]

{ #category : 'accessing' }
LLMApiError >> responseBody [

	^ responseBody
]

{ #category : 'accessing' }
LLMApiError >> responseBody: aString [

	responseBody := aString
]

{ #category : 'accessing' }
LLMApiError >> statusCode [

	^ statusCode
]

{ #category : 'accessing' }
LLMApiError >> statusCode: anInteger [

	statusCode := anInteger
]
