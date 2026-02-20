Class {
	#name : 'LLMMapStepTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Core',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Core'
}

{ #category : 'tests' }
LLMMapStepTest >> testMapInPipeline [

	| pipeline result |
	pipeline := LLMPipeline new
		            addStep: (LLMBlockStep block: [ :ctx |
					             ctx at: #items put: #( 1 2 3 4 5 ).
					             ctx ]);
		            addStep: (LLMMapStep step: (LLMBlockStep block: [ :ctx |
							          ctx output: ctx output squared.
							          ctx ]));
		            yourself.
	result := pipeline runWith: Dictionary new.
	self assert: result output equals: #( 1 4 9 16 25 )
]

{ #category : 'tests' }
LLMMapStepTest >> testMapOverItems [

	| step result |
	step := LLMMapStep step: (LLMBlockStep block: [ :ctx |
			         ctx output: ctx output * 2.
			         ctx ]).
	result := step runWith: { (#items -> #( 1 2 3 )) } asDictionary.
	self assert: result output equals: #( 2 4 6 )
]

{ #category : 'tests' }
LLMMapStepTest >> testMapValidation [

	| step |
	step := LLMMapStep new.
	self should: [ step validate ] raise: LLMValidationError
]

{ #category : 'tests' }
LLMMapStepTest >> testMapWithCustomKeys [

	| step result |
	step := LLMMapStep step: (LLMBlockStep block: [ :ctx |
			         ctx output: ctx output asUppercase.
			         ctx ]).
	step inputKey: #words.
	step outputKey: #uppercased.
	result := step runWith:
		          { (#words -> #( 'hello' 'world' )) } asDictionary.
	self assert: result output equals: #( 'HELLO' 'WORLD' ).
	self assert: (result at: #uppercased) equals: #( 'HELLO' 'WORLD' )
]
