Class {
	#name : 'LLMJsonOutputParser',
	#superclass : 'LLMOutputParser',
	#instVars : [
		'extractKey'
	],
	#category : 'LLM-LLMStudio-Parsers',
	#package : 'LLM-LLMStudio',
	#tag : 'Parsers'
}

{ #category : 'instance creation' }
LLMJsonOutputParser class >> extractKey: aKey [
	"Create a parser that extracts a specific key from the parsed JSON."

	^ self new
		  extractKey: aKey;
		  yourself
]

{ #category : 'accessing' }
LLMJsonOutputParser >> extractKey [

	^ extractKey
]

{ #category : 'accessing' }
LLMJsonOutputParser >> extractKey: aKey [

	extractKey := aKey
]

{ #category : 'parsing' }
LLMJsonOutputParser >> parse: aString [
	"Parse JSON from the LLM output. Handles markdown code blocks."

	| jsonString parsed |
	jsonString := self stripCodeBlock: aString.
	[ parsed := NeoJSONReader fromString: jsonString ]
		on: Error
		do: [ :e |
			LLMValidationError signal:
				'Failed to parse JSON output: ' , e messageText ].
	extractKey ifNotNil: [ :key |
		^ parsed at: key ifAbsent: [
			  LLMValidationError signal:
				  'Key not found in JSON output: ' , key ] ].
	^ parsed
]

{ #category : 'private' }
LLMJsonOutputParser >> stripCodeBlock: aString [
	"Remove markdown code block markers if present."

	| trimmed |
	trimmed := aString trimBoth.
	(trimmed beginsWith: '```json') ifTrue: [
		trimmed := trimmed allButFirst: 7 ].
	(trimmed beginsWith: '```') ifTrue: [
		trimmed := trimmed allButFirst: 3 ].
	(trimmed endsWith: '```') ifTrue: [
		trimmed := trimmed allButLast: 3 ].
	^ trimmed trimBoth
]
