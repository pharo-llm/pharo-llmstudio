Class {
	#name : 'LLMHttpConnector',
	#superclass : 'Object',
	#instVars : [
		'baseUrl',
		'headers',
		'timeoutSeconds'
	],
	#category : 'LLM-LLMStudio-Connectors',
	#package : 'LLM-LLMStudio',
	#tag : 'Connectors'
}

{ #category : 'instance creation' }
LLMHttpConnector class >> baseUrl: aString [

	^ self new
		  baseUrl: aString;
		  yourself
]

{ #category : 'instance creation' }
LLMHttpConnector class >> new [

	^ super new initialize
]

{ #category : 'accessing' }
LLMHttpConnector >> baseUrl [

	^ baseUrl
]

{ #category : 'accessing' }
LLMHttpConnector >> baseUrl: aString [

	baseUrl := aString
]

{ #category : 'accessing' }
LLMHttpConnector >> headerAt: aKey put: aValue [

	headers at: aKey put: aValue
]

{ #category : 'accessing' }
LLMHttpConnector >> headers [

	^ headers
]

{ #category : 'initialization' }
LLMHttpConnector >> initialize [

	headers := Dictionary new.
	timeoutSeconds := 120.
	headers at: 'Content-Type' put: 'application/json'
]

{ #category : 'api' }
LLMHttpConnector >> post: anEndpoint body: aDictionary [
	"Send a POST request and return the parsed JSON response."

	| url client response |
	url := baseUrl , anEndpoint.
	client := ZnClient new
		           url: url;
		           timeout: timeoutSeconds;
		           yourself.
	headers keysAndValuesDo: [ :key :value |
		client headerAt: key put: value ].
	client
		entity: (ZnEntity json: (NeoJSONWriter toString: aDictionary));
		post.
	response := client response.
	response isSuccess
		ifFalse: [
			response code = 429
				ifTrue: [ LLMRateLimitError retryAfter: (self parseRetryAfter: response) ]
				ifFalse: [ LLMApiError statusCode: response code body: (response entity ifNotNil: [ :e | e string ] ifNil: [ '' ]) ] ].
	^ NeoJSONReader fromString: client contents
]

{ #category : 'api' }
LLMHttpConnector >> get: anEndpoint [
	"Send a GET request and return the parsed JSON response."

	| url client response |
	url := baseUrl , anEndpoint.
	client := ZnClient new
		           url: url;
		           timeout: timeoutSeconds;
		           yourself.
	headers keysAndValuesDo: [ :key :value |
		client headerAt: key put: value ].
	client get.
	response := client response.
	response isSuccess
		ifFalse: [
			LLMApiError statusCode: response code body: (response entity ifNotNil: [ :e | e string ] ifNil: [ '' ]) ].
	^ NeoJSONReader fromString: client contents
]

{ #category : 'private' }
LLMHttpConnector >> parseRetryAfter: aResponse [

	| retryHeader |
	retryHeader := aResponse headers
		               at: 'Retry-After'
		               ifAbsent: [ '60' ].
	^ retryHeader asInteger
]

{ #category : 'printing' }
LLMHttpConnector >> printOn: aStream [

	aStream
		nextPutAll: 'LLMHttpConnector(';
		nextPutAll: (baseUrl ifNil: [ 'no url' ]);
		nextPut: $)
]

{ #category : 'accessing' }
LLMHttpConnector >> timeoutSeconds [

	^ timeoutSeconds
]

{ #category : 'accessing' }
LLMHttpConnector >> timeoutSeconds: anInteger [

	timeoutSeconds := anInteger
]
