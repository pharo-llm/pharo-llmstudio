Class {
	#name : 'LLMToolRegistry',
	#superclass : 'Object',
	#instVars : [
		'tools'
	],
	#category : 'LLM-LLMStudio-Tools',
	#package : 'LLM-LLMStudio',
	#tag : 'Tools'
}

{ #category : 'instance creation' }
LLMToolRegistry class >> new [

	^ super new initialize
]

{ #category : 'accessing' }
LLMToolRegistry >> addTool: anLLMTool [

	tools at: anLLMTool toolName put: anLLMTool.
	^ self
]

{ #category : 'converting' }
LLMToolRegistry >> asFunctionSchemas [
	"Return all tools as an array of function calling schemas."

	^ tools values collect: [ :tool | tool asFunctionSchema ]
]

{ #category : 'running' }
LLMToolRegistry >> executeTool: aToolName withInput: anInput [
	"Find and execute a tool by name."

	| tool |
	tool := tools
		        at: aToolName
		        ifAbsent: [
			        LLMValidationError signal:
				        'Tool not found: ' , aToolName ].
	^ tool execute: anInput
]

{ #category : 'testing' }
LLMToolRegistry >> hasTool: aToolName [

	^ tools includesKey: aToolName
]

{ #category : 'initialization' }
LLMToolRegistry >> initialize [

	tools := Dictionary new
]

{ #category : 'printing' }
LLMToolRegistry >> printOn: aStream [

	aStream
		nextPutAll: 'LLMToolRegistry(';
		print: tools size;
		nextPutAll: ' tools)'
]

{ #category : 'accessing' }
LLMToolRegistry >> removeTool: aToolName [

	tools removeKey: aToolName ifAbsent: [  ]
]

{ #category : 'accessing' }
LLMToolRegistry >> size [

	^ tools size
]

{ #category : 'accessing' }
LLMToolRegistry >> toolNames [

	^ tools keys asArray
]

{ #category : 'accessing' }
LLMToolRegistry >> tools [

	^ tools values asArray
]
