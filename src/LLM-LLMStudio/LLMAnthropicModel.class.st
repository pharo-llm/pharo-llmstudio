Class {
	#name : 'LLMAnthropicModel',
	#superclass : 'LLMAbstractModel',
	#instVars : [
		'systemPrompt'
	],
	#category : 'LLM-LLMStudio-Models',
	#package : 'LLM-LLMStudio',
	#tag : 'Models'
}

{ #category : 'instance creation' }
LLMAnthropicModel class >> claude3Haiku [

	^ self modelId: 'claude-3-haiku-20240307'
]

{ #category : 'instance creation' }
LLMAnthropicModel class >> claude3Opus [

	^ self modelId: 'claude-3-opus-20240229'
]

{ #category : 'instance creation' }
LLMAnthropicModel class >> claude3Sonnet [

	^ self modelId: 'claude-3-5-sonnet-20241022'
]

{ #category : 'api' }
LLMAnthropicModel >> buildRequestBody: messages [

	| body normalizedMessages |
	body := Dictionary new.
	body at: 'model' put: modelId.
	body at: 'max_tokens' put: configuration maxTokens.
	normalizedMessages := self normalizeMessages: messages.

	"Extract system messages into top-level system parameter"
	| systemMessages chatMessages |
	systemMessages := normalizedMessages select: [ :m |
		                  (m at: 'role') = 'system' ].
	chatMessages := normalizedMessages reject: [ :m |
		                (m at: 'role') = 'system' ].
	systemMessages ifNotEmpty: [
		body at: 'system' put: (String streamContents: [ :s |
				 systemMessages
					 do: [ :m | s nextPutAll: (m at: 'content') ]
					 separatedBy: [ s cr ] ]) ].
	systemPrompt ifNotNil: [ :sp |
		body at: 'system' put: sp ].
	body at: 'messages' put: chatMessages.
	configuration temperature ifNotNil: [ :t |
		body at: 'temperature' put: t ].
	configuration topP ifNotNil: [ :p |
		body at: 'top_p' put: p ].
	(configuration stopSequences isNotNil and: [
		 configuration stopSequences isNotEmpty ]) ifTrue: [
		body at: 'stop_sequences' put: configuration stopSequences ].
	^ body
]

{ #category : 'api' }
LLMAnthropicModel >> completionEndpoint [

	^ '/v1/messages'
]

{ #category : 'private' }
LLMAnthropicModel >> createDefaultConnector [

	| conn |
	conn := LLMHttpConnector baseUrl: 'https://api.anthropic.com'.
	conn headerAt: 'x-api-key' put: (self apiKeyManager apiKeyFor: self providerName).
	conn headerAt: 'anthropic-version' put: '2023-06-01'.
	^ conn
]

{ #category : 'accessing' }
LLMAnthropicModel >> providerName [

	^ #anthropic
]

{ #category : 'accessing' }
LLMAnthropicModel >> systemPrompt [

	^ systemPrompt
]

{ #category : 'accessing' }
LLMAnthropicModel >> systemPrompt: aString [

	systemPrompt := aString
]
