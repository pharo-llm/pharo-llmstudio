Class {
	#name : 'LLMBlockStepTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Core',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Core'
}

{ #category : 'tests' }
LLMBlockStepTest >> testBasicBlock [

	| step result |
	step := LLMBlockStep block: [ :ctx |
		        ctx output: 'hello from block'.
		        ctx ].
	result := step runWith: Dictionary new.
	self assert: result output equals: 'hello from block'
]

{ #category : 'tests' }
LLMBlockStepTest >> testBlockReturningValue [

	| step result |
	step := LLMBlockStep block: [ :ctx | 42 ].
	result := step runWith: Dictionary new.
	self assert: result output equals: 42
]

{ #category : 'tests' }
LLMBlockStepTest >> testBlockAccessingVariables [

	| step result |
	step := LLMBlockStep block: [ :ctx |
		        ctx output: ((ctx at: #x) + (ctx at: #y)).
		        ctx ].
	result := step runWith: {
			          (#x -> 10).
			          (#y -> 20) } asDictionary.
	self assert: result output equals: 30
]

{ #category : 'tests' }
LLMBlockStepTest >> testBlockModifyingContext [

	| step result |
	step := LLMBlockStep block: [ :ctx |
		        ctx at: #processed put: true.
		        ctx at: #text put: (ctx at: #text ifAbsent: [ '' ]) , ' processed'.
		        ctx ].
	result := step runWith: { (#text -> 'input') } asDictionary.
	self assert: (result at: #processed).
	self assert: (result at: #text) equals: 'input processed'
]

{ #category : 'tests' }
LLMBlockStepTest >> testNamedBlock [

	| step |
	step := LLMBlockStep named: 'transformer' block: [ :ctx | ctx ].
	self assert: step name equals: 'transformer'
]

{ #category : 'tests' }
LLMBlockStepTest >> testValidationNoBlock [

	| step |
	step := LLMBlockStep new.
	self should: [ step validate ] raise: LLMValidationError
]
