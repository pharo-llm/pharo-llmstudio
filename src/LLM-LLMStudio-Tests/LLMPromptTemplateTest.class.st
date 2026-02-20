Class {
	#name : 'LLMPromptTemplateTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Prompts',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Prompts'
}

{ #category : 'tests' }
LLMPromptTemplateTest >> testDuplicateVariables [

	| template |
	template := LLMPromptTemplate template: '{x} and {x}'.
	self assert: template inputVariables equals: #( 'x' )
]

{ #category : 'tests' }
LLMPromptTemplateTest >> testEmptyTemplate [

	| template |
	template := LLMPromptTemplate template: ''.
	self assert: template inputVariables isEmpty.
	self assert: (template format: Dictionary new) equals: ''
]

{ #category : 'tests' }
LLMPromptTemplateTest >> testFormatContext [

	| template ctx result |
	template := LLMPromptTemplate template: 'Hello {name}'.
	ctx := LLMPipelineContext withVariables: { (#name -> 'Alice') } asDictionary.
	result := template formatContext: ctx.
	self assert: result equals: 'Hello Alice'
]

{ #category : 'tests' }
LLMPromptTemplateTest >> testMissingVariableRaisesError [

	| template |
	template := LLMPromptTemplate template: 'Hello {name}!'.
	self
		should: [ template format: Dictionary new ]
		raise: LLMValidationError
]

{ #category : 'tests' }
LLMPromptTemplateTest >> testMultipleVariables [

	| template result |
	template := LLMPromptTemplate template: 'Translate "{text}" to {language}'.
	result := template format: {
			          (#text -> 'Hello').
			          (#language -> 'French') } asDictionary.
	self assert: result equals: 'Translate "Hello" to French'
]

{ #category : 'tests' }
LLMPromptTemplateTest >> testNoVariables [

	| template result |
	template := LLMPromptTemplate template: 'Hello World!'.
	result := template format: Dictionary new.
	self assert: result equals: 'Hello World!'
]

{ #category : 'tests' }
LLMPromptTemplateTest >> testParseVariables [

	| template |
	template := LLMPromptTemplate template: 'Hello {name}, you are {age} years old'.
	self assert: template inputVariables asSet equals: #( 'name' 'age' ) asSet
]

{ #category : 'tests' }
LLMPromptTemplateTest >> testPartialVariables [

	| template result |
	template := LLMPromptTemplate template: '{greeting} {name}!'.
	template := template partial: { (#greeting -> 'Hello') } asDictionary.
	result := template format: { (#name -> 'World') } asDictionary.
	self assert: result equals: 'Hello World!'
]

{ #category : 'tests' }
LLMPromptTemplateTest >> testSimpleFormat [

	| template result |
	template := LLMPromptTemplate template: 'Hello {name}!'.
	result := template format: { (#name -> 'World') } asDictionary.
	self assert: result equals: 'Hello World!'
]
