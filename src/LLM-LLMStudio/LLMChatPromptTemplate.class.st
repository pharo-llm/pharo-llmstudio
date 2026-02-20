Class {
	#name : 'LLMChatPromptTemplate',
	#superclass : 'Object',
	#instVars : [
		'messageTemplates'
	],
	#category : 'LLM-LLMStudio-Prompts',
	#package : 'LLM-LLMStudio',
	#tag : 'Prompts'
}

{ #category : 'instance creation' }
LLMChatPromptTemplate class >> fromMessages: aCollection [
	"Create from an array of associations: { #system -> 'template'. #user -> 'template' }"

	| instance |
	instance := self new.
	aCollection do: [ :assoc |
		instance addMessageRole: assoc key asString template: assoc value ].
	^ instance
]

{ #category : 'instance creation' }
LLMChatPromptTemplate class >> new [

	^ super new initialize
]

{ #category : 'building' }
LLMChatPromptTemplate >> addAssistantMessage: aTemplateString [

	^ self addMessageRole: 'assistant' template: aTemplateString
]

{ #category : 'building' }
LLMChatPromptTemplate >> addMessageRole: aRole template: aTemplateString [

	messageTemplates add: (Association
			 key: aRole
			 value: (LLMPromptTemplate template: aTemplateString)).
	^ self
]

{ #category : 'building' }
LLMChatPromptTemplate >> addSystemMessage: aTemplateString [

	^ self addMessageRole: 'system' template: aTemplateString
]

{ #category : 'building' }
LLMChatPromptTemplate >> addUserMessage: aTemplateString [

	^ self addMessageRole: 'user' template: aTemplateString
]

{ #category : 'formatting' }
LLMChatPromptTemplate >> format: aDictionary [
	"Format all message templates and return an array of LLMChatMessage."

	^ messageTemplates collect: [ :assoc |
		  LLMChatMessage
			  role: assoc key
			  content: (assoc value format: aDictionary) ]
]

{ #category : 'formatting' }
LLMChatPromptTemplate >> formatContext: aContext [

	^ self format: aContext variables
]

{ #category : 'initialization' }
LLMChatPromptTemplate >> initialize [

	messageTemplates := OrderedCollection new
]

{ #category : 'accessing' }
LLMChatPromptTemplate >> inputVariables [
	"Collect all unique input variables from all message templates."

	| allVars |
	allVars := Set new.
	messageTemplates do: [ :assoc |
		allVars addAll: assoc value inputVariables ].
	^ allVars asArray
]

{ #category : 'accessing' }
LLMChatPromptTemplate >> messageTemplates [

	^ messageTemplates
]

{ #category : 'printing' }
LLMChatPromptTemplate >> printOn: aStream [

	aStream
		nextPutAll: 'LLMChatPromptTemplate(';
		print: messageTemplates size;
		nextPutAll: ' messages)'
]
