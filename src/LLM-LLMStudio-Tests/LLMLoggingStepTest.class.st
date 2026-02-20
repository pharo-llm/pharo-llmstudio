Class {
	#name : 'LLMLoggingStepTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Core',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Core'
}

{ #category : 'tests' }
LLMLoggingStepTest >> testLoggingCapturesMessages [

	| logs step result |
	logs := OrderedCollection new.
	step := LLMLoggingStep
		        step: (LLMBlockStep named: 'doubler' block: [ :ctx |
				         ctx output: (ctx at: #value ifAbsent: [ 0 ]) * 2.
				         ctx ])
		        logger: [ :msg | logs add: msg ].
	result := step runWith: { (#value -> 21) } asDictionary.
	self assert: result output equals: 42.
	self assert: logs size equals: 2.
	self assert: (logs first includesSubstring: 'doubler')
]

{ #category : 'tests' }
LLMLoggingStepTest >> testLoggingInputOnly [

	| logs step |
	logs := OrderedCollection new.
	step := LLMLoggingStep
		        step: (LLMBlockStep block: [ :ctx | ctx ])
		        logger: [ :msg | logs add: msg ].
	step logOutput: false.
	step runWith: Dictionary new.
	self assert: logs size equals: 1
]

{ #category : 'tests' }
LLMLoggingStepTest >> testLoggingOutputOnly [

	| logs step |
	logs := OrderedCollection new.
	step := LLMLoggingStep
		        step: (LLMBlockStep block: [ :ctx | ctx ])
		        logger: [ :msg | logs add: msg ].
	step logInput: false.
	step runWith: Dictionary new.
	self assert: logs size equals: 1
]

{ #category : 'tests' }
LLMLoggingStepTest >> testValidation [

	| step |
	step := LLMLoggingStep new.
	self should: [ step validate ] raise: LLMValidationError
]
