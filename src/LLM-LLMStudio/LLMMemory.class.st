Class {
	#name : 'LLMMemory',
	#superclass : 'Object',
	#instVars : [
		'messages'
	],
	#category : 'LLM-LLMStudio-Memory',
	#package : 'LLM-LLMStudio',
	#tag : 'Memory'
}

{ #category : 'instance creation' }
LLMMemory class >> new [

	^ super new initialize
]

{ #category : 'accessing' }
LLMMemory >> addAssistantMessage: aString [

	self addMessage: (LLMChatMessage assistant: aString)
]

{ #category : 'accessing' }
LLMMemory >> addMessage: aChatMessage [
	"Add a message to memory. Subclasses may override for custom behavior."

	messages add: aChatMessage
]

{ #category : 'accessing' }
LLMMemory >> addUserMessage: aString [

	self addMessage: (LLMChatMessage user: aString)
]

{ #category : 'accessing' }
LLMMemory >> clear [

	messages removeAll
]

{ #category : 'initialization' }
LLMMemory >> initialize [

	messages := OrderedCollection new
]

{ #category : 'accessing' }
LLMMemory >> messages [
	"Return the messages that should be included in the next request.
	 Subclasses must override."

	^ self subclassResponsibility
]

{ #category : 'printing' }
LLMMemory >> printOn: aStream [

	aStream
		nextPutAll: self class name;
		nextPut: $(;
		print: messages size;
		nextPutAll: ' messages)'
]

{ #category : 'accessing' }
LLMMemory >> rawMessages [
	"Access the underlying message collection."

	^ messages
]

{ #category : 'accessing' }
LLMMemory >> size [

	^ messages size
]
