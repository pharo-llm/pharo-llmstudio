Class {
	#name : 'LLMPipelineStep',
	#superclass : 'Object',
	#instVars : [
		'name'
	],
	#category : 'LLM-LLMStudio-Core',
	#package : 'LLM-LLMStudio',
	#tag : 'Core'
}

{ #category : 'instance creation' }
LLMPipelineStep class >> named: aString [

	^ self new
		  name: aString;
		  yourself
]

{ #category : 'composing' }
LLMPipelineStep >> then: anotherStep [
	"Chain this step with another step, creating a pipeline.
	 Usage: (promptStep then: modelStep) then: parserStep"

	^ LLMPipeline new
		  addStep: self;
		  addStep: anotherStep;
		  yourself
]

{ #category : 'accessing' }
LLMPipelineStep >> name [

	^ name ifNil: [ self class name ]
]

{ #category : 'accessing' }
LLMPipelineStep >> name: aString [

	name := aString
]

{ #category : 'printing' }
LLMPipelineStep >> printOn: aStream [

	aStream
		nextPutAll: self class name;
		nextPut: $(;
		nextPutAll: self name;
		nextPut: $)
]

{ #category : 'running' }
LLMPipelineStep >> processContext: aContext [
	"Execute this step on the given context. Subclasses must override."

	^ self subclassResponsibility
]

{ #category : 'running' }
LLMPipelineStep >> runWith: aDictionary [
	"Convenience method to run this step with initial variables."

	| context |
	context := LLMPipelineContext withVariables: aDictionary.
	^ self processContext: context
]

{ #category : 'running' }
LLMPipelineStep >> runWithInput: anObject [
	"Convenience method to run with a single input value."

	| context |
	context := LLMPipelineContext new.
	context output: anObject.
	context at: #input put: anObject.
	^ self processContext: context
]

{ #category : 'validating' }
LLMPipelineStep >> validate [
	"Validate that this step is properly configured. Override in subclasses."

	^ true
]
