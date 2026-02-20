Class {
	#name : 'LLMToolTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Tools',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Tools'
}

{ #category : 'tests' }
LLMToolTest >> testToolCreation [

	| tool |
	tool := LLMTool
		        name: 'calculator'
		        description: 'Performs math'
		        block: [ :input | input ].
	self assert: tool toolName equals: 'calculator'.
	self assert: tool description equals: 'Performs math'
]

{ #category : 'tests' }
LLMToolTest >> testToolExecution [

	| tool result |
	tool := LLMTool
		        name: 'add'
		        description: 'Adds two numbers'
		        block: [ :input |
			        (input at: 'a') + (input at: 'b') ].
	result := tool execute: {
			          ('a' -> 3).
			          ('b' -> 5) } asDictionary.
	self assert: result isSuccess.
	self assert: result output equals: 8
]

{ #category : 'tests' }
LLMToolTest >> testToolExecutionError [

	| tool result |
	tool := LLMTool
		        name: 'failing'
		        description: 'Always fails'
		        block: [ :input | 1 / 0 ].
	result := tool execute: Dictionary new.
	self deny: result isSuccess.
	self assert: result error isNotNil
]

{ #category : 'tests' }
LLMToolTest >> testToolAsFunctionSchema [

	| tool schema |
	tool := LLMTool
		        name: 'search'
		        description: 'Search the web'
		        block: [ :input | input ].
	tool parameters: (Dictionary new
			 at: 'type' put: 'object';
			 at: 'properties'
			 put: (Dictionary new
					  at: 'query'
					  put: (Dictionary new
							   at: 'type' put: 'string';
							   yourself);
					  yourself);
			 yourself).
	schema := tool asFunctionSchema.
	self assert: (schema at: 'type') equals: 'function'.
	self
		assert: ((schema at: 'function') at: 'name')
		equals: 'search'
]

{ #category : 'tests' }
LLMToolTest >> testToolResultAsString [

	| result |
	result := LLMToolResult tool: 'test' output: 42.
	self assert: result asString equals: '42'.

	result := LLMToolResult tool: 'test' output: nil error: 'failed'.
	self assert: result asString equals: 'Error: failed'
]
