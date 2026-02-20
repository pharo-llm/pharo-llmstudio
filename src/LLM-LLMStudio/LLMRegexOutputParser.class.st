Class {
	#name : 'LLMRegexOutputParser',
	#superclass : 'LLMOutputParser',
	#instVars : [
		'pattern',
		'groupIndex'
	],
	#category : 'LLM-LLMStudio-Parsers',
	#package : 'LLM-LLMStudio',
	#tag : 'Parsers'
}

{ #category : 'instance creation' }
LLMRegexOutputParser class >> new [

	^ super new initialize
]

{ #category : 'instance creation' }
LLMRegexOutputParser class >> pattern: aRegexString [

	^ self new
		  pattern: aRegexString;
		  yourself
]

{ #category : 'instance creation' }
LLMRegexOutputParser class >> pattern: aRegexString group: anIndex [

	^ self new
		  pattern: aRegexString;
		  groupIndex: anIndex;
		  yourself
]

{ #category : 'accessing' }
LLMRegexOutputParser >> groupIndex [

	^ groupIndex
]

{ #category : 'accessing' }
LLMRegexOutputParser >> groupIndex: anIndex [

	groupIndex := anIndex
]

{ #category : 'initialization' }
LLMRegexOutputParser >> initialize [

	groupIndex := 0
]

{ #category : 'parsing' }
LLMRegexOutputParser >> normalizedPattern [
	"Convert common regex escapes into RxParser-compatible syntax."

	^ pattern
		copyReplaceAll: '\w' with: '[A-Za-z0-9_]';
		copyReplaceAll: '\d' with: '[0-9]';
		yourself
]

{ #category : 'parsing' }
LLMRegexOutputParser >> parse: aString [

		| matcher matches |
	matcher := self normalizedPattern asRegex.
	groupIndex > 0 ifFalse: [
		matches := matcher matchesIn: aString.
		matches ifEmpty: [
			LLMValidationError signal:
				'Regex pattern did not match any output: ' , pattern ].
		^ matches first ].
	(matcher search: aString) ifFalse: [
		LLMValidationError signal:
			'Regex pattern did not match any output: ' , pattern ].
	^ [ matcher subexpression: groupIndex ]
		on: Error
		do: [ :e |
			LLMValidationError signal:
				'Regex group extraction failed: ' , e messageText ]

]

{ #category : 'accessing' }
LLMRegexOutputParser >> pattern [

	^ pattern
]

{ #category : 'accessing' }
LLMRegexOutputParser >> pattern: aString [

	pattern := aString
]
