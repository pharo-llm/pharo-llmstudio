Class {
	#name : 'LLMSlidingWindowMemory',
	#superclass : 'LLMMemory',
	#instVars : [
		'windowSize',
		'systemMessage'
	],
	#category : 'LLM-LLMStudio-Memory',
	#package : 'LLM-LLMStudio',
	#tag : 'Memory'
}

{ #category : 'instance creation' }
LLMSlidingWindowMemory class >> new [

	^ super new initialize
]

{ #category : 'instance creation' }
LLMSlidingWindowMemory class >> windowSize: anInteger [

	^ self new
		  windowSize: anInteger;
		  yourself
]

{ #category : 'initialization' }
LLMSlidingWindowMemory >> initialize [

	super initialize.
	windowSize := 10
]

{ #category : 'accessing' }
LLMSlidingWindowMemory >> messages [
	"Return only the last N messages within the window, with system message prepended."

	| result allMessages startIndex |
	result := OrderedCollection new.
	systemMessage ifNotNil: [ :sys |
		result add: (LLMChatMessage system: sys) ].
	allMessages := self rawMessages.
	startIndex := (allMessages size - windowSize + 1) max: 1.
	result addAll: (allMessages copyFrom: startIndex to: allMessages size).
	^ result asArray
]

{ #category : 'accessing' }
LLMSlidingWindowMemory >> systemMessage [

	^ systemMessage
]

{ #category : 'accessing' }
LLMSlidingWindowMemory >> systemMessage: aString [

	systemMessage := aString
]

{ #category : 'accessing' }
LLMSlidingWindowMemory >> windowSize [

	^ windowSize
]

{ #category : 'accessing' }
LLMSlidingWindowMemory >> windowSize: anInteger [

	windowSize := anInteger
]
