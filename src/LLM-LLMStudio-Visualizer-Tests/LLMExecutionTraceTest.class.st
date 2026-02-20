Class {
	#name : 'LLMExecutionTraceTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Visualizer-Tests-Data',
	#package : 'LLM-LLMStudio-Visualizer-Tests',
	#tag : 'Data'
}

{ #category : 'helpers' }
LLMExecutionTraceTest >> makeStep: aName status: aStatus tokens: anInteger [

	| exec |
	exec := LLMStepExecution stepName: aName className: 'LLMBlockStep'.
	exec status: aStatus.
	exec tokenUsage: {
			(#inputTokens -> (anInteger // 2)).
			(#outputTokens -> (anInteger // 2)).
			(#totalTokens -> anInteger) } asDictionary.
	exec startTime: DateAndTime now.
	exec endTime: DateAndTime now + 100 milliSeconds.
	^ exec
]

{ #category : 'tests' }
LLMExecutionTraceTest >> testAddStepExecutionAssignsIndex [

	| trace exec1 exec2 |
	trace := LLMExecutionTrace new.
	exec1 := LLMStepExecution new.
	exec2 := LLMStepExecution new.
	trace addStepExecution: exec1.
	trace addStepExecution: exec2.
	self assert: exec1 stepIndex equals: 1.
	self assert: exec2 stepIndex equals: 2
]

{ #category : 'tests' }
LLMExecutionTraceTest >> testAvgStepDuration [

	| trace |
	trace := LLMExecutionTrace new.
	trace addStepExecution: (self makeStep: 'a' status: #success tokens: 0).
	trace addStepExecution: (self makeStep: 'b' status: #success tokens: 0).
	self assert: trace avgStepDurationMs >= 0
]

{ #category : 'tests' }
LLMExecutionTraceTest >> testAvgStepDurationEmptyTrace [

	| trace |
	trace := LLMExecutionTrace new.
	self assert: trace avgStepDurationMs equals: 0
]

{ #category : 'tests' }
LLMExecutionTraceTest >> testCompletedAndErrorSteps [

	| trace |
	trace := LLMExecutionTrace new.
	trace addStepExecution: (self makeStep: 'a' status: #success tokens: 0).
	trace addStepExecution: (self makeStep: 'b' status: #error tokens: 0).
	trace addStepExecution: (self makeStep: 'c' status: #success tokens: 0).
	self assert: trace completedSteps size equals: 2.
	self assert: trace errorSteps size equals: 1
]

{ #category : 'tests' }
LLMExecutionTraceTest >> testCreation [

	| trace |
	trace := LLMExecutionTrace pipelineName: 'TestPipeline'.
	self assert: trace pipelineName equals: 'TestPipeline'.
	self assert: trace status equals: #pending.
	self assert: trace id isNotNil.
	self assert: trace stepExecutions isEmpty
]

{ #category : 'tests' }
LLMExecutionTraceTest >> testDefaultPipelineName [

	| trace |
	trace := LLMExecutionTrace new.
	self assert: trace pipelineName equals: 'Unnamed Pipeline'
]

{ #category : 'tests' }
LLMExecutionTraceTest >> testDuration [

	| trace |
	trace := LLMExecutionTrace new.
	self assert: trace totalDurationMs equals: 0.
	trace startTime: DateAndTime now.
	trace endTime: DateAndTime now + 500 milliSeconds.
	self assert: trace totalDurationMs >= 400
]

{ #category : 'tests' }
LLMExecutionTraceTest >> testMarkStartedAndSuccess [

	| trace |
	trace := LLMExecutionTrace new.
	trace markStarted.
	self assert: trace status equals: #running.
	self assert: trace startTime isNotNil.
	trace markSuccess.
	self assert: trace isSuccess.
	self assert: trace endTime isNotNil
]

{ #category : 'tests' }
LLMExecutionTraceTest >> testMessages [

	| trace msg |
	trace := LLMExecutionTrace new.
	msg := LLMChatMessage user: 'hello'.
	trace addMessage: msg.
	self assert: trace messages size equals: 1.
	self assert: trace messages first content equals: 'hello'
]

{ #category : 'tests' }
LLMExecutionTraceTest >> testStatusLabels [

	| trace |
	trace := LLMExecutionTrace new.
	trace status: #success.
	self assert: trace statusLabel equals: 'Success'.
	trace status: #error.
	self assert: trace statusLabel equals: 'Failed'.
	trace status: #running.
	self assert: trace statusLabel equals: 'Running'.
	trace status: #pending.
	self assert: trace statusLabel equals: 'Pending'
]

{ #category : 'tests' }
LLMExecutionTraceTest >> testStepCount [

	| trace |
	trace := LLMExecutionTrace new.
	self assert: trace stepCount equals: 0.
	trace addStepExecution: (self makeStep: 'a' status: #success tokens: 0).
	self assert: trace stepCount equals: 1
]

{ #category : 'tests' }
LLMExecutionTraceTest >> testSuccessRate [

	| trace |
	trace := LLMExecutionTrace new.
	self assert: trace successRate equals: 0.
	trace addStepExecution: (self makeStep: 'a' status: #success tokens: 0).
	trace addStepExecution: (self makeStep: 'b' status: #error tokens: 0).
	self assert: trace successRate equals: 50.0
]

{ #category : 'tests' }
LLMExecutionTraceTest >> testTokenAggregation [

	| trace |
	trace := LLMExecutionTrace new.
	trace addStepExecution: (self makeStep: 'a' status: #success tokens: 100).
	trace addStepExecution: (self makeStep: 'b' status: #success tokens: 200).
	self assert: trace totalTokens equals: 300.
	self assert: trace totalInputTokens equals: 150.
	self assert: trace totalOutputTokens equals: 150
]

{ #category : 'tests' }
LLMExecutionTraceTest >> testUniqueId [

	| trace1 trace2 |
	trace1 := LLMExecutionTrace new.
	trace2 := LLMExecutionTrace new.
	self deny: trace1 id = trace2 id
]
