Class {
	#name : 'LLMTool',
	#superclass : 'Object',
	#instVars : [
		'toolName',
		'description',
		'parameters',
		'executionBlock'
	],
	#category : 'LLM-LLMStudio-Tools',
	#package : 'LLM-LLMStudio',
	#tag : 'Tools'
}

{ #category : 'instance creation' }
LLMTool class >> name: aName description: aDescription block: aBlock [

	^ self new
		  toolName: aName;
		  description: aDescription;
		  executionBlock: aBlock;
		  yourself
]

{ #category : 'instance creation' }
LLMTool class >> name: aName description: aDescription parameters: aParameterSpec block: aBlock [

	^ self new
		  toolName: aName;
		  description: aDescription;
		  parameters: aParameterSpec;
		  executionBlock: aBlock;
		  yourself
]

{ #category : 'instance creation' }
LLMTool class >> new [

	^ super new initialize
]

{ #category : 'converting' }
LLMTool >> asFunctionSchema [
	"Convert to OpenAI-compatible function calling schema."

	| schema |
	schema := Dictionary new.
	schema at: 'type' put: 'function'.
	schema at: 'function' put: (Dictionary new
			 at: 'name' put: toolName;
			 at: 'description' put: description;
			 yourself).
	parameters ifNotNil: [ :p |
		(schema at: 'function') at: 'parameters' put: p ].
	^ schema
]

{ #category : 'accessing' }
LLMTool >> description [

	^ description
]

{ #category : 'accessing' }
LLMTool >> description: aString [

	description := aString
]

{ #category : 'running' }
LLMTool >> execute: anInput [
	"Execute the tool with the given input and return a result."

	| result |
	[ result := executionBlock value: anInput ]
		on: Error
		do: [ :e |
			^ LLMToolResult
				  tool: toolName
				  output: nil
				  error: e messageText ].
	^ LLMToolResult tool: toolName output: result
]

{ #category : 'accessing' }
LLMTool >> executionBlock [

	^ executionBlock
]

{ #category : 'accessing' }
LLMTool >> executionBlock: aBlock [

	executionBlock := aBlock
]

{ #category : 'initialization' }
LLMTool >> initialize [

	parameters := nil
]

{ #category : 'accessing' }
LLMTool >> parameters [

	^ parameters
]

{ #category : 'accessing' }
LLMTool >> parameters: aDictionary [
	"Set the JSON Schema for tool parameters."

	parameters := aDictionary
]

{ #category : 'printing' }
LLMTool >> printOn: aStream [

	aStream
		nextPutAll: 'LLMTool(';
		nextPutAll: (toolName ifNil: [ 'unnamed' ]);
		nextPut: $)
]

{ #category : 'accessing' }
LLMTool >> toolName [

	^ toolName
]

{ #category : 'accessing' }
LLMTool >> toolName: aString [

	toolName := aString
]
