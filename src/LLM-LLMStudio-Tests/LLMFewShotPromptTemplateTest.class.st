Class {
	#name : 'LLMFewShotPromptTemplateTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Prompts',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Prompts'
}

{ #category : 'tests' }
LLMFewShotPromptTemplateTest >> testBasicFewShot [

	| template result |
	template := LLMFewShotPromptTemplate new.
	template exampleTemplate: 'Input: {input}
Output: {output}'.
	template addExample: {
			(#input -> 'hello').
			(#output -> 'hola') } asDictionary.
	template addExample: {
			(#input -> 'bye').
			(#output -> 'adios') } asDictionary.
	result := template format: Dictionary new.
	self assert: (result includesSubstring: 'Input: hello').
	self assert: (result includesSubstring: 'Output: adios')
]

{ #category : 'tests' }
LLMFewShotPromptTemplateTest >> testCustomSeparator [

	| template result |
	template := LLMFewShotPromptTemplate new.
	template separator: '---'.
	template exampleTemplate: '{q} -> {a}'.
	template addExample: { (#q -> 'Q1'). (#a -> 'A1') } asDictionary.
	template addExample: { (#q -> 'Q2'). (#a -> 'A2') } asDictionary.
	result := template format: Dictionary new.
	self assert: (result includesSubstring: '---')
]

{ #category : 'tests' }
LLMFewShotPromptTemplateTest >> testExampleCount [

	| template |
	template := LLMFewShotPromptTemplate new.
	template exampleTemplate: '{x}'.
	template addExample: { (#x -> '1') } asDictionary.
	template addExample: { (#x -> '2') } asDictionary.
	template addExample: { (#x -> '3') } asDictionary.
	self assert: template examples size equals: 3
]

{ #category : 'tests' }
LLMFewShotPromptTemplateTest >> testWithPrefixAndSuffix [

	| template result |
	template := LLMFewShotPromptTemplate new.
	template prefix: 'Translate English to Spanish:'.
	template suffix: 'Input: {input}
Output:'.
	template exampleTemplate: 'Input: {input}
Output: {output}'.
	template addExample: {
			(#input -> 'hello').
			(#output -> 'hola') } asDictionary.
	result := template format: { (#input -> 'goodbye') } asDictionary.
	self assert: (result includesSubstring: 'Translate English to Spanish:').
	self assert: (result includesSubstring: 'Input: goodbye')
]
