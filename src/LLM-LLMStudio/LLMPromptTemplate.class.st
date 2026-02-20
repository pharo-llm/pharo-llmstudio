Class {
	#name : 'LLMPromptTemplate',
	#superclass : 'Object',
	#instVars : [
		'template',
		'inputVariables',
		'partialVariables'
	],
	#category : 'LLM-LLMStudio-Prompts',
	#package : 'LLM-LLMStudio',
	#tag : 'Prompts'
}

{ #category : 'instance creation' }
LLMPromptTemplate class >> new [

	^ super new initialize
]

{ #category : 'instance creation' }
LLMPromptTemplate class >> template: aString [

	^ self new
		  template: aString;
		  yourself
]

{ #category : 'instance creation' }
LLMPromptTemplate class >> template: aString variables: aCollection [

	^ self new
		  template: aString;
		  inputVariables: aCollection;
		  yourself
]

{ #category : 'formatting' }
LLMPromptTemplate >> format: aDictionary [
	"Format the template by replacing {variable} placeholders with values."

	| result allVariables |
	allVariables := aDictionary copy.
	partialVariables keysAndValuesDo: [ :k :v |
		allVariables at: k ifAbsentPut: [ v ] ].
	self validateVariables: allVariables.
	result := template.
	allVariables keysAndValuesDo: [ :key :value |
		result := result copyReplaceAll: '{' , key , '}' with: value asString ].
	^ result
]

{ #category : 'formatting' }
LLMPromptTemplate >> formatContext: aContext [
	"Format using a pipeline context's variables."

	^ self format: aContext variables
]

{ #category : 'initialization' }
LLMPromptTemplate >> initialize [

	partialVariables := Dictionary new.
	inputVariables := #()
]

{ #category : 'accessing' }
LLMPromptTemplate >> inputVariables [
	"Return declared input variables, or auto-detect them from the template."

	inputVariables ifNotEmpty: [ ^ inputVariables ].
	^ self parseVariables
]

{ #category : 'accessing' }
LLMPromptTemplate >> inputVariables: aCollection [

	inputVariables := aCollection asArray
]

{ #category : 'private' }
LLMPromptTemplate >> parseVariables [
	"Extract variable names from {variable} placeholders in the template."

	| vars |
	vars := OrderedCollection new.
	template ifNil: [ ^ #() ].
	'{([^}]+)}' asRegex
		matchesIn: template
		do: [ :match |
			| varName |
			varName := match copyFrom: 2 to: match size - 1.
			(vars includes: varName) ifFalse: [ vars add: varName ] ].
	^ vars asArray
]

{ #category : 'formatting' }
LLMPromptTemplate >> partial: aDictionary [
	"Return a new template with some variables pre-filled."

	| newTemplate |
	newTemplate := self class template: template.
	newTemplate partialVariables: partialVariables copy.
	aDictionary keysAndValuesDo: [ :k :v |
		newTemplate partialVariables at: k put: v ].
	^ newTemplate
]

{ #category : 'accessing' }
LLMPromptTemplate >> partialVariables [

	^ partialVariables
]

{ #category : 'accessing' }
LLMPromptTemplate >> partialVariables: aDictionary [

	partialVariables := aDictionary
]

{ #category : 'printing' }
LLMPromptTemplate >> printOn: aStream [

	aStream
		nextPutAll: 'LLMPromptTemplate(';
		nextPutAll: (template
				 ifNotNil: [ template truncateTo: 40 ]
				 ifNil: [ 'empty' ]);
		nextPut: $)
]

{ #category : 'accessing' }
LLMPromptTemplate >> template [

	^ template
]

{ #category : 'accessing' }
LLMPromptTemplate >> template: aString [

	template := aString
]

{ #category : 'validating' }
LLMPromptTemplate >> validateVariables: aDictionary [
	"Verify that all required variables are present."

	self parseVariables do: [ :varName |
		(aDictionary includesKey: varName) ifFalse: [
			LLMValidationError signal:
				'Missing required variable: ' , varName ] ]
]
