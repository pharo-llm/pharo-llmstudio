Class {
	#name : 'LLMRetryStep',
	#superclass : 'LLMPipelineStep',
	#instVars : [
		'wrappedStep',
		'maxRetries',
		'backoffStrategy',
		'retryOn',
		'onRetry'
	],
	#category : 'LLM-LLMStudio-Core',
	#package : 'LLM-LLMStudio',
	#tag : 'Core'
}

{ #category : 'instance creation' }
LLMRetryStep class >> new [

	^ super new initialize
]

{ #category : 'instance creation' }
LLMRetryStep class >> step: aStep maxRetries: anInteger [

	^ self new
		  wrappedStep: aStep;
		  maxRetries: anInteger;
		  yourself
]

{ #category : 'accessing' }
LLMRetryStep >> backoffStrategy [

	^ backoffStrategy
]

{ #category : 'accessing' }
LLMRetryStep >> backoffStrategy: aSymbol [
	"Set the backoff strategy: #linear, #exponential, or #fixed."

	backoffStrategy := aSymbol
]

{ #category : 'private' }
LLMRetryStep >> delayForAttempt: attemptNumber [
	"Calculate delay in seconds based on the backoff strategy."

	backoffStrategy = #exponential ifTrue: [
		^ (2 raisedTo: attemptNumber - 1) min: 60 ].
	backoffStrategy = #linear ifTrue: [ ^ attemptNumber ].
	"#fixed"
	^ 1
]

{ #category : 'initialization' }
LLMRetryStep >> initialize [

	maxRetries := 3.
	backoffStrategy := #exponential.
	retryOn := { Error }
]

{ #category : 'accessing' }
LLMRetryStep >> maxRetries [

	^ maxRetries
]

{ #category : 'accessing' }
LLMRetryStep >> maxRetries: anInteger [

	maxRetries := anInteger
]

{ #category : 'accessing' }
LLMRetryStep >> onRetry [

	^ onRetry
]

{ #category : 'accessing' }
LLMRetryStep >> onRetry: aBlock [
	"Set a callback block that receives [ :error :attemptNumber | ... ] on each retry."

	onRetry := aBlock
]

{ #category : 'running' }
LLMRetryStep >> processContext: aContext [

	| attempt lastError |
	attempt := 0.
	[
	attempt := attempt + 1.
	[ ^ wrappedStep processContext: aContext ]
		on: Error
		do: [ :e |
			lastError := e.
			(self shouldRetry: e attempt: attempt)
				ifFalse: [ e signal ]
				ifTrue: [
					onRetry ifNotNil: [ :blk | blk value: e value: attempt ].
					aContext addError: e.
					(Delay forSeconds: (self delayForAttempt: attempt)) wait ] ] ]
		repeat.
	lastError signal
]

{ #category : 'accessing' }
LLMRetryStep >> retryOn [

	^ retryOn
]

{ #category : 'accessing' }
LLMRetryStep >> retryOn: aCollectionOfExceptionClasses [

	retryOn := aCollectionOfExceptionClasses
]

{ #category : 'private' }
LLMRetryStep >> shouldRetry: anError attempt: attemptNumber [

	attemptNumber > maxRetries ifTrue: [ ^ false ].
	^ retryOn anySatisfy: [ :exClass | anError isKindOf: exClass ]
]

{ #category : 'validating' }
LLMRetryStep >> validate [

	wrappedStep ifNil: [
		LLMValidationError signal:
			'RetryStep requires a wrapped step' ].
	^ true
]

{ #category : 'accessing' }
LLMRetryStep >> wrappedStep [

	^ wrappedStep
]

{ #category : 'accessing' }
LLMRetryStep >> wrappedStep: aStep [

	wrappedStep := aStep
]
