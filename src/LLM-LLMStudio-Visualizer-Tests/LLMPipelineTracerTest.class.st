Class {
	#name : 'LLMPipelineTracerTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Visualizer-Tests-Data',
	#package : 'LLM-LLMStudio-Visualizer-Tests',
	#tag : 'Data'
}

{ #category : 'helpers' }
LLMPipelineTracerTest >> simplePipeline [
	"Create a simple test pipeline with block steps."

	^ LLMPipeline new
		  addStep: (LLMBlockStep named: 'step1' block: [ :ctx |
					   ctx output: 'hello'.
					   ctx ]);
		  addStep: (LLMBlockStep named: 'step2' block: [ :ctx |
					   ctx output: ctx output , ' world'.
					   ctx ]);
		  yourself
]

{ #category : 'tests' }
LLMPipelineTracerTest >> testBasicTracing [

	| tracer result |
	tracer := LLMPipelineTracer on: self simplePipeline.
	result := tracer runWith: Dictionary new.

	self assert: result output equals: 'hello world'.
	self assert: tracer traceCount equals: 1.
	self assert: tracer lastTrace isSuccess.
	self assert: tracer lastTrace stepCount equals: 2
]

{ #category : 'tests' }
LLMPipelineTracerTest >> testClearTraces [

	| tracer |
	tracer := LLMPipelineTracer on: self simplePipeline.
	tracer runWith: Dictionary new.
	self assert: tracer traceCount equals: 1.
	tracer clearTraces.
	self assert: tracer traceCount equals: 0
]

{ #category : 'tests' }
LLMPipelineTracerTest >> testCreation [

	| pipeline tracer |
	pipeline := self simplePipeline.
	tracer := LLMPipelineTracer on: pipeline.
	self assert: tracer pipeline identicalTo: pipeline.
	self assert: tracer traceCount equals: 0
]

{ #category : 'tests' }
LLMPipelineTracerTest >> testErrorTracing [

	| pipeline tracer |
	pipeline := LLMPipeline new
		            addStep: (LLMBlockStep named: 'failing' block: [ :ctx |
					             Error signal: 'test error' ]);
		            yourself.
	tracer := LLMPipelineTracer on: pipeline.

	[ tracer runWith: Dictionary new ]
		on: Error
		do: [ :e | "expected" ].

	self assert: tracer traceCount equals: 1.
	self assert: tracer lastTrace isError.
	self assert: tracer lastTrace errorSteps size equals: 1.
	self
		assert: tracer lastTrace errorSteps first error
		equals: 'test error'
]

{ #category : 'tests' }
LLMPipelineTracerTest >> testInputVariablesRecorded [

	| tracer vars |
	tracer := LLMPipelineTracer on: self simplePipeline.
	vars := { (#name -> 'test') } asDictionary.
	tracer runWith: vars.

	self
		assert: (tracer lastTrace inputVariables at: #name)
		equals: 'test'
]

{ #category : 'tests' }
LLMPipelineTracerTest >> testMultipleRuns [

	| tracer |
	tracer := LLMPipelineTracer on: self simplePipeline.
	tracer runWith: Dictionary new.
	tracer runWith: Dictionary new.
	tracer runWith: Dictionary new.
	self assert: tracer traceCount equals: 3.
	self assert: (tracer traces allSatisfy: [ :t | t isSuccess ])
]

{ #category : 'tests' }
LLMPipelineTracerTest >> testStepExecutionDetails [

	| tracer steps |
	tracer := LLMPipelineTracer on: self simplePipeline.
	tracer runWith: Dictionary new.

	steps := tracer lastTrace stepExecutions.
	self assert: steps first stepName equals: 'step1'.
	self assert: steps first isSuccess.
	self assert: steps first output equals: 'hello'.
	self assert: steps second stepName equals: 'step2'.
	self assert: steps second isSuccess.
	self assert: steps second output equals: 'hello world'
]

{ #category : 'tests' }
LLMPipelineTracerTest >> testStepTimingRecorded [

	| tracer steps |
	tracer := LLMPipelineTracer on: self simplePipeline.
	tracer runWith: Dictionary new.

	steps := tracer lastTrace stepExecutions.
	steps do: [ :step |
		self assert: step startTime isNotNil.
		self assert: step endTime isNotNil.
		self assert: step durationMs >= 0 ]
]

{ #category : 'tests' }
LLMPipelineTracerTest >> testTraceAnnouncement [

	| tracer announced |
	tracer := LLMPipelineTracer on: self simplePipeline.
	announced := false.
	tracer announcer
		when: LLMTraceCompletedAnnouncement
		do: [ :ann | announced := true ]
		for: self.
	tracer runWith: Dictionary new.
	self assert: announced
]

{ #category : 'tests' }
LLMPipelineTracerTest >> testTraceFinalOutput [

	| tracer |
	tracer := LLMPipelineTracer on: self simplePipeline.
	tracer runWith: Dictionary new.
	self assert: tracer lastTrace finalOutput equals: 'hello world'
]

{ #category : 'tests' }
LLMPipelineTracerTest >> testTracePipelineName [

	| pipeline tracer |
	pipeline := self simplePipeline.
	pipeline name: 'MyPipeline'.
	tracer := LLMPipelineTracer on: pipeline.
	tracer runWith: Dictionary new.
	self assert: tracer lastTrace pipelineName equals: 'MyPipeline'
]
