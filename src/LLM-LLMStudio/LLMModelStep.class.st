Class {
	#name : 'LLMModelStep',
	#superclass : 'LLMPipelineStep',
	#instVars : [
		'model',
		'inputKey',
		'outputKey'
	],
	#category : 'LLM-LLMStudio-Models',
	#package : 'LLM-LLMStudio',
	#tag : 'Models'
}

{ #category : 'instance creation' }
LLMModelStep class >> model: aModel [

	^ self new
		  model: aModel;
		  yourself
]

{ #category : 'accessing' }
LLMModelStep >> inputKey [

	^ inputKey ifNil: [ #prompt ]
]

{ #category : 'accessing' }
LLMModelStep >> inputKey: aSymbol [

	inputKey := aSymbol
]

{ #category : 'accessing' }
LLMModelStep >> model [

	^ model
]

{ #category : 'accessing' }
LLMModelStep >> model: aModel [

	model := aModel
]

{ #category : 'accessing' }
LLMModelStep >> outputKey [

	^ outputKey ifNil: [ #response ]
]

{ #category : 'accessing' }
LLMModelStep >> outputKey: aSymbol [

	outputKey := aSymbol
]

{ #category : 'running' }
LLMModelStep >> processContext: aContext [

	| input response messages |
	"Determine input: either pre-built messages or a text prompt"
	(aContext includesKey: #messages)
		ifTrue: [ messages := aContext at: #messages ]
		ifFalse: [
			input := aContext at: self inputKey ifAbsent: [
				         aContext output ifNil: [
					         LLMValidationError signal:
						         'ModelStep: no input found. Set ' , self inputKey
						         , ' in context or provide output from previous step.' ] ].
			messages := input isArray
				            ifTrue: [ input ]
				            ifFalse: [ { LLMChatMessage user: input asString } ] ].
	response := model chat: messages.
	aContext at: self outputKey put: response.
	aContext output: response content.
	^ aContext
]

{ #category : 'validating' }
LLMModelStep >> validate [

	model ifNil: [
		LLMValidationError signal: 'ModelStep requires a model' ].
	^ true
]
