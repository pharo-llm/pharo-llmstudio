Class {
	#name : 'LLMBufferMemory',
	#superclass : 'LLMMemory',
	#instVars : [
		'systemMessage'
	],
	#category : 'LLM-LLMStudio-Memory',
	#package : 'LLM-LLMStudio',
	#tag : 'Memory'
}

{ #category : 'instance creation' }
LLMBufferMemory class >> withSystemMessage: aString [

	^ self new
		  systemMessage: aString;
		  yourself
]

{ #category : 'accessing' }
LLMBufferMemory >> messages [
	"Return all messages with the system message prepended if set."

	| result |
	result := OrderedCollection new.
	systemMessage ifNotNil: [ :sys |
		result add: (LLMChatMessage system: sys) ].
	result addAll: self rawMessages.
	^ result asArray
]

{ #category : 'accessing' }
LLMBufferMemory >> systemMessage [

	^ systemMessage
]

{ #category : 'accessing' }
LLMBufferMemory >> systemMessage: aString [

	systemMessage := aString
]
