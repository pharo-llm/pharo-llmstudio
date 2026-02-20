Class {
	#name : 'LLMParserStep',
	#superclass : 'LLMPipelineStep',
	#instVars : [
		'parser',
		'outputKey'
	],
	#category : 'LLM-LLMStudio-Parsers',
	#package : 'LLM-LLMStudio',
	#tag : 'Parsers'
}

{ #category : 'instance creation' }
LLMParserStep class >> parser: aParser [

	^ self new
		  parser: aParser;
		  yourself
]

{ #category : 'accessing' }
LLMParserStep >> outputKey [

	^ outputKey ifNil: [ #parsed ]
]

{ #category : 'accessing' }
LLMParserStep >> outputKey: aSymbol [

	outputKey := aSymbol
]

{ #category : 'accessing' }
LLMParserStep >> parser [

	^ parser
]

{ #category : 'accessing' }
LLMParserStep >> parser: aParser [

	parser := aParser
]

{ #category : 'running' }
LLMParserStep >> processContext: aContext [

	| input parsed |
	input := aContext output ifNil: [
		         LLMValidationError signal:
			         'ParserStep: no output to parse from previous step' ].
	parsed := input isString
		          ifTrue: [ parser parse: input ]
		          ifFalse: [
			          (input isKindOf: LLMResponse)
				          ifTrue: [ parser parseResponse: input ]
				          ifFalse: [ parser parse: input asString ] ].
	aContext at: self outputKey put: parsed.
	aContext output: parsed.
	^ aContext
]

{ #category : 'validating' }
LLMParserStep >> validate [

	parser ifNil: [
		LLMValidationError signal: 'ParserStep requires a parser' ].
	^ true
]
