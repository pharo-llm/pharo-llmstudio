Class {
	#name : 'LLMRetryStepTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Core',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Core'
}

{ #category : 'tests' }
LLMRetryStepTest >> testExhaustedRetries [

	| step |
	step := LLMRetryStep
		        step: (LLMBlockStep block: [ :ctx |
				         Error signal: 'Always fails' ])
		        maxRetries: 2.
	step backoffStrategy: #fixed.
	self should: [ step runWith: Dictionary new ] raise: Error
]

{ #category : 'tests' }
LLMRetryStepTest >> testExponentialBackoffDelay [

	| step |
	step := LLMRetryStep new.
	step backoffStrategy: #exponential.
	self assert: (step delayForAttempt: 1) equals: 1.
	self assert: (step delayForAttempt: 2) equals: 2.
	self assert: (step delayForAttempt: 3) equals: 4.
	self assert: (step delayForAttempt: 4) equals: 8
]

{ #category : 'tests' }
LLMRetryStepTest >> testLinearBackoffDelay [

	| step |
	step := LLMRetryStep new.
	step backoffStrategy: #linear.
	self assert: (step delayForAttempt: 1) equals: 1.
	self assert: (step delayForAttempt: 2) equals: 2.
	self assert: (step delayForAttempt: 3) equals: 3
]

{ #category : 'tests' }
LLMRetryStepTest >> testOnRetryCallback [

	| retries step |
	retries := OrderedCollection new.
	step := LLMRetryStep
		        step: (LLMBlockStep block: [ :ctx |
				         retries size < 2 ifTrue: [ Error signal: 'Retry' ].
				         ctx output: 'ok'.
				         ctx ])
		        maxRetries: 3.
	step backoffStrategy: #fixed.
	step onRetry: [ :error :attempt | retries add: attempt ].
	step runWith: Dictionary new.
	self assert: retries size equals: 2.
	self assert: retries first equals: 1.
	self assert: retries second equals: 2
]

{ #category : 'tests' }
LLMRetryStepTest >> testSuccessAfterRetries [

	| callCount step result |
	callCount := 0.
	step := LLMRetryStep
		        step: (LLMBlockStep block: [ :ctx |
				         callCount := callCount + 1.
				         callCount < 3 ifTrue: [ Error signal: 'Not yet' ].
				         ctx output: 'finally'.
				         ctx ])
		        maxRetries: 5.
	step backoffStrategy: #fixed.
	result := step runWith: Dictionary new.
	self assert: result output equals: 'finally'.
	self assert: callCount equals: 3
]

{ #category : 'tests' }
LLMRetryStepTest >> testSuccessOnFirstTry [

	| step result |
	step := LLMRetryStep
		        step: (LLMBlockStep block: [ :ctx |
				         ctx output: 'success'.
				         ctx ])
		        maxRetries: 3.
	result := step runWith: Dictionary new.
	self assert: result output equals: 'success'
]

{ #category : 'tests' }
LLMRetryStepTest >> testValidation [

	| step |
	step := LLMRetryStep new.
	self should: [ step validate ] raise: LLMValidationError
]
