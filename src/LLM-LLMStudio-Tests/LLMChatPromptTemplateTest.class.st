Class {
	#name : 'LLMChatPromptTemplateTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Prompts',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Prompts'
}

{ #category : 'tests' }
LLMChatPromptTemplateTest >> testFormatContext [

	| template ctx messages |
	template := LLMChatPromptTemplate new
		            addUserMessage: 'Hello {name}';
		            yourself.
	ctx := LLMPipelineContext withVariables:
		       { (#name -> 'Bob') } asDictionary.
	messages := template formatContext: ctx.
	self assert: messages first content equals: 'Hello Bob'
]

{ #category : 'tests' }
LLMChatPromptTemplateTest >> testFromMessages [

	| template messages |
	template := LLMChatPromptTemplate fromMessages: {
			            (#system -> 'System prompt').
			            (#user -> 'User says {msg}') }.
	messages := template format: { (#msg -> 'hello') } asDictionary.
	self assert: messages size equals: 2.
	self assert: messages first isSystem.
	self assert: messages second content equals: 'User says hello'
]

{ #category : 'tests' }
LLMChatPromptTemplateTest >> testInputVariables [

	| template |
	template := LLMChatPromptTemplate new
		            addSystemMessage: 'Translate to {language}';
		            addUserMessage: '{text}';
		            yourself.
	self
		assert: template inputVariables asSet
		equals: #( 'language' 'text' ) asSet
]

{ #category : 'tests' }
LLMChatPromptTemplateTest >> testMultiTurnConversation [

	| template messages |
	template := LLMChatPromptTemplate new
		            addSystemMessage: 'You are a tutor.';
		            addUserMessage: 'What is {topic}?';
		            addAssistantMessage: '{topic} is a concept in {field}.';
		            addUserMessage: 'Tell me more about {topic}.';
		            yourself.
	messages := template format: {
			            (#topic -> 'polymorphism').
			            (#field -> 'OOP') } asDictionary.
	self assert: messages size equals: 4.
	self assert: messages third isAssistant.
	self
		assert: messages third content
		equals: 'polymorphism is a concept in OOP.'
]

{ #category : 'tests' }
LLMChatPromptTemplateTest >> testSimpleChatPrompt [

	| template messages |
	template := LLMChatPromptTemplate new
		            addSystemMessage: 'You are a helpful assistant.';
		            addUserMessage: 'Hello {name}!';
		            yourself.
	messages := template format: { (#name -> 'World') } asDictionary.
	self assert: messages size equals: 2.
	self assert: messages first isSystem.
	self assert: messages first content equals: 'You are a helpful assistant.'.
	self assert: messages second isUser.
	self assert: messages second content equals: 'Hello World!'
]
