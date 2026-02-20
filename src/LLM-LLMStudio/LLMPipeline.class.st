Class {
	#name : 'LLMPipeline',
	#superclass : 'LLMPipelineStep',
	#instVars : [
		'steps'
	],
	#category : 'LLM-LLMStudio-Core',
	#package : 'LLM-LLMStudio',
	#tag : 'Core'
}

{ #category : 'instance creation' }
LLMPipeline class >> new [

	^ super new initialize
]

{ #category : 'instance creation' }
LLMPipeline class >> withSteps: aCollection [

	^ self new
		  steps: aCollection asOrderedCollection;
		  yourself
]

{ #category : 'building' }
LLMPipeline >> addStep: aStep [

	steps add: aStep.
	^ self
]

{ #category : 'initialization' }
LLMPipeline >> initialize [

	steps := OrderedCollection new
]

{ #category : 'running' }
LLMPipeline >> processContext: aContext [
	"Execute all steps sequentially, passing context through each."

	| currentContext |
	currentContext := aContext.
	steps do: [ :step |
		currentContext := step processContext: currentContext.
		currentContext recordStep: step name output: currentContext output ].
	^ currentContext
]

{ #category : 'printing' }
LLMPipeline >> printOn: aStream [

	aStream
		nextPutAll: 'LLMPipeline(';
		print: steps size;
		nextPutAll: ' steps)'.
]

{ #category : 'accessing' }
LLMPipeline >> steps [

	^ steps
]

{ #category : 'accessing' }
LLMPipeline >> steps: aCollection [

	steps := aCollection asOrderedCollection
]

{ #category : 'accessing' }
LLMPipeline >> stepCount [

	^ steps size
]

{ #category : 'composing' }
LLMPipeline >> then: anotherStep [
	"Add a step to this pipeline (unlike the superclass which creates a new pipeline)."

	^ self addStep: anotherStep
]

{ #category : 'validating' }
LLMPipeline >> validate [

	steps do: [ :step | step validate ].
	^ true
]

{ #category : 'running' }
LLMPipeline >> runWith: aDictionary [
	"Run the pipeline with the given variables dictionary."

	| context |
	self validate.
	context := LLMPipelineContext withVariables: aDictionary.
	^ self processContext: context
]
