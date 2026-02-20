Class {
	#name : 'LLMMockModel',
	#superclass : 'LLMAbstractModel',
	#instVars : [
		'responses',
		'callCount',
		'capturedRequests'
	],
	#category : 'LLM-LLMStudio-Tests-Helpers',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Helpers'
}

{ #category : 'instance creation' }
LLMMockModel class >> new [

	^ super new initialize
]

{ #category : 'instance creation' }
LLMMockModel class >> respondingWith: aString [
	"Create a mock model that always returns the given string."

	^ self new addResponse: aString
]

{ #category : 'instance creation' }
LLMMockModel class >> respondingWithSequence: aCollection [
	"Create a mock model that returns responses in sequence."

	| instance |
	instance := self new.
	aCollection do: [ :resp | instance addResponse: resp ].
	^ instance
]

{ #category : 'configuration' }
LLMMockModel >> addResponse: aStringOrResponse [
	"Add a response to the queue. Can be a string or an LLMResponse."

	| response |
	response := aStringOrResponse isString
		            ifTrue: [ LLMResponse content: aStringOrResponse ]
		            ifFalse: [ aStringOrResponse ].
	responses add: response.
	^ self
]

{ #category : 'configuration' }
LLMMockModel >> addToolCallResponse: aToolCallsArray [
	"Add a response that contains tool calls."

	| response |
	response := LLMResponse new.
	response content: ''.
	response toolCalls: aToolCallsArray.
	responses add: response.
	^ self
]

{ #category : 'api' }
LLMMockModel >> buildRequestBody: messages [

	^ Dictionary new
		  at: 'model' put: 'mock';
		  at: 'messages' put: (self normalizeMessages: messages);
		  yourself
]

{ #category : 'accessing' }
LLMMockModel >> callCount [

	^ callCount
]

{ #category : 'accessing' }
LLMMockModel >> capturedRequests [

	^ capturedRequests
]

{ #category : 'api' }
LLMMockModel >> chat: messages [
	"Return the next queued response, cycling if necessary."

	| response |
	capturedRequests add: messages.
	callCount := callCount + 1.
	responses ifEmpty: [
		^ LLMResponse content: 'Mock response ' , callCount printString ].
	response := responses size >= callCount
		            ifTrue: [ responses at: callCount ]
		            ifFalse: [ responses last ].
	^ response
]

{ #category : 'api' }
LLMMockModel >> completionEndpoint [

	^ '/mock/chat'
]

{ #category : 'private' }
LLMMockModel >> createDefaultConnector [

	^ LLMHttpConnector baseUrl: 'http://localhost:0'
]

{ #category : 'initialization' }
LLMMockModel >> initialize [

	super initialize.
	responses := OrderedCollection new.
	callCount := 0.
	capturedRequests := OrderedCollection new.
	modelId := 'mock-model'
]

{ #category : 'accessing' }
LLMMockModel >> lastCapturedMessages [

	^ capturedRequests last
]

{ #category : 'accessing' }
LLMMockModel >> providerName [

	^ #mock
]
