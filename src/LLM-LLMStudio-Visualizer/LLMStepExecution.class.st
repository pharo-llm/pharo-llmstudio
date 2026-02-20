Class {
	#name : 'LLMStepExecution',
	#superclass : 'Object',
	#instVars : [
		'stepName',
		'stepClassName',
		'stepIndex',
		'input',
		'output',
		'startTime',
		'endTime',
		'duration',
		'tokenUsage',
		'status',
		'error',
		'metadata'
	],
	#category : 'LLM-LLMStudio-Visualizer-Data',
	#package : 'LLM-LLMStudio-Visualizer',
	#tag : 'Data'
}

{ #category : 'instance creation' }
LLMStepExecution class >> new [

	^ super new initialize
]

{ #category : 'instance creation' }
LLMStepExecution class >> stepName: aName className: aClassName [

	^ self new
		  stepName: aName;
		  stepClassName: aClassName;
		  yourself
]

{ #category : 'accessing' }
LLMStepExecution >> duration [

	^ duration ifNil: [
		  (startTime isNotNil and: [ endTime isNotNil ])
			  ifTrue: [ endTime - startTime ]
			  ifFalse: [ Duration zero ] ]
]

{ #category : 'accessing' }
LLMStepExecution >> duration: aDuration [

	duration := aDuration
]

{ #category : 'accessing' }
LLMStepExecution >> durationMs [

	^ self duration asMilliSeconds
]

{ #category : 'accessing' }
LLMStepExecution >> endTime [

	^ endTime
]

{ #category : 'accessing' }
LLMStepExecution >> endTime: aDateAndTime [

	endTime := aDateAndTime
]

{ #category : 'accessing' }
LLMStepExecution >> error [

	^ error
]

{ #category : 'accessing' }
LLMStepExecution >> error: anError [

	error := anError
]

{ #category : 'initialization' }
LLMStepExecution >> initialize [

	status := #pending.
	metadata := Dictionary new.
	tokenUsage := Dictionary new
]

{ #category : 'accessing' }
LLMStepExecution >> input [

	^ input
]

{ #category : 'accessing' }
LLMStepExecution >> input: anObject [

	input := anObject
]

{ #category : 'accessing' }
LLMStepExecution >> inputTokens [

	^ tokenUsage at: #inputTokens ifAbsent: [ 0 ]
]

{ #category : 'testing' }
LLMStepExecution >> isError [

	^ status = #error
]

{ #category : 'testing' }
LLMStepExecution >> isSuccess [

	^ status = #success
]

{ #category : 'recording' }
LLMStepExecution >> markError: anError [

	endTime := DateAndTime now.
	status := #error.
	error := anError messageText
]

{ #category : 'recording' }
LLMStepExecution >> markStarted [

	startTime := DateAndTime now.
	status := #running
]

{ #category : 'recording' }
LLMStepExecution >> markSuccess [

	endTime := DateAndTime now.
	status := #success
]

{ #category : 'accessing' }
LLMStepExecution >> metadata [

	^ metadata
]

{ #category : 'accessing' }
LLMStepExecution >> metadata: aDictionary [

	metadata := aDictionary
]

{ #category : 'accessing' }
LLMStepExecution >> metadataAt: aKey put: aValue [

	metadata at: aKey put: aValue
]

{ #category : 'accessing' }
LLMStepExecution >> output [

	^ output
]

{ #category : 'accessing' }
LLMStepExecution >> output: anObject [

	output := anObject
]

{ #category : 'accessing' }
LLMStepExecution >> outputTokens [

	^ tokenUsage at: #outputTokens ifAbsent: [ 0 ]
]

{ #category : 'printing' }
LLMStepExecution >> printOn: aStream [

	aStream
		nextPutAll: 'LLMStepExecution(';
		nextPutAll: (stepName ifNil: [ 'unnamed' ]);
		nextPutAll: ' [';
		nextPutAll: status asString;
		nextPutAll: '] ';
		nextPutAll: self durationMs printString;
		nextPutAll: 'ms)'
]

{ #category : 'recording' }
LLMStepExecution >> recordTokenUsage: aResponse [
	"Extract token usage from an LLMResponse if present."

	aResponse ifNil: [ ^ self ].
	tokenUsage at: #inputTokens put: aResponse inputTokens.
	tokenUsage at: #outputTokens put: aResponse outputTokens.
	tokenUsage at: #totalTokens put: aResponse totalTokens
]

{ #category : 'accessing' }
LLMStepExecution >> startTime [

	^ startTime
]

{ #category : 'accessing' }
LLMStepExecution >> startTime: aDateAndTime [

	startTime := aDateAndTime
]

{ #category : 'accessing' }
LLMStepExecution >> status [

	^ status
]

{ #category : 'accessing' }
LLMStepExecution >> status: aSymbol [

	status := aSymbol
]

{ #category : 'accessing' }
LLMStepExecution >> statusLabel [

	status = #success ifTrue: [ ^ '[OK]' ].
	status = #error ifTrue: [ ^ '[ERR]' ].
	status = #running ifTrue: [ ^ '[...]' ].
	status = #pending ifTrue: [ ^ '[ ]' ].
	^ '[?]'
]

{ #category : 'accessing' }
LLMStepExecution >> stepClassName [

	^ stepClassName
]

{ #category : 'accessing' }
LLMStepExecution >> stepClassName: aString [

	stepClassName := aString
]

{ #category : 'accessing' }
LLMStepExecution >> stepIndex [

	^ stepIndex
]

{ #category : 'accessing' }
LLMStepExecution >> stepIndex: anInteger [

	stepIndex := anInteger
]

{ #category : 'accessing' }
LLMStepExecution >> stepName [

	^ stepName
]

{ #category : 'accessing' }
LLMStepExecution >> stepName: aString [

	stepName := aString
]

{ #category : 'accessing' }
LLMStepExecution >> tokenUsage [

	^ tokenUsage
]

{ #category : 'accessing' }
LLMStepExecution >> tokenUsage: aDictionary [

	tokenUsage := aDictionary
]

{ #category : 'accessing' }
LLMStepExecution >> totalTokens [

	^ tokenUsage at: #totalTokens ifAbsent: [ 0 ]
]
