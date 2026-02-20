Class {
	#name : 'LLMAbstractModel',
	#superclass : 'Object',
	#instVars : [
		'modelId',
		'configuration',
		'connector',
		'apiKeyManager'
	],
	#category : 'LLM-LLMStudio-Models',
	#package : 'LLM-LLMStudio',
	#tag : 'Models'
}

{ #category : 'instance creation' }
LLMAbstractModel class >> modelId: aString [

	^ self new
		  modelId: aString;
		  yourself
]

{ #category : 'instance creation' }
LLMAbstractModel class >> new [

	^ super new initialize
]

{ #category : 'accessing' }
LLMAbstractModel >> apiKeyManager [

	^ apiKeyManager ifNil: [ LLMApiKeyManager default ]
]

{ #category : 'accessing' }
LLMAbstractModel >> apiKeyManager: anApiKeyManager [

	apiKeyManager := anApiKeyManager
]

{ #category : 'api' }
LLMAbstractModel >> buildRequestBody: messages [
	"Build the provider-specific request body. Subclasses must override."

	^ self subclassResponsibility
]

{ #category : 'api' }
LLMAbstractModel >> chat: messages [
	"Send a chat completion request with messages (an array of LLMChatMessage or dictionaries)."

	| requestBody rawResponse |
	requestBody := self buildRequestBody: messages.
	rawResponse := self connector post: self completionEndpoint body: requestBody.
	^ LLMResponse fromDictionary: rawResponse
]

{ #category : 'api' }
LLMAbstractModel >> complete: aPromptString [
	"Convenience method: complete a single text prompt."

	| messages |
	messages := { LLMChatMessage user: aPromptString }.
	^ self chat: messages
]

{ #category : 'api' }
LLMAbstractModel >> completionEndpoint [
	"Return the API endpoint path for completions. Subclasses must override."

	^ self subclassResponsibility
]

{ #category : 'accessing' }
LLMAbstractModel >> configuration [

	^ configuration
]

{ #category : 'accessing' }
LLMAbstractModel >> configuration: aModelConfiguration [

	configuration := aModelConfiguration
]

{ #category : 'accessing' }
LLMAbstractModel >> connector [

	^ connector ifNil: [
		  connector := self createDefaultConnector ]
]

{ #category : 'accessing' }
LLMAbstractModel >> connector: anHttpConnector [

	connector := anHttpConnector
]

{ #category : 'private' }
LLMAbstractModel >> createDefaultConnector [
	"Create the default HTTP connector for this provider. Subclasses must override."

	^ self subclassResponsibility
]

{ #category : 'initialization' }
LLMAbstractModel >> initialize [

	configuration := LLMModelConfiguration new
]

{ #category : 'accessing' }
LLMAbstractModel >> modelId [

	^ modelId
]

{ #category : 'accessing' }
LLMAbstractModel >> modelId: aString [

	modelId := aString
]

{ #category : 'private' }
LLMAbstractModel >> normalizeMessages: messages [
	"Ensure messages are in dictionary format suitable for the API."

	^ messages collect: [ :msg |
		  msg isDictionary
			  ifTrue: [ msg ]
			  ifFalse: [ msg asDictionary ] ]
]

{ #category : 'printing' }
LLMAbstractModel >> printOn: aStream [

	aStream
		nextPutAll: self class name;
		nextPut: $(;
		nextPutAll: (modelId ifNil: [ 'no model' ]);
		nextPut: $)
]

{ #category : 'accessing' }
LLMAbstractModel >> providerName [
	"Return the provider identifier. Subclasses must override."

	^ self subclassResponsibility
]
