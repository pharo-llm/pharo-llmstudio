Class {
	#name : 'LLMError',
	#superclass : 'Error',
	#instVars : [
		'details'
	],
	#category : 'LLM-LLMStudio-Errors',
	#package : 'LLM-LLMStudio',
	#tag : 'Errors'
}

{ #category : 'instance creation' }
LLMError class >> message: aString details: aDictionary [

	^ self new
		  messageText: aString;
		  details: aDictionary;
		  yourself
]

{ #category : 'accessing' }
LLMError >> details [

	^ details ifNil: [ details := Dictionary new ]
]

{ #category : 'accessing' }
LLMError >> details: aDictionary [

	details := aDictionary
]
