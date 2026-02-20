Class {
	#name : 'LLMPipelineContextTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Core',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Core'
}

{ #category : 'tests' }
LLMPipelineContextTest >> testAtIfAbsent [

	| ctx |
	ctx := LLMPipelineContext new.
	self assert: (ctx at: #missing ifAbsent: [ 'default' ]) equals: 'default'
]

{ #category : 'tests' }
LLMPipelineContextTest >> testAtIfPresent [

	| ctx result |
	ctx := LLMPipelineContext new.
	ctx at: #key put: 'value'.
	result := ctx at: #key ifPresent: [ :v | v , '!' ].
	self assert: result equals: 'value!'
]

{ #category : 'tests' }
LLMPipelineContextTest >> testCopy [

	| ctx copy |
	ctx := LLMPipelineContext new.
	ctx at: #key put: 'value'.
	ctx output: 'output'.
	copy := ctx copy.
	copy at: #key put: 'modified'.
	self assert: (ctx at: #key) equals: 'value'.
	self assert: (copy at: #key) equals: 'modified'
]

{ #category : 'tests' }
LLMPipelineContextTest >> testCreateEmpty [

	| ctx |
	ctx := LLMPipelineContext new.
	self assert: ctx variables isEmpty.
	self deny: ctx hasOutput.
	self deny: ctx hasErrors
]

{ #category : 'tests' }
LLMPipelineContextTest >> testCreateWithVariables [

	| ctx |
	ctx := LLMPipelineContext withVariables: {
			       (#name -> 'Alice').
			       (#age -> 30) } asDictionary.
	self assert: (ctx at: #name) equals: 'Alice'.
	self assert: (ctx at: #age) equals: 30
]

{ #category : 'tests' }
LLMPipelineContextTest >> testErrors [

	| ctx |
	ctx := LLMPipelineContext new.
	self deny: ctx hasErrors.
	ctx addError: (Error new messageText: 'test error').
	self assert: ctx hasErrors.
	self assert: ctx errors size equals: 1
]

{ #category : 'tests' }
LLMPipelineContextTest >> testHistory [

	| ctx |
	ctx := LLMPipelineContext new.
	ctx recordStep: 'step1' output: 'result1'.
	ctx recordStep: 'step2' output: 'result2'.
	self assert: ctx history size equals: 2.
	self assert: ctx history first key equals: 'step1'.
	self assert: ctx history first value equals: 'result1'
]

{ #category : 'tests' }
LLMPipelineContextTest >> testMetadata [

	| ctx |
	ctx := LLMPipelineContext new.
	ctx metadataAt: #startTime put: '12:00'.
	self assert: (ctx metadataAt: #startTime) equals: '12:00'
]

{ #category : 'tests' }
LLMPipelineContextTest >> testOutput [

	| ctx |
	ctx := LLMPipelineContext new.
	self deny: ctx hasOutput.
	ctx output: 'hello'.
	self assert: ctx hasOutput.
	self assert: ctx output equals: 'hello'
]

{ #category : 'tests' }
LLMPipelineContextTest >> testSetAndGetVariables [

	| ctx |
	ctx := LLMPipelineContext new.
	ctx at: #key put: 'value'.
	self assert: (ctx at: #key) equals: 'value'.
	self assert: (ctx includesKey: #key)
]
