Class {
	#name : 'LLMPipelineTracer',
	#superclass : 'Object',
	#instVars : [
		'pipeline',
		'traces',
		'currentTrace',
		'announcer'
	],
	#category : 'LLM-LLMStudio-Visualizer-Data',
	#package : 'LLM-LLMStudio-Visualizer',
	#tag : 'Data'
}

{ #category : 'instance creation' }
LLMPipelineTracer class >> new [

	^ super new initialize
]

{ #category : 'instance creation' }
LLMPipelineTracer class >> on: aPipeline [

	^ self new
		  pipeline: aPipeline;
		  yourself
]

{ #category : 'accessing' }
LLMPipelineTracer >> announcer [
	"Announcer for live update notifications to the UI."

	^ announcer
]

{ #category : 'accessing' }
LLMPipelineTracer >> clearTraces [

	traces removeAll.
	currentTrace := nil
]

{ #category : 'accessing' }
LLMPipelineTracer >> currentTrace [

	^ currentTrace
]

{ #category : 'initialization' }
LLMPipelineTracer >> initialize [

	traces := OrderedCollection new.
	announcer := Announcer new
]

{ #category : 'accessing' }
LLMPipelineTracer >> lastTrace [

	^ traces ifEmpty: [ nil ] ifNotEmpty: [ traces last ]
]

{ #category : 'ui' }
LLMPipelineTracer >> openDashboard [
	"Open the visual dashboard on this tracer."

	^ LLMDashboardPresenter openOn: self
]

{ #category : 'accessing' }
LLMPipelineTracer >> pipeline [

	^ pipeline
]

{ #category : 'accessing' }
LLMPipelineTracer >> pipeline: aPipeline [

	pipeline := aPipeline
]

{ #category : 'printing' }
LLMPipelineTracer >> printOn: aStream [

	aStream
		nextPutAll: 'LLMPipelineTracer(';
		print: traces size;
		nextPutAll: ' traces)'
]

{ #category : 'running' }
LLMPipelineTracer >> runWith: aDictionary [
	"Run the pipeline with tracing. Records all step executions."

	| context |
	pipeline ifNil: [
		LLMValidationError signal: 'No pipeline configured. Create one first.' ].
	pipeline validate.
	context := LLMPipelineContext withVariables: aDictionary.
	currentTrace := LLMExecutionTrace pipelineName: pipeline name.
	currentTrace inputVariables: aDictionary copy.
	currentTrace markStarted.

	[
		self traceSteps: pipeline steps context: context.
		currentTrace finalOutput: context output.
		currentTrace markSuccess ]
		on: Error
		do: [ :err |
			currentTrace markError.
			currentTrace finalOutput: err messageText.
			err pass ].

	traces add: currentTrace.
	announcer announce: (LLMTraceCompletedAnnouncement new trace: currentTrace).
	^ context
]

{ #category : 'accessing' }
LLMPipelineTracer >> traceCount [

	^ traces size
]

{ #category : 'private' }
LLMPipelineTracer >> traceStep: aStep context: aContext [
	"Execute a single step with tracing."

	| execution response |
	execution := LLMStepExecution
		             stepName: aStep name
		             className: aStep class name.
	execution input: (aContext output ifNil: [
			 aContext variables printString ]).
	execution markStarted.

	[
		aStep processContext: aContext.
		aContext recordStep: aStep name output: aContext output.
		execution output: aContext output.

		"Capture token usage from model responses"
		response := aContext at: #response ifAbsent: [ nil ].
		execution recordTokenUsage: response.

		"Capture messages for conversation view"
		(aContext includesKey: #messages) ifTrue: [
			(aContext at: #messages) do: [ :msg |
				currentTrace addMessage: msg ] ].

		execution markSuccess ]
		on: Error
		do: [ :err |
			execution markError: err.
			execution output: err messageText.
			currentTrace addStepExecution: execution.
			err pass ].

	currentTrace addStepExecution: execution.
	announcer announce:
		(LLMStepCompletedAnnouncement new stepExecution: execution).
	^ aContext
]

{ #category : 'private' }
LLMPipelineTracer >> traceSteps: steps context: aContext [
	"Execute a collection of steps with tracing."

	steps do: [ :step | self traceStep: step context: aContext ]
]

{ #category : 'accessing' }
LLMPipelineTracer >> traces [

	^ traces
]
