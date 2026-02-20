Class {
	#name : 'LLMChatMessageTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Prompts',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Prompts'
}

{ #category : 'tests' }
LLMChatMessageTest >> testAsDictionary [

	| msg dict |
	msg := LLMChatMessage user: 'Hello'.
	dict := msg asDictionary.
	self assert: (dict at: 'role') equals: 'user'.
	self assert: (dict at: 'content') equals: 'Hello'
]

{ #category : 'tests' }
LLMChatMessageTest >> testAssistantMessage [

	| msg |
	msg := LLMChatMessage assistant: 'Hi there!'.
	self assert: msg role equals: 'assistant'.
	self assert: msg content equals: 'Hi there!'.
	self assert: msg isAssistant
]

{ #category : 'tests' }
LLMChatMessageTest >> testCustomRole [

	| msg |
	msg := LLMChatMessage role: 'tool' content: 'Tool result'.
	self assert: msg role equals: 'tool'.
	self assert: msg content equals: 'Tool result'
]

{ #category : 'tests' }
LLMChatMessageTest >> testSystemMessage [

	| msg |
	msg := LLMChatMessage system: 'You are helpful.'.
	self assert: msg role equals: 'system'.
	self assert: msg content equals: 'You are helpful.'.
	self assert: msg isSystem.
	self deny: msg isUser.
	self deny: msg isAssistant
]

{ #category : 'tests' }
LLMChatMessageTest >> testUserMessage [

	| msg |
	msg := LLMChatMessage user: 'Hello!'.
	self assert: msg role equals: 'user'.
	self assert: msg content equals: 'Hello!'.
	self assert: msg isUser
]
