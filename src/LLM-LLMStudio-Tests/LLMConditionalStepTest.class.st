Class {
	#name : 'LLMConditionalStepTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Core',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Core'
}

{ #category : 'tests' }
LLMConditionalStepTest >> testFalseBranch [

	| step result |
	step := LLMConditionalStep
		        condition: [ :ctx | (ctx at: #value) > 10 ]
		        ifTrue: (LLMBlockStep block: [ :ctx |
				         ctx output: 'big'.
				         ctx ])
		        ifFalse: (LLMBlockStep block: [ :ctx |
				         ctx output: 'small'.
				         ctx ]).
	result := step runWith: { (#value -> 5) } asDictionary.
	self assert: result output equals: 'small'
]

{ #category : 'tests' }
LLMConditionalStepTest >> testInPipeline [

	| pipeline result |
	pipeline := LLMPipeline new
		            addStep: (LLMBlockStep block: [ :ctx |
					             ctx at: #score put: 85.
					             ctx ]);
		            addStep: (LLMConditionalStep
					             condition: [ :ctx | (ctx at: #score) >= 70 ]
					             ifTrue: (LLMBlockStep block: [ :ctx |
							              ctx output: 'pass'.
							              ctx ])
					             ifFalse: (LLMBlockStep block: [ :ctx |
							              ctx output: 'fail'.
							              ctx ]));
		            yourself.
	result := pipeline runWith: Dictionary new.
	self assert: result output equals: 'pass'
]

{ #category : 'tests' }
LLMConditionalStepTest >> testNoFalseBranch [

	| step result |
	step := LLMConditionalStep
		        condition: [ :ctx | false ]
		        ifTrue: (LLMBlockStep block: [ :ctx |
				         ctx output: 'true'.
				         ctx ]).
	result := step runWith: Dictionary new.
	self assert: result output isNil
]

{ #category : 'tests' }
LLMConditionalStepTest >> testTrueBranch [

	| step result |
	step := LLMConditionalStep
		        condition: [ :ctx | (ctx at: #value) > 10 ]
		        ifTrue: (LLMBlockStep block: [ :ctx |
				         ctx output: 'big'.
				         ctx ])
		        ifFalse: (LLMBlockStep block: [ :ctx |
				         ctx output: 'small'.
				         ctx ]).
	result := step runWith: { (#value -> 20) } asDictionary.
	self assert: result output equals: 'big'
]

{ #category : 'tests' }
LLMConditionalStepTest >> testValidationMissingCondition [

	| step |
	step := LLMConditionalStep new.
	step trueStep: (LLMBlockStep block: [ :ctx | ctx ]).
	self should: [ step validate ] raise: LLMValidationError
]
