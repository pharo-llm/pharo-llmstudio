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

{ #category : 'instance creation' }
LLMRegexOutputParser class >> new [

	^ super new initialize
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
LLMRegexOutputParser >> parse: aString [

	| regex |
	regex := pattern asRegex.
	(regex matchesIn: aString) ifEmpty: [
		LLMValidationError signal:
			'Regex pattern did not match any output: ' , pattern ].
	regex search: aString.
	^ groupIndex > 0
		  ifTrue: [ regex subexpression: groupIndex + 1 ]
		  ifFalse: [ regex match ]
]

{ #category : 'accessing' }
LLMRegexOutputParser >> pattern [

	^ pattern
]

{ #category : 'accessing' }
LLMRegexOutputParser >> pattern: aString [

	pattern := aString
]
