Class {
	#name : 'LLMMemoryStep',
	#superclass : 'LLMPipelineStep',
	#instVars : [
		'memory',
		'inputKey',
		'recordOutput'
	],
	#category : 'LLM-LLMStudio-Memory',
	#package : 'LLM-LLMStudio',
	#tag : 'Memory'
}

{ #category : 'instance creation' }
LLMMemoryStep class >> memory: aMemory [

	^ self new
		  memory: aMemory;
		  yourself
]

{ #category : 'instance creation' }
LLMMemoryStep class >> new [

	^ super new initialize
]

{ #category : 'initialization' }
LLMMemoryStep >> initialize [

	recordOutput := true
]

{ #category : 'accessing' }
LLMMemoryStep >> inputKey [

	^ inputKey ifNil: [ #input ]
]

{ #category : 'accessing' }
LLMMemoryStep >> inputKey: aSymbol [

	inputKey := aSymbol
]

{ #category : 'accessing' }
LLMMemoryStep >> memory [

	^ memory
]

{ #category : 'accessing' }
LLMMemoryStep >> memory: aMemory [

	memory := aMemory
]

{ #category : 'running' }
LLMMemoryStep >> processContext: aContext [
	"Inject memory messages into context and optionally record new input/output."

	| userInput |
	"Record the user input into memory"
	userInput := aContext at: self inputKey ifAbsent: [ aContext output ].
	userInput ifNotNil: [
		memory addUserMessage: userInput asString ].

	"Set the messages from memory into context for the model step"
	aContext at: #messages put: memory messages.
	^ aContext
]

{ #category : 'running' }
LLMMemoryStep >> recordAssistantOutput: aContext [
	"Record the assistant's output into memory. Call this after the model step."

	recordOutput ifTrue: [
		aContext output ifNotNil: [ :out |
			memory addAssistantMessage: out asString ] ]
]

{ #category : 'accessing' }
LLMMemoryStep >> recordOutput [

	^ recordOutput
]

{ #category : 'accessing' }
LLMMemoryStep >> recordOutput: aBoolean [

	recordOutput := aBoolean
]

{ #category : 'validating' }
LLMMemoryStep >> validate [

	memory ifNil: [
		LLMValidationError signal: 'MemoryStep requires a memory' ].
	^ true
]
