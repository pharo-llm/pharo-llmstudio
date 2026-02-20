Class {
	#name : 'LLMPipelineContext',
	#superclass : 'Object',
	#instVars : [
		'variables',
		'output',
		'metadata',
		'errors',
		'history'
	],
	#category : 'LLM-LLMStudio-Core',
	#package : 'LLM-LLMStudio',
	#tag : 'Core'
}

{ #category : 'instance creation' }
LLMPipelineContext class >> new [

	^ super new initialize
]

{ #category : 'instance creation' }
LLMPipelineContext class >> withVariables: aDictionary [

	^ self new
		  variables: aDictionary;
		  yourself
]

{ #category : 'accessing' }
LLMPipelineContext >> at: aKey [

	^ variables at: aKey
]

{ #category : 'accessing' }
LLMPipelineContext >> at: aKey ifAbsent: aBlock [

	^ variables at: aKey ifAbsent: aBlock
]

{ #category : 'accessing' }
LLMPipelineContext >> at: aKey ifPresent: aBlock [

	^ variables at: aKey ifPresent: aBlock
]

{ #category : 'accessing' }
LLMPipelineContext >> at: aKey put: aValue [

	variables at: aKey put: aValue.
	^ aValue
]

{ #category : 'copying' }
LLMPipelineContext >> copy [

	^ self class new
		  variables: variables copy;
		  output: output;
		  metadata: metadata copy;
		  errors: errors copy;
		  history: history copy;
		  yourself
]

{ #category : 'error handling' }
LLMPipelineContext >> addError: anError [

	errors add: anError
]

{ #category : 'accessing' }
LLMPipelineContext >> errors [

	^ errors
]

{ #category : 'testing' }
LLMPipelineContext >> hasErrors [

	^ errors isNotEmpty
]

{ #category : 'testing' }
LLMPipelineContext >> hasOutput [

	^ output isNotNil
]

{ #category : 'accessing - history' }
LLMPipelineContext >> history [

	^ history
]

{ #category : 'accessing - history' }
LLMPipelineContext >> history: aCollection [

	history := aCollection asOrderedCollection
]

{ #category : 'testing' }
LLMPipelineContext >> includesKey: aKey [

	^ variables includesKey: aKey
]

{ #category : 'initialization' }
LLMPipelineContext >> initialize [

	variables := Dictionary new.
	metadata := Dictionary new.
	errors := OrderedCollection new.
	history := OrderedCollection new
]

{ #category : 'accessing' }
LLMPipelineContext >> metadata [

	^ metadata
]

{ #category : 'accessing' }
LLMPipelineContext >> metadata: aDictionary [

	metadata := aDictionary
]

{ #category : 'accessing' }
LLMPipelineContext >> metadataAt: aKey [

	^ metadata at: aKey
]

{ #category : 'accessing' }
LLMPipelineContext >> metadataAt: aKey put: aValue [

	metadata at: aKey put: aValue
]

{ #category : 'accessing' }
LLMPipelineContext >> output [

	^ output
]

{ #category : 'accessing' }
LLMPipelineContext >> output: anObject [

	output := anObject
]

{ #category : 'printing' }
LLMPipelineContext >> printOn: aStream [

	aStream
		nextPutAll: 'LLMPipelineContext(';
		nextPutAll: 'vars: ';
		print: variables size;
		nextPutAll: ', output: ';
		print: (output isNotNil
				 ifTrue: [ output class name ]
				 ifFalse: [ 'nil' ]);
		nextPut: $)
]

{ #category : 'accessing - history' }
LLMPipelineContext >> recordStep: aStepName output: anOutput [

	history add: (Association key: aStepName value: anOutput)
]

{ #category : 'accessing' }
LLMPipelineContext >> variables [

	^ variables
]

{ #category : 'accessing' }
LLMPipelineContext >> variables: aDictionary [

	variables := aDictionary asDictionary
]
