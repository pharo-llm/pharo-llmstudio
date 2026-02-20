Class {
	#name : 'LLMFewShotPromptTemplate',
	#superclass : 'Object',
	#instVars : [
		'exampleTemplate',
		'examples',
		'prefix',
		'suffix',
		'separator'
	],
	#category : 'LLM-LLMStudio-Prompts',
	#package : 'LLM-LLMStudio',
	#tag : 'Prompts'
}

{ #category : 'instance creation' }
LLMFewShotPromptTemplate class >> new [

	^ super new initialize
]

{ #category : 'instance creation' }
LLMFewShotPromptTemplate class >> exampleTemplate: aTemplate examples: aCollection [

	^ self new
		  exampleTemplate: aTemplate;
		  examples: aCollection;
		  yourself
]

{ #category : 'building' }
LLMFewShotPromptTemplate >> addExample: aDictionary [

	examples add: aDictionary.
	^ self
]

{ #category : 'accessing' }
LLMFewShotPromptTemplate >> exampleTemplate [

	^ exampleTemplate
]

{ #category : 'accessing' }
LLMFewShotPromptTemplate >> exampleTemplate: aLLMPromptTemplate [

	exampleTemplate := aLLMPromptTemplate isString
		                   ifTrue: [ LLMPromptTemplate template: aLLMPromptTemplate ]
		                   ifFalse: [ aLLMPromptTemplate ]
]

{ #category : 'accessing' }
LLMFewShotPromptTemplate >> examples [

	^ examples
]

{ #category : 'accessing' }
LLMFewShotPromptTemplate >> examples: aCollection [

	examples := aCollection asOrderedCollection
]

{ #category : 'formatting' }
LLMFewShotPromptTemplate >> format: aDictionary [
	"Format the few-shot prompt with prefix, examples, and suffix."

	| parts formattedExamples |
	formattedExamples := examples collect: [ :example |
		                     exampleTemplate format: example ].
	parts := OrderedCollection new.
	prefix ifNotNil: [ :p |
		parts add: (LLMPromptTemplate template: p) format: aDictionary ].
	parts addAll: formattedExamples.
	suffix ifNotNil: [ :s |
		parts add: (LLMPromptTemplate template: s) format: aDictionary ].
	^ separator join: parts
]

{ #category : 'initialization' }
LLMFewShotPromptTemplate >> initialize [

	examples := OrderedCollection new.
	separator := String cr , String cr.
	prefix := nil.
	suffix := nil
]

{ #category : 'accessing' }
LLMFewShotPromptTemplate >> prefix [

	^ prefix
]

{ #category : 'accessing' }
LLMFewShotPromptTemplate >> prefix: aString [

	prefix := aString
]

{ #category : 'printing' }
LLMFewShotPromptTemplate >> printOn: aStream [

	aStream
		nextPutAll: 'LLMFewShotPromptTemplate(';
		print: examples size;
		nextPutAll: ' examples)'
]

{ #category : 'accessing' }
LLMFewShotPromptTemplate >> separator [

	^ separator
]

{ #category : 'accessing' }
LLMFewShotPromptTemplate >> separator: aString [

	separator := aString
]

{ #category : 'accessing' }
LLMFewShotPromptTemplate >> suffix [

	^ suffix
]

{ #category : 'accessing' }
LLMFewShotPromptTemplate >> suffix: aString [

	suffix := aString
]
