Class {
	#name : 'LLMExecutionTrace',
	#superclass : 'Object',
	#instVars : [
		'id',
		'pipelineName',
		'stepExecutions',
		'startTime',
		'endTime',
		'inputVariables',
		'finalOutput',
		'status',
		'messages'
	],
	#category : 'LLM-LLMStudio-Visualizer-Data',
	#package : 'LLM-LLMStudio-Visualizer',
	#tag : 'Data'
}

{ #category : 'instance creation' }
LLMExecutionTrace class >> new [

	^ super new initialize
]

{ #category : 'instance creation' }
LLMExecutionTrace class >> pipelineName: aString [

	^ self new
		  pipelineName: aString;
		  yourself
]

{ #category : 'adding' }
LLMExecutionTrace >> addMessage: aMessage [
	"Record a conversation message (LLMChatMessage)."

	messages add: aMessage
]

{ #category : 'adding' }
LLMExecutionTrace >> addStepExecution: aStepExecution [

	aStepExecution stepIndex: stepExecutions size + 1.
	stepExecutions add: aStepExecution
]

{ #category : 'accessing - computed' }
LLMExecutionTrace >> avgStepDurationMs [

	| completed |
	completed := self completedSteps.
	completed ifEmpty: [ ^ 0 ].
	^ (completed collect: [ :s | s durationMs ]) average asFloat round: 1
]

{ #category : 'accessing - computed' }
LLMExecutionTrace >> completedSteps [

	^ stepExecutions select: [ :s | s isSuccess ]
]

{ #category : 'accessing' }
LLMExecutionTrace >> endTime [

	^ endTime
]

{ #category : 'accessing' }
LLMExecutionTrace >> endTime: aDateAndTime [

	endTime := aDateAndTime
]

{ #category : 'accessing - computed' }
LLMExecutionTrace >> errorSteps [

	^ stepExecutions select: [ :s | s isError ]
]

{ #category : 'accessing' }
LLMExecutionTrace >> finalOutput [

	^ finalOutput
]

{ #category : 'accessing' }
LLMExecutionTrace >> finalOutput: anObject [

	finalOutput := anObject
]

{ #category : 'accessing' }
LLMExecutionTrace >> id [

	^ id
]

{ #category : 'accessing' }
LLMExecutionTrace >> id: aString [

	id := aString
]

{ #category : 'initialization' }
LLMExecutionTrace >> initialize [

	id := UUID new asString36.
	stepExecutions := OrderedCollection new.
	messages := OrderedCollection new.
	inputVariables := Dictionary new.
	status := #pending
]

{ #category : 'accessing' }
LLMExecutionTrace >> inputVariables [

	^ inputVariables
]

{ #category : 'accessing' }
LLMExecutionTrace >> inputVariables: aDictionary [

	inputVariables := aDictionary
]

{ #category : 'testing' }
LLMExecutionTrace >> isError [

	^ status = #error
]

{ #category : 'testing' }
LLMExecutionTrace >> isSuccess [

	^ status = #success
]

{ #category : 'recording' }
LLMExecutionTrace >> markError [

	endTime := DateAndTime now.
	status := #error
]

{ #category : 'recording' }
LLMExecutionTrace >> markStarted [

	startTime := DateAndTime now.
	status := #running
]

{ #category : 'recording' }
LLMExecutionTrace >> markSuccess [

	endTime := DateAndTime now.
	status := #success
]

{ #category : 'accessing' }
LLMExecutionTrace >> messages [

	^ messages
]

{ #category : 'accessing' }
LLMExecutionTrace >> messages: aCollection [

	messages := aCollection asOrderedCollection
]

{ #category : 'accessing' }
LLMExecutionTrace >> pipelineName [

	^ pipelineName ifNil: [ 'Unnamed Pipeline' ]
]

{ #category : 'accessing' }
LLMExecutionTrace >> pipelineName: aString [

	pipelineName := aString
]

{ #category : 'printing' }
LLMExecutionTrace >> printOn: aStream [

	aStream
		nextPutAll: 'LLMExecutionTrace(';
		nextPutAll: self pipelineName;
		nextPutAll: ' [';
		nextPutAll: status asString;
		nextPutAll: '] ';
		print: stepExecutions size;
		nextPutAll: ' steps, ';
		nextPutAll: self totalDurationMs printString;
		nextPutAll: 'ms)'
]

{ #category : 'accessing' }
LLMExecutionTrace >> startTime [

	^ startTime
]

{ #category : 'accessing' }
LLMExecutionTrace >> startTime: aDateAndTime [

	startTime := aDateAndTime
]

{ #category : 'accessing' }
LLMExecutionTrace >> status [

	^ status
]

{ #category : 'accessing' }
LLMExecutionTrace >> status: aSymbol [

	status := aSymbol
]

{ #category : 'accessing' }
LLMExecutionTrace >> statusLabel [

	status = #success ifTrue: [ ^ 'Success' ].
	status = #error ifTrue: [ ^ 'Failed' ].
	status = #running ifTrue: [ ^ 'Running' ].
	^ 'Pending'
]

{ #category : 'accessing' }
LLMExecutionTrace >> stepCount [

	^ stepExecutions size
]

{ #category : 'accessing' }
LLMExecutionTrace >> stepExecutions [

	^ stepExecutions
]

{ #category : 'accessing' }
LLMExecutionTrace >> stepExecutions: aCollection [

	stepExecutions := aCollection asOrderedCollection
]

{ #category : 'accessing - computed' }
LLMExecutionTrace >> successRate [

	stepExecutions ifEmpty: [ ^ 0 ].
	^ ((self completedSteps size / stepExecutions size) * 100) asFloat round: 1
]

{ #category : 'accessing - computed' }
LLMExecutionTrace >> totalDurationMs [

	(startTime isNotNil and: [ endTime isNotNil ])
		ifTrue: [ ^ (endTime - startTime) asMilliSeconds ].
	^ 0
]

{ #category : 'accessing - computed' }
LLMExecutionTrace >> totalInputTokens [

	^ (stepExecutions collect: [ :s | s inputTokens ]) sum
]

{ #category : 'accessing - computed' }
LLMExecutionTrace >> totalOutputTokens [

	^ (stepExecutions collect: [ :s | s outputTokens ]) sum
]

{ #category : 'accessing - computed' }
LLMExecutionTrace >> totalTokens [

	^ (stepExecutions collect: [ :s | s totalTokens ]) sum
]
