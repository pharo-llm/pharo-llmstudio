Class {
	#name : 'LLMParallelStepTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Core',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Core'
}

{ #category : 'tests' }
LLMParallelStepTest >> testBasicParallel [

	| step result |
	step := LLMParallelStep new.
	step addBranch: #upper step: (LLMBlockStep block: [ :ctx |
			 ctx output: (ctx at: #text ifAbsent: [ 'hello' ]) asUppercase.
			 ctx ]).
	step addBranch: #lower step: (LLMBlockStep block: [ :ctx |
			 ctx output: (ctx at: #text ifAbsent: [ 'hello' ]) asLowercase.
			 ctx ]).
	result := step runWith: { (#text -> 'Hello World') } asDictionary.
	self assert: (result output at: #upper) equals: 'HELLO WORLD'.
	self assert: (result output at: #lower) equals: 'hello world'
]

{ #category : 'tests' }
LLMParallelStepTest >> testBranchesFromDictionary [

	| step |
	step := LLMParallelStep branches: {
			        (#a -> (LLMBlockStep block: [ :ctx | ctx output: 1. ctx ])).
			        (#b -> (LLMBlockStep block: [ :ctx | ctx output: 2. ctx ])) } asDictionary.
	self assert: step branches size equals: 2
]

{ #category : 'tests' }
LLMParallelStepTest >> testBranchIsolation [

	| step result |
	step := LLMParallelStep new.
	step addBranch: #first step: (LLMBlockStep block: [ :ctx |
			 ctx at: #modified put: true.
			 ctx output: 'first'.
			 ctx ]).
	step addBranch: #second step: (LLMBlockStep block: [ :ctx |
			 ctx output: (ctx at: #modified ifAbsent: [ 'not modified' ]).
			 ctx ]).
	result := step runWith: Dictionary new.
	"Branches should get independent copies of the context"
	self assert: (result output at: #second) equals: 'not modified'
]

{ #category : 'tests' }
LLMParallelStepTest >> testResultsInContext [

	| step result |
	step := LLMParallelStep new.
	step addBranch: #x step: (LLMBlockStep block: [ :ctx | ctx output: 10. ctx ]).
	step addBranch: #y step: (LLMBlockStep block: [ :ctx | ctx output: 20. ctx ]).
	result := step runWith: Dictionary new.
	self assert: ((result at: #parallelResults) at: #x) equals: 10.
	self assert: ((result at: #parallelResults) at: #y) equals: 20
]

{ #category : 'tests' }
LLMParallelStepTest >> testValidationEmpty [

	| step |
	step := LLMParallelStep new.
	self should: [ step validate ] raise: LLMValidationError
]
