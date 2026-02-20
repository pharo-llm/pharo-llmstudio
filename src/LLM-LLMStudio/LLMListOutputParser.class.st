Class {
	#name : 'LLMListOutputParser',
	#superclass : 'LLMOutputParser',
	#instVars : [
		'separator',
		'trimItems',
		'removeEmpty'
	],
	#category : 'LLM-LLMStudio-Parsers',
	#package : 'LLM-LLMStudio',
	#tag : 'Parsers'
}

{ #category : 'instance creation' }
LLMListOutputParser class >> new [

	^ super new initialize
]

{ #category : 'instance creation' }
LLMListOutputParser class >> separator: aString [

	^ self new
		  separator: aString;
		  yourself
]

{ #category : 'initialization' }
LLMListOutputParser >> initialize [

	separator := String cr.
	trimItems := true.
	removeEmpty := true
]

{ #category : 'parsing' }
LLMListOutputParser >> parse: aString [

	| items |
	items := separator split: aString.
	trimItems ifTrue: [
		items := items collect: [ :item | item trimBoth ] ].
	removeEmpty ifTrue: [
		items := items reject: [ :item | item isEmpty ] ].
	"Remove common list markers (-, *, 1., etc.)"
	items := items collect: [ :item | self stripListMarker: item ].
	^ items asArray
]

{ #category : 'accessing' }
LLMListOutputParser >> removeEmpty [

	^ removeEmpty
]

{ #category : 'accessing' }
LLMListOutputParser >> removeEmpty: aBoolean [

	removeEmpty := aBoolean
]

{ #category : 'accessing' }
LLMListOutputParser >> separator [

	^ separator
]

{ #category : 'accessing' }
LLMListOutputParser >> separator: aString [

	separator := aString
]

{ #category : 'private' }
LLMListOutputParser >> stripListMarker: aString [
	"Remove common list markers like '- ', '* ', '1. ' from the beginning."

	| trimmed |
	trimmed := aString.
	(trimmed matchesRegex: '^\d+\.\s+.*') ifTrue: [
		^ (trimmed copyAfter: $.) trimLeft ].
	(trimmed matchesRegex: '^[-*]\s+.*') ifTrue: [
		^ (trimmed allButFirst: 1) trimLeft ].
	^ trimmed
]

{ #category : 'accessing' }
LLMListOutputParser >> trimItems [

	^ trimItems
]

{ #category : 'accessing' }
LLMListOutputParser >> trimItems: aBoolean [

	trimItems := aBoolean
]
