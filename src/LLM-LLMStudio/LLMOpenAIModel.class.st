Class {
	#name : 'LLMOpenAIModel',
	#superclass : 'LLMAbstractModel',
	#category : 'LLM-LLMStudio-Models',
	#package : 'LLM-LLMStudio',
	#tag : 'Models'
}

{ #category : 'instance creation' }
LLMOpenAIModel class >> gpt4 [

	^ self modelId: 'gpt-4'
]

{ #category : 'instance creation' }
LLMOpenAIModel class >> gpt4Turbo [

	^ self modelId: 'gpt-4-turbo'
]

{ #category : 'instance creation' }
LLMOpenAIModel class >> gpt4o [

	^ self modelId: 'gpt-4o'
]

{ #category : 'instance creation' }
LLMOpenAIModel class >> gpt4oMini [

	^ self modelId: 'gpt-4o-mini'
]

{ #category : 'api' }
LLMOpenAIModel >> buildRequestBody: messages [

	| body |
	body := Dictionary new.
	body at: 'model' put: modelId.
	body at: 'messages' put: (self normalizeMessages: messages).
	body addAll: configuration asDictionary.
	^ body
]

{ #category : 'api' }
LLMOpenAIModel >> completionEndpoint [

	^ '/v1/chat/completions'
]

{ #category : 'private' }
LLMOpenAIModel >> createDefaultConnector [

	| conn |
	conn := LLMHttpConnector baseUrl: 'https://api.openai.com'.
	conn headerAt: 'Authorization' put: 'Bearer ' , (self apiKeyManager apiKeyFor: self providerName).
	^ conn
]

{ #category : 'accessing' }
LLMOpenAIModel >> providerName [

	^ #openai
]
