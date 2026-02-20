Class {
	#name : 'LLMStringOutputParser',
	#superclass : 'LLMOutputParser',
	#instVars : [
		'trimWhitespace'
	],
	#category : 'LLM-LLMStudio-Parsers',
	#package : 'LLM-LLMStudio',
	#tag : 'Parsers'
}

{ #category : 'instance creation' }
LLMStringOutputParser class >> new [

	^ super new initialize
]

{ #category : 'initialization' }
LLMStringOutputParser >> initialize [

	trimWhitespace := true
]

{ #category : 'parsing' }
LLMStringOutputParser >> parse: aString [

	^ trimWhitespace
		  ifTrue: [ aString trimBoth ]
		  ifFalse: [ aString ]
]

{ #category : 'accessing' }
LLMStringOutputParser >> trimWhitespace [

	^ trimWhitespace
]

{ #category : 'accessing' }
LLMStringOutputParser >> trimWhitespace: aBoolean [

	trimWhitespace := aBoolean
]
