Class {
	#name : 'LLMPromptStep',
	#superclass : 'LLMPipelineStep',
	#instVars : [
		'promptTemplate',
		'chatPromptTemplate',
		'outputKey'
	],
	#category : 'LLM-LLMStudio-Prompts',
	#package : 'LLM-LLMStudio',
	#tag : 'Prompts'
}

{ #category : 'instance creation' }
LLMPromptStep class >> template: aString [

	^ self new
		  promptTemplate: (LLMPromptTemplate template: aString);
		  yourself
]

{ #category : 'instance creation' }
LLMPromptStep class >> chatTemplate: aChatPromptTemplate [

	^ self new
		  chatPromptTemplate: aChatPromptTemplate;
		  yourself
]

{ #category : 'accessing' }
LLMPromptStep >> chatPromptTemplate [

	^ chatPromptTemplate
]

{ #category : 'accessing' }
LLMPromptStep >> chatPromptTemplate: aChatPromptTemplate [

	chatPromptTemplate := aChatPromptTemplate
]

{ #category : 'accessing' }
LLMPromptStep >> outputKey [

	^ outputKey ifNil: [ #prompt ]
]

{ #category : 'accessing' }
LLMPromptStep >> outputKey: aSymbol [

	outputKey := aSymbol
]

{ #category : 'running' }
LLMPromptStep >> processContext: aContext [

	| formatted |
	chatPromptTemplate
		ifNotNil: [
			formatted := chatPromptTemplate formatContext: aContext.
			aContext at: #messages put: formatted.
			aContext output: formatted ]
		ifNil: [
			formatted := promptTemplate formatContext: aContext.
			aContext at: self outputKey put: formatted.
			aContext output: formatted ].
	^ aContext
]

{ #category : 'accessing' }
LLMPromptStep >> promptTemplate [

	^ promptTemplate
]

{ #category : 'accessing' }
LLMPromptStep >> promptTemplate: aLLMPromptTemplate [

	promptTemplate := aLLMPromptTemplate
]

{ #category : 'validating' }
LLMPromptStep >> validate [

	(promptTemplate isNil and: [ chatPromptTemplate isNil ]) ifTrue: [
		LLMValidationError signal:
			'PromptStep requires either a promptTemplate or chatPromptTemplate' ].
	^ true
]
