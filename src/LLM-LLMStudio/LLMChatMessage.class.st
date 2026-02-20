Class {
	#name : 'LLMChatMessage',
	#superclass : 'Object',
	#instVars : [
		'role',
		'content'
	],
	#category : 'LLM-LLMStudio-Prompts',
	#package : 'LLM-LLMStudio',
	#tag : 'Prompts'
}

{ #category : 'instance creation' }
LLMChatMessage class >> assistant: aString [

	^ self role: 'assistant' content: aString
]

{ #category : 'instance creation' }
LLMChatMessage class >> role: aRole content: aContent [

	^ self new
		  role: aRole;
		  content: aContent;
		  yourself
]

{ #category : 'instance creation' }
LLMChatMessage class >> system: aString [

	^ self role: 'system' content: aString
]

{ #category : 'instance creation' }
LLMChatMessage class >> user: aString [

	^ self role: 'user' content: aString
]

{ #category : 'converting' }
LLMChatMessage >> asDictionary [

	^ Dictionary new
		  at: 'role' put: role;
		  at: 'content' put: content;
		  yourself
]

{ #category : 'accessing' }
LLMChatMessage >> content [

	^ content
]

{ #category : 'accessing' }
LLMChatMessage >> content: aString [

	content := aString
]

{ #category : 'testing' }
LLMChatMessage >> isAssistant [

	^ role = 'assistant'
]

{ #category : 'testing' }
LLMChatMessage >> isSystem [

	^ role = 'system'
]

{ #category : 'testing' }
LLMChatMessage >> isUser [

	^ role = 'user'
]

{ #category : 'printing' }
LLMChatMessage >> printOn: aStream [

	aStream
		nextPutAll: 'LLMChatMessage(';
		nextPutAll: role;
		nextPutAll: ': ';
		nextPutAll: (content truncateTo: 30);
		nextPut: $)
]

{ #category : 'accessing' }
LLMChatMessage >> role [

	^ role
]

{ #category : 'accessing' }
LLMChatMessage >> role: aString [

	role := aString
]
