Class {
	#name : 'LLMPipelineTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Core',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Core'
}

{ #category : 'tests' }
LLMPipelineTest >> testEmptyPipeline [

	| pipeline ctx result |
	pipeline := LLMPipeline new.
	ctx := LLMPipelineContext new.
	ctx output: 'input'.
	result := pipeline processContext: ctx.
	self assert: result output equals: 'input'
]

{ #category : 'tests' }
LLMPipelineTest >> testHistoryRecording [

	| pipeline result |
	pipeline := LLMPipeline new
		            addStep: (LLMBlockStep named: 'first' block: [ :ctx |
					             ctx output: 'one'.
					             ctx ]);
		            addStep: (LLMBlockStep named: 'second' block: [ :ctx |
					             ctx output: 'two'.
					             ctx ]);
		            yourself.
	result := pipeline runWith: Dictionary new.
	self assert: result history size equals: 2
]

{ #category : 'tests' }
LLMPipelineTest >> testMultipleSteps [

	| pipeline result |
	pipeline := LLMPipeline new
		            addStep: (LLMBlockStep block: [ :ctx |
					             ctx output: 'step1'.
					             ctx ]);
		            addStep: (LLMBlockStep block: [ :ctx |
					             ctx output: ctx output , '+step2'.
					             ctx ]);
		            addStep: (LLMBlockStep block: [ :ctx |
					             ctx output: ctx output , '+step3'.
					             ctx ]);
		            yourself.
	result := pipeline runWith: Dictionary new.
	self assert: result output equals: 'step1+step2+step3'
]

{ #category : 'tests' }
LLMPipelineTest >> testNestedPipelines [

	| innerPipeline outerPipeline result |
	innerPipeline := LLMPipeline new
		                 addStep: (LLMBlockStep block: [ :ctx |
					                  ctx output: 'inner'.
					                  ctx ]);
		                 yourself.
	outerPipeline := LLMPipeline new
		                 addStep: (LLMBlockStep block: [ :ctx |
					                  ctx output: 'before-'.
					                  ctx ]);
		                 addStep: innerPipeline;
		                 addStep: (LLMBlockStep block: [ :ctx |
					                  ctx output: ctx output , '-after'.
					                  ctx ]);
		                 yourself.
	result := outerPipeline runWith: Dictionary new.
	self assert: result output equals: 'inner-after'
]

{ #category : 'tests' }
LLMPipelineTest >> testPipelineWithVariables [

	| pipeline result |
	pipeline := LLMPipeline new
		            addStep: (LLMBlockStep block: [ :ctx |
					             ctx output: (ctx at: #greeting) , ' ' , (ctx at: #name).
					             ctx ]);
		            yourself.
	result := pipeline runWith: {
			          (#greeting -> 'Hello').
			          (#name -> 'World') } asDictionary.
	self assert: result output equals: 'Hello World'
]

{ #category : 'tests' }
LLMPipelineTest >> testSingleStep [

	| pipeline result |
	pipeline := LLMPipeline new
		            addStep: (LLMBlockStep block: [ :ctx |
					             ctx output: ((ctx output ifNil: [ '' ]) , ' processed').
					             ctx ]);
		            yourself.
	result := pipeline runWith: Dictionary new.
	self assert: result output equals: ' processed'
]

{ #category : 'tests' }
LLMPipelineTest >> testStepCount [

	| pipeline |
	pipeline := LLMPipeline new
		            addStep: (LLMBlockStep block: [ :ctx | ctx ]);
		            addStep: (LLMBlockStep block: [ :ctx | ctx ]);
		            yourself.
	self assert: pipeline stepCount equals: 2
]

{ #category : 'tests' }
LLMPipelineTest >> testThenChaining [

	| step1 step2 step3 pipeline result |
	step1 := LLMBlockStep block: [ :ctx |
		         ctx output: 'a'.
		         ctx ].
	step2 := LLMBlockStep block: [ :ctx |
		         ctx output: ctx output , 'b'.
		         ctx ].
	step3 := LLMBlockStep block: [ :ctx |
		         ctx output: ctx output , 'c'.
		         ctx ].
	pipeline := (step1 then: step2) then: step3.
	result := pipeline runWith: Dictionary new.
	self assert: result output equals: 'abc'
]

{ #category : 'tests' }
LLMPipelineTest >> testWithStepsCreation [

	| pipeline |
	pipeline := LLMPipeline withSteps: {
			            (LLMBlockStep block: [ :ctx | ctx ]).
			            (LLMBlockStep block: [ :ctx | ctx ]) }.
	self assert: pipeline stepCount equals: 2
]
