Class {
	#name : 'LLMStepExecutionTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Visualizer-Tests-Data',
	#package : 'LLM-LLMStudio-Visualizer-Tests',
	#tag : 'Data'
}

{ #category : 'tests' }
LLMStepExecutionTest >> testCreation [

	| exec |
	exec := LLMStepExecution stepName: 'myStep' className: 'LLMBlockStep'.
	self assert: exec stepName equals: 'myStep'.
	self assert: exec stepClassName equals: 'LLMBlockStep'.
	self assert: exec status equals: #pending
]

{ #category : 'tests' }
LLMStepExecutionTest >> testDefaultTokensAreZero [

	| exec |
	exec := LLMStepExecution new.
	self assert: exec inputTokens equals: 0.
	self assert: exec outputTokens equals: 0.
	self assert: exec totalTokens equals: 0
]

{ #category : 'tests' }
LLMStepExecutionTest >> testDurationCalculation [

	| exec |
	exec := LLMStepExecution new.
	exec startTime: (DateAndTime year: 2025 month: 1 day: 1 hour: 10 minute: 0 second: 0).
	exec endTime: (DateAndTime year: 2025 month: 1 day: 1 hour: 10 minute: 0 second: 2).
	self assert: exec durationMs equals: 2000
]

{ #category : 'tests' }
LLMStepExecutionTest >> testDurationZeroWhenNoTimes [

	| exec |
	exec := LLMStepExecution new.
	self assert: exec durationMs equals: 0
]

{ #category : 'tests' }
LLMStepExecutionTest >> testIsError [

	| exec |
	exec := LLMStepExecution new.
	self deny: exec isError.
	exec status: #error.
	self assert: exec isError
]

{ #category : 'tests' }
LLMStepExecutionTest >> testIsSuccess [

	| exec |
	exec := LLMStepExecution new.
	self deny: exec isSuccess.
	exec status: #success.
	self assert: exec isSuccess
]

{ #category : 'tests' }
LLMStepExecutionTest >> testMarkError [

	| exec |
	exec := LLMStepExecution new.
	exec markStarted.
	self assert: exec status equals: #running.
	exec markError: (Error new messageText: 'test failure').
	self assert: exec status equals: #error.
	self assert: exec error equals: 'test failure'.
	self assert: exec endTime isNotNil
]

{ #category : 'tests' }
LLMStepExecutionTest >> testMarkStartedAndSuccess [

	| exec |
	exec := LLMStepExecution new.
	exec markStarted.
	self assert: exec status equals: #running.
	self assert: exec startTime isNotNil.
	exec markSuccess.
	self assert: exec status equals: #success.
	self assert: exec endTime isNotNil.
	self assert: exec durationMs >= 0
]

{ #category : 'tests' }
LLMStepExecutionTest >> testMetadata [

	| exec |
	exec := LLMStepExecution new.
	exec metadataAt: #key put: 'value'.
	self assert: (exec metadata at: #key) equals: 'value'
]

{ #category : 'tests' }
LLMStepExecutionTest >> testPrintOn [

	| exec |
	exec := LLMStepExecution stepName: 'test' className: 'LLMBlockStep'.
	self assert: exec printString equals: 'LLMStepExecution(test [pending] 0ms)'
]

{ #category : 'tests' }
LLMStepExecutionTest >> testRecordTokenUsage [

	| exec response |
	exec := LLMStepExecution new.
	response := LLMResponse new.
	response usage: {
			('prompt_tokens' -> 100).
			('completion_tokens' -> 50) } asDictionary.
	exec recordTokenUsage: response.
	self assert: exec inputTokens equals: 100.
	self assert: exec outputTokens equals: 50.
	self assert: exec totalTokens equals: 150
]

{ #category : 'tests' }
LLMStepExecutionTest >> testRecordTokenUsageNilResponse [

	| exec |
	exec := LLMStepExecution new.
	exec recordTokenUsage: nil.
	self assert: exec totalTokens equals: 0
]

{ #category : 'tests' }
LLMStepExecutionTest >> testStatusLabels [

	| exec |
	exec := LLMStepExecution new.
	exec status: #success.
	self assert: exec statusLabel equals: '[OK]'.
	exec status: #error.
	self assert: exec statusLabel equals: '[ERR]'.
	exec status: #running.
	self assert: exec statusLabel equals: '[...]'.
	exec status: #pending.
	self assert: exec statusLabel equals: '[ ]'
]

{ #category : 'tests' }
LLMStepExecutionTest >> testStepIndex [

	| exec |
	exec := LLMStepExecution new.
	exec stepIndex: 3.
	self assert: exec stepIndex equals: 3
]
