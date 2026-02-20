Class {
	#name : 'LLMToolResult',
	#superclass : 'Object',
	#instVars : [
		'toolName',
		'output',
		'error'
	],
	#category : 'LLM-LLMStudio-Tools',
	#package : 'LLM-LLMStudio',
	#tag : 'Tools'
}

{ #category : 'instance creation' }
LLMToolResult class >> tool: aName output: anOutput [

	^ self new
		  toolName: aName;
		  output: anOutput;
		  yourself
]

{ #category : 'instance creation' }
LLMToolResult class >> tool: aName output: anOutput error: anError [

	^ self new
		  toolName: aName;
		  output: anOutput;
		  error: anError;
		  yourself
]

{ #category : 'converting' }
LLMToolResult >> asString [

	^ self isSuccess
		  ifTrue: [ output asString ]
		  ifFalse: [ 'Error: ' , error asString ]
]

{ #category : 'accessing' }
LLMToolResult >> error [

	^ error
]

{ #category : 'accessing' }
LLMToolResult >> error: aString [

	error := aString
]

{ #category : 'testing' }
LLMToolResult >> isSuccess [

	^ error isNil
]

{ #category : 'accessing' }
LLMToolResult >> output [

	^ output
]

{ #category : 'accessing' }
LLMToolResult >> output: anObject [

	output := anObject
]

{ #category : 'printing' }
LLMToolResult >> printOn: aStream [

	aStream
		nextPutAll: 'LLMToolResult(';
		nextPutAll: (toolName ifNil: [ 'unnamed' ]);
		nextPutAll: ': ';
		nextPutAll: (self isSuccess
				 ifTrue: [ 'success' ]
				 ifFalse: [ 'error' ]);
		nextPut: $)
]

{ #category : 'accessing' }
LLMToolResult >> toolName [

	^ toolName
]

{ #category : 'accessing' }
LLMToolResult >> toolName: aString [

	toolName := aString
]
