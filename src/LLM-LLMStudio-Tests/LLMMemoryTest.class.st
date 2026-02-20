Class {
	#name : 'LLMMemoryTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Memory',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Memory'
}

{ #category : 'tests - buffer' }
LLMMemoryTest >> testBufferMemoryAddMessages [

	| memory |
	memory := LLMBufferMemory new.
	memory addUserMessage: 'Hello'.
	memory addAssistantMessage: 'Hi there!'.
	self assert: memory size equals: 2.
	self assert: memory messages size equals: 2
]

{ #category : 'tests - buffer' }
LLMMemoryTest >> testBufferMemoryClear [

	| memory |
	memory := LLMBufferMemory new.
	memory addUserMessage: 'Hello'.
	memory addAssistantMessage: 'Hi'.
	memory clear.
	self assert: memory size equals: 0
]

{ #category : 'tests - buffer' }
LLMMemoryTest >> testBufferMemoryWithSystemMessage [

	| memory messages |
	memory := LLMBufferMemory withSystemMessage: 'You are a helper.'.
	memory addUserMessage: 'Hello'.
	messages := memory messages.
	self assert: messages size equals: 2.
	self assert: messages first isSystem.
	self assert: messages first content equals: 'You are a helper.'.
	self assert: messages second isUser
]

{ #category : 'tests - sliding' }
LLMMemoryTest >> testSlidingWindowBasic [

	| memory messages |
	memory := LLMSlidingWindowMemory windowSize: 4.
	1 to: 10 do: [ :i |
		memory addUserMessage: 'Message ' , i printString ].
	messages := memory messages.
	self assert: messages size equals: 4.
	self assert: messages first content equals: 'Message 7'
]

{ #category : 'tests - sliding' }
LLMMemoryTest >> testSlidingWindowDefaultSize [

	| memory |
	memory := LLMSlidingWindowMemory new.
	self assert: memory windowSize equals: 10
]

{ #category : 'tests - sliding' }
LLMMemoryTest >> testSlidingWindowUnderSize [

	| memory messages |
	memory := LLMSlidingWindowMemory windowSize: 10.
	memory addUserMessage: 'Hello'.
	messages := memory messages.
	self assert: messages size equals: 1
]

{ #category : 'tests - sliding' }
LLMMemoryTest >> testSlidingWindowWithSystemMessage [

	| memory messages |
	memory := LLMSlidingWindowMemory windowSize: 2.
	memory systemMessage: 'System'.
	memory addUserMessage: 'One'.
	memory addUserMessage: 'Two'.
	memory addUserMessage: 'Three'.
	messages := memory messages.
	self assert: messages size equals: 3.
	self assert: messages first isSystem.
	self assert: messages second content equals: 'Two'.
	self assert: messages third content equals: 'Three'
]
