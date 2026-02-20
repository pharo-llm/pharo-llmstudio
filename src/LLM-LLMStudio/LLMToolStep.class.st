Class {
	#name : 'LLMToolStep',
	#superclass : 'LLMPipelineStep',
	#instVars : [
		'registry',
		'model',
		'maxIterations'
	],
	#category : 'LLM-LLMStudio-Tools',
	#package : 'LLM-LLMStudio',
	#tag : 'Tools'
}

{ #category : 'instance creation' }
LLMToolStep class >> registry: aRegistry model: aModel [

	^ self new
		  registry: aRegistry;
		  model: aModel;
		  yourself
]

{ #category : 'instance creation' }
LLMToolStep class >> new [

	^ super new initialize
]

{ #category : 'building' }
LLMToolStep >> addTool: anLLMTool [

	registry addTool: anLLMTool.
	^ self
]

{ #category : 'initialization' }
LLMToolStep >> initialize [

	registry := LLMToolRegistry new.
	maxIterations := 10
]

{ #category : 'accessing' }
LLMToolStep >> maxIterations [

	^ maxIterations
]

{ #category : 'accessing' }
LLMToolStep >> maxIterations: anInteger [

	maxIterations := anInteger
]

{ #category : 'accessing' }
LLMToolStep >> model [

	^ model
]

{ #category : 'accessing' }
LLMToolStep >> model: aModel [

	model := aModel
]

{ #category : 'running' }
LLMToolStep >> processContext: aContext [
	"Execute a tool-using agent loop. The model can call tools iteratively
	 until it produces a final text response."

	| messages iteration response |
	messages := (aContext includesKey: #messages)
		            ifTrue: [ aContext at: #messages ]
		            ifFalse: [
			            { LLMChatMessage user: (aContext output ifNil: [
					              aContext at: #input ifAbsent: [ '' ] ]) asString } ].
	messages := messages asOrderedCollection.
	iteration := 0.

	[
	iteration := iteration + 1.
	iteration > maxIterations ifTrue: [
		LLMValidationError signal:
			'Tool step exceeded maximum iterations: '
			, maxIterations printString ].

	response := model chat: messages.
	response hasToolCalls ]
		whileTrue: [
			| toolResults |
			toolResults := response toolCalls collect: [ :tc |
				               | toolCallName toolArgs result |
				               toolCallName := tc at: 'function'
					                               ifPresent: [ :f | f at: 'name' ]
					                               ifAbsent: [ tc at: 'name' ].
				               toolArgs := tc at: 'function'
					                           ifPresent: [ :f |
						                           NeoJSONReader fromString:
							                           (f at: 'arguments' ifAbsent: [ '{}' ]) ]
					                           ifAbsent: [ tc at: 'input' ifAbsent: [ Dictionary new ] ].
				               result := registry
					                         executeTool: toolCallName
					                         withInput: toolArgs.
				               result ].

			"Add tool results back as messages"
			messages add: (LLMChatMessage assistant: (response content ifNil: [ '' ])).
			toolResults do: [ :tr |
				messages add: (LLMChatMessage role: 'tool' content: tr asString) ] ].

	aContext output: response content.
	aContext at: #response put: response.
	aContext at: #toolIterations put: iteration.
	^ aContext
]

{ #category : 'accessing' }
LLMToolStep >> registry [

	^ registry
]

{ #category : 'accessing' }
LLMToolStep >> registry: aRegistry [

	registry := aRegistry
]

{ #category : 'validating' }
LLMToolStep >> validate [

	model ifNil: [
		LLMValidationError signal: 'ToolStep requires a model' ].
	^ true
]
