Class {
	#name : 'LLMToolRegistryTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Tools',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Tools'
}

{ #category : 'tests' }
LLMToolRegistryTest >> testAddAndRetrieveTools [

	| registry |
	registry := LLMToolRegistry new.
	registry addTool: (LLMTool
			 name: 'tool1'
			 description: 'First tool'
			 block: [ :x | x ]).
	registry addTool: (LLMTool
			 name: 'tool2'
			 description: 'Second tool'
			 block: [ :x | x ]).
	self assert: registry size equals: 2.
	self assert: (registry hasTool: 'tool1').
	self assert: (registry hasTool: 'tool2')
]

{ #category : 'tests' }
LLMToolRegistryTest >> testAsFunctionSchemas [

	| registry schemas |
	registry := LLMToolRegistry new.
	registry addTool: (LLMTool
			 name: 'tool1'
			 description: 'First'
			 block: [ :x | x ]).
	schemas := registry asFunctionSchemas.
	self assert: schemas size equals: 1.
	self assert: (schemas first at: 'type') equals: 'function'
]

{ #category : 'tests' }
LLMToolRegistryTest >> testExecuteNonExistentTool [

	| registry |
	registry := LLMToolRegistry new.
	self
		should: [
			registry executeTool: 'nonexistent' withInput: Dictionary new ]
		raise: LLMValidationError
]

{ #category : 'tests' }
LLMToolRegistryTest >> testExecuteTool [

	| registry result |
	registry := LLMToolRegistry new.
	registry addTool: (LLMTool
			 name: 'double'
			 description: 'Doubles a number'
			 block: [ :input | (input at: 'n') * 2 ]).
	result := registry
		          executeTool: 'double'
		          withInput: { ('n' -> 5) } asDictionary.
	self assert: result isSuccess.
	self assert: result output equals: 10
]

{ #category : 'tests' }
LLMToolRegistryTest >> testRemoveTool [

	| registry |
	registry := LLMToolRegistry new.
	registry addTool: (LLMTool
			 name: 'temp'
			 description: 'Temp'
			 block: [ :x | x ]).
	self assert: registry size equals: 1.
	registry removeTool: 'temp'.
	self assert: registry size equals: 0
]

{ #category : 'tests' }
LLMToolRegistryTest >> testToolNames [

	| registry |
	registry := LLMToolRegistry new.
	registry addTool: (LLMTool
			 name: 'alpha'
			 description: 'A'
			 block: [ :x | x ]).
	registry addTool: (LLMTool
			 name: 'beta'
			 description: 'B'
			 block: [ :x | x ]).
	self assert: registry toolNames asSet equals: #( 'alpha' 'beta' ) asSet
]
