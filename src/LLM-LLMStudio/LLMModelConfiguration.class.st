Class {
	#name : 'LLMModelConfiguration',
	#superclass : 'Object',
	#instVars : [
		'temperature',
		'maxTokens',
		'topP',
		'stopSequences',
		'frequencyPenalty',
		'presencePenalty',
		'seed',
		'extraParameters'
	],
	#category : 'LLM-LLMStudio-Models',
	#package : 'LLM-LLMStudio',
	#tag : 'Models'
}

{ #category : 'instance creation' }
LLMModelConfiguration class >> creative [

	^ self new
		  temperature: 0.9;
		  topP: 0.95;
		  yourself
]

{ #category : 'instance creation' }
LLMModelConfiguration class >> default [

	^ self new
]

{ #category : 'instance creation' }
LLMModelConfiguration class >> new [

	^ super new initialize
]

{ #category : 'instance creation' }
LLMModelConfiguration class >> precise [

	^ self new
		  temperature: 0.1;
		  topP: 0.1;
		  yourself
]

{ #category : 'converting' }
LLMModelConfiguration >> asDictionary [
	"Return parameters as a dictionary suitable for API requests."

	| dict |
	dict := Dictionary new.
	temperature ifNotNil: [ :v | dict at: 'temperature' put: v ].
	maxTokens ifNotNil: [ :v | dict at: 'max_tokens' put: v ].
	topP ifNotNil: [ :v | dict at: 'top_p' put: v ].
	(stopSequences isNotNil and: [ stopSequences isNotEmpty ])
		ifTrue: [ dict at: 'stop' put: stopSequences asArray ].
	frequencyPenalty ifNotNil: [ :v | dict at: 'frequency_penalty' put: v ].
	presencePenalty ifNotNil: [ :v | dict at: 'presence_penalty' put: v ].
	seed ifNotNil: [ :v | dict at: 'seed' put: v ].
	extraParameters ifNotNil: [
		extraParameters keysAndValuesDo: [ :k :v | dict at: k put: v ] ].
	^ dict
]

{ #category : 'accessing' }
LLMModelConfiguration >> extraParameterAt: aKey put: aValue [

	extraParameters at: aKey put: aValue
]

{ #category : 'accessing' }
LLMModelConfiguration >> extraParameters [

	^ extraParameters
]

{ #category : 'accessing' }
LLMModelConfiguration >> frequencyPenalty [

	^ frequencyPenalty
]

{ #category : 'accessing' }
LLMModelConfiguration >> frequencyPenalty: aNumber [

	frequencyPenalty := aNumber
]

{ #category : 'initialization' }
LLMModelConfiguration >> initialize [

	temperature := 0.7.
	maxTokens := 1024.
	stopSequences := #().
	extraParameters := Dictionary new
]

{ #category : 'accessing' }
LLMModelConfiguration >> maxTokens [

	^ maxTokens
]

{ #category : 'accessing' }
LLMModelConfiguration >> maxTokens: anInteger [

	maxTokens := anInteger
]

{ #category : 'accessing' }
LLMModelConfiguration >> presencePenalty [

	^ presencePenalty
]

{ #category : 'accessing' }
LLMModelConfiguration >> presencePenalty: aNumber [

	presencePenalty := aNumber
]

{ #category : 'printing' }
LLMModelConfiguration >> printOn: aStream [

	aStream
		nextPutAll: 'LLMModelConfiguration(temp: ';
		print: temperature;
		nextPutAll: ', maxTokens: ';
		print: maxTokens;
		nextPut: $)
]

{ #category : 'accessing' }
LLMModelConfiguration >> seed [

	^ seed
]

{ #category : 'accessing' }
LLMModelConfiguration >> seed: anInteger [

	seed := anInteger
]

{ #category : 'accessing' }
LLMModelConfiguration >> stopSequences [

	^ stopSequences
]

{ #category : 'accessing' }
LLMModelConfiguration >> stopSequences: aCollection [

	stopSequences := aCollection asArray
]

{ #category : 'accessing' }
LLMModelConfiguration >> temperature [

	^ temperature
]

{ #category : 'accessing' }
LLMModelConfiguration >> temperature: aNumber [

	temperature := aNumber
]

{ #category : 'accessing' }
LLMModelConfiguration >> topP [

	^ topP
]

{ #category : 'accessing' }
LLMModelConfiguration >> topP: aNumber [

	topP := aNumber
]
