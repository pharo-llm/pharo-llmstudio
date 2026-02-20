Class {
	#name : 'LLMResponse',
	#superclass : 'Object',
	#instVars : [
		'content',
		'role',
		'model',
		'finishReason',
		'usage',
		'toolCalls',
		'rawResponse'
	],
	#category : 'LLM-LLMStudio-Core',
	#package : 'LLM-LLMStudio',
	#tag : 'Core'
}

{ #category : 'instance creation' }
LLMResponse class >> content: aString [

	^ self new
		  content: aString;
		  yourself
]

{ #category : 'instance creation' }
LLMResponse class >> fromDictionary: aDictionary [
	"Create a response from a raw API response dictionary."

	| response choice message |
	response := self new.
	response rawResponse: aDictionary.

	"OpenAI-style response"
	(aDictionary includesKey: 'choices')
		ifTrue: [
			choice := (aDictionary at: 'choices') first.
			message := choice at: 'message' ifAbsent: [ choice ].
			response
				content: (message at: 'content' ifAbsent: [ '' ]);
				role: (message at: 'role' ifAbsent: [ 'assistant' ]);
				finishReason: (choice at: 'finish_reason' ifAbsent: [ nil ]).
			(message includesKey: 'tool_calls') ifTrue: [
				response toolCalls: (message at: 'tool_calls') ] ].

	"Anthropic-style response"
	(aDictionary includesKey: 'content')
		ifTrue: [
			| contentBlocks |
			contentBlocks := aDictionary at: 'content'.
			contentBlocks isArray
				ifTrue: [
					response content: (String streamContents: [ :s |
						contentBlocks do: [ :block |
							(block at: 'type' ifAbsent: [ '' ]) = 'text'
								ifTrue: [ s nextPutAll: (block at: 'text') ] ] ]) ]
				ifFalse: [ response content: contentBlocks ].
			response
				role: (aDictionary at: 'role' ifAbsent: [ 'assistant' ]);
				finishReason: (aDictionary at: 'stop_reason' ifAbsent: [ nil ]) ].

	"Usage info"
	(aDictionary includesKey: 'usage') ifTrue: [
		response usage: (aDictionary at: 'usage') ].

	response model: (aDictionary at: 'model' ifAbsent: [ nil ]).
	^ response
]

{ #category : 'instance creation' }
LLMResponse class >> new [

	^ super new initialize
]

{ #category : 'accessing' }
LLMResponse >> content [

	^ content
]

{ #category : 'accessing' }
LLMResponse >> content: aString [

	content := aString
]

{ #category : 'accessing' }
LLMResponse >> finishReason [

	^ finishReason
]

{ #category : 'accessing' }
LLMResponse >> finishReason: aString [

	finishReason := aString
]

{ #category : 'testing' }
LLMResponse >> hasToolCalls [

	^ toolCalls isNotNil and: [ toolCalls isNotEmpty ]
]

{ #category : 'initialization' }
LLMResponse >> initialize [

	toolCalls := #()
]

{ #category : 'accessing' }
LLMResponse >> inputTokens [

	^ usage
		  ifNotNil: [
			  (usage at: 'input_tokens' ifAbsent: [
				   usage at: 'prompt_tokens' ifAbsent: [ 0 ] ]) ]
		  ifNil: [ 0 ]
]

{ #category : 'accessing' }
LLMResponse >> model [

	^ model
]

{ #category : 'accessing' }
LLMResponse >> model: aString [

	model := aString
]

{ #category : 'accessing' }
LLMResponse >> outputTokens [

	^ usage
		  ifNotNil: [
			  (usage at: 'output_tokens' ifAbsent: [
				   usage at: 'completion_tokens' ifAbsent: [ 0 ] ]) ]
		  ifNil: [ 0 ]
]

{ #category : 'printing' }
LLMResponse >> printOn: aStream [

	aStream
		nextPutAll: 'LLMResponse(';
		nextPutAll: (content
				 ifNotNil: [ content truncateTo: 50 ]
				 ifNil: [ 'empty' ]);
		nextPut: $)
]

{ #category : 'accessing' }
LLMResponse >> rawResponse [

	^ rawResponse
]

{ #category : 'accessing' }
LLMResponse >> rawResponse: aDictionary [

	rawResponse := aDictionary
]

{ #category : 'accessing' }
LLMResponse >> role [

	^ role
]

{ #category : 'accessing' }
LLMResponse >> role: aString [

	role := aString
]

{ #category : 'accessing' }
LLMResponse >> toolCalls [

	^ toolCalls
]

{ #category : 'accessing' }
LLMResponse >> toolCalls: aCollection [

	toolCalls := aCollection
]

{ #category : 'accessing' }
LLMResponse >> totalTokens [

	^ self inputTokens + self outputTokens
]

{ #category : 'accessing' }
LLMResponse >> usage [

	^ usage
]

{ #category : 'accessing' }
LLMResponse >> usage: aDictionary [

	usage := aDictionary
]
