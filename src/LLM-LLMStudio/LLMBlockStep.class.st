Class {
	#name : 'LLMBlockStep',
	#superclass : 'LLMPipelineStep',
	#instVars : [
		'block'
	],
	#category : 'LLM-LLMStudio-Core',
	#package : 'LLM-LLMStudio',
	#tag : 'Core'
}

{ #category : 'instance creation' }
LLMBlockStep class >> block: aBlock [

	^ self new
		  block: aBlock;
		  yourself
]

{ #category : 'instance creation' }
LLMBlockStep class >> named: aName block: aBlock [

	^ self new
		  name: aName;
		  block: aBlock;
		  yourself
]

{ #category : 'accessing' }
LLMBlockStep >> block [

	^ block
]

{ #category : 'accessing' }
LLMBlockStep >> block: aBlock [

	block := aBlock
]

{ #category : 'running' }
LLMBlockStep >> processContext: aContext [

	| result |
	result := block value: aContext.
	result class = LLMPipelineContext
		ifTrue: [ ^ result ]
		ifFalse: [
			aContext output: result.
			^ aContext ]
]

{ #category : 'validating' }
LLMBlockStep >> validate [

	block ifNil: [ LLMValidationError signal: 'BlockStep requires a block' ].
	^ true
]
