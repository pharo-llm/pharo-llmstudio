Class {
	#name : 'LLMOllamaModel',
	#superclass : 'LLMAbstractModel',
	#instVars : [
		'host',
		'port'
	],
	#category : 'LLM-LLMStudio-Models',
	#package : 'LLM-LLMStudio',
	#tag : 'Models'
}

{ #category : 'instance creation' }
LLMOllamaModel class >> codeLlama [

	^ self modelId: 'codellama'
]

{ #category : 'instance creation' }
LLMOllamaModel class >> llama3 [

	^ self modelId: 'llama3'
]

{ #category : 'instance creation' }
LLMOllamaModel class >> mistral [

	^ self modelId: 'mistral'
]

{ #category : 'instance creation' }
LLMOllamaModel class >> new [

	^ super new initialize
]

{ #category : 'api' }
LLMOllamaModel >> buildRequestBody: messages [

	| body |
	body := Dictionary new.
	body at: 'model' put: modelId.
	body at: 'messages' put: (self normalizeMessages: messages).
	body at: 'stream' put: false.
	body at: 'options' put: (Dictionary new
			 at: 'temperature' put: configuration temperature;
			 at: 'num_predict' put: configuration maxTokens;
			 yourself).
	configuration topP ifNotNil: [ :p |
		(body at: 'options') at: 'top_p' put: p ].
	(configuration stopSequences isNotNil and: [
		 configuration stopSequences isNotEmpty ]) ifTrue: [
		(body at: 'options') at: 'stop' put: configuration stopSequences ].
	^ body
]

{ #category : 'api' }
LLMOllamaModel >> completionEndpoint [

	^ '/api/chat'
]

{ #category : 'private' }
LLMOllamaModel >> createDefaultConnector [
	"Ollama runs locally and does not require an API key."

	^ LLMHttpConnector baseUrl: 'http://' , self host , ':' , self port printString
]

{ #category : 'accessing' }
LLMOllamaModel >> host [

	^ host ifNil: [ 'localhost' ]
]

{ #category : 'accessing' }
LLMOllamaModel >> host: aString [

	host := aString
]

{ #category : 'initialization' }
LLMOllamaModel >> initialize [

	super initialize.
	host := 'localhost'.
	port := 11434
]

{ #category : 'accessing' }
LLMOllamaModel >> port [

	^ port ifNil: [ 11434 ]
]

{ #category : 'accessing' }
LLMOllamaModel >> port: anInteger [

	port := anInteger
]

{ #category : 'accessing' }
LLMOllamaModel >> providerName [

	^ #ollama
]
