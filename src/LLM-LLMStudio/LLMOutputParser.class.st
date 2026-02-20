Class {
	#name : 'LLMOutputParser',
	#superclass : 'Object',
	#category : 'LLM-LLMStudio-Parsers',
	#package : 'LLM-LLMStudio',
	#tag : 'Parsers'
}

{ #category : 'parsing' }
LLMOutputParser >> parse: aString [
	"Parse the LLM output string. Subclasses must override."

	^ self subclassResponsibility
]

{ #category : 'parsing' }
LLMOutputParser >> parseResponse: anLLMResponse [
	"Parse an LLMResponse object."

	^ self parse: anLLMResponse content
]

{ #category : 'printing' }
LLMOutputParser >> printOn: aStream [

	aStream nextPutAll: self class name
]
