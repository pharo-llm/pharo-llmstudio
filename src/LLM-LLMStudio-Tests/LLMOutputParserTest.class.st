Class {
	#name : 'LLMOutputParserTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Parsers',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Parsers'
}

{ #category : 'tests - string' }
LLMOutputParserTest >> testStringParserTrim [

	| parser |
	parser := LLMStringOutputParser new.
	self assert: (parser parse: '  hello world  ') equals: 'hello world'
]

{ #category : 'tests - string' }
LLMOutputParserTest >> testStringParserNoTrim [

	| parser |
	parser := LLMStringOutputParser new.
	parser trimWhitespace: false.
	self assert: (parser parse: '  hello  ') equals: '  hello  '
]

{ #category : 'tests - json' }
LLMOutputParserTest >> testJsonParser [

	| parser result |
	parser := LLMJsonOutputParser new.
	result := parser parse: '{"name": "Alice", "age": 30}'.
	self assert: (result at: 'name') equals: 'Alice'.
	self assert: (result at: 'age') equals: 30
]

{ #category : 'tests - json' }
LLMOutputParserTest >> testJsonParserWithCodeBlock [

	| parser result |
	parser := LLMJsonOutputParser new.
	result := parser parse: '```json
{"name": "Bob"}
```'.
	self assert: (result at: 'name') equals: 'Bob'
]

{ #category : 'tests - json' }
LLMOutputParserTest >> testJsonParserExtractKey [

	| parser result |
	parser := LLMJsonOutputParser extractKey: 'answer'.
	result := parser parse: '{"answer": "42", "confidence": 0.95}'.
	self assert: result equals: '42'
]

{ #category : 'tests - json' }
LLMOutputParserTest >> testJsonParserInvalidJson [

	| parser |
	parser := LLMJsonOutputParser new.
	self
		should: [ parser parse: 'not valid json' ]
		raise: LLMValidationError
]

{ #category : 'tests - json' }
LLMOutputParserTest >> testJsonParserMissingKey [

	| parser |
	parser := LLMJsonOutputParser extractKey: 'missing'.
	self
		should: [ parser parse: '{"present": "value"}' ]
		raise: LLMValidationError
]

{ #category : 'tests - regex' }
LLMOutputParserTest >> testRegexParser [

	| parser result |
	parser := LLMRegexOutputParser pattern: '\d+'.
	result := parser parse: 'The answer is 42 items'.
	self assert: result equals: '42'
]

{ #category : 'tests - regex' }
LLMOutputParserTest >> testRegexParserWithGroup [

	| parser result |
	parser := LLMRegexOutputParser pattern: 'answer: (\w+)' group: 1.
	result := parser parse: 'The answer: hello world'.
	self assert: result equals: 'hello'
]

{ #category : 'tests - regex' }
LLMOutputParserTest >> testRegexParserNoMatch [

	| parser |
	parser := LLMRegexOutputParser pattern: '\d+'.
	self
		should: [ parser parse: 'no numbers here' ]
		raise: LLMValidationError
]

{ #category : 'tests - list' }
LLMOutputParserTest >> testListParser [

	| parser result |
	parser := LLMListOutputParser new.
	result := parser parse: 'apple
banana
cherry'.
	self assert: result size equals: 3.
	self assert: result first equals: 'apple'.
	self assert: result last equals: 'cherry'
]

{ #category : 'tests - list' }
LLMOutputParserTest >> testListParserWithMarkers [

	| parser result |
	parser := LLMListOutputParser new.
	result := parser parse: '- apple
- banana
- cherry'.
	self assert: result size equals: 3.
	self assert: result first equals: 'apple'
]

{ #category : 'tests - list' }
LLMOutputParserTest >> testListParserWithNumbers [

	| parser result |
	parser := LLMListOutputParser new.
	result := parser parse: '1. first
2. second
3. third'.
	self assert: result size equals: 3.
	self assert: result first equals: 'first'
]

{ #category : 'tests - list' }
LLMOutputParserTest >> testListParserCustomSeparator [

	| parser result |
	parser := LLMListOutputParser separator: ','.
	result := parser parse: 'a, b, c'.
	self assert: result size equals: 3.
	self assert: result first equals: 'a'
]

{ #category : 'tests - list' }
LLMOutputParserTest >> testListParserRemovesEmpty [

	| parser result |
	parser := LLMListOutputParser new.
	result := parser parse: 'apple

banana

cherry'.
	self assert: result size equals: 3
]
