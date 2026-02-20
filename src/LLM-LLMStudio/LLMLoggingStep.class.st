Class {
	#name : 'LLMLoggingStep',
	#superclass : 'LLMPipelineStep',
	#instVars : [
		'wrappedStep',
		'logger',
		'logLevel',
		'logInput',
		'logOutput'
	],
	#category : 'LLM-LLMStudio-Core',
	#package : 'LLM-LLMStudio',
	#tag : 'Core'
}

{ #category : 'instance creation' }
LLMLoggingStep class >> new [

	^ super new initialize
]

{ #category : 'instance creation' }
LLMLoggingStep class >> step: aStep [

	^ self new
		  wrappedStep: aStep;
		  yourself
]

{ #category : 'instance creation' }
LLMLoggingStep class >> step: aStep logger: aBlock [

	^ self new
		  wrappedStep: aStep;
		  logger: aBlock;
		  yourself
]

{ #category : 'initialization' }
LLMLoggingStep >> initialize [

	logInput := true.
	logOutput := true.
	logLevel := #info.
	logger := [ :msg | Transcript show: msg; cr ]
]

{ #category : 'private' }
LLMLoggingStep >> log: aMessage [

	logger value: aMessage
]

{ #category : 'accessing' }
LLMLoggingStep >> logInput [

	^ logInput
]

{ #category : 'accessing' }
LLMLoggingStep >> logInput: aBoolean [

	logInput := aBoolean
]

{ #category : 'accessing' }
LLMLoggingStep >> logLevel [

	^ logLevel
]

{ #category : 'accessing' }
LLMLoggingStep >> logLevel: aSymbol [
	"Set log level: #debug, #info, #warn, #error."

	logLevel := aSymbol
]

{ #category : 'accessing' }
LLMLoggingStep >> logOutput [

	^ logOutput
]

{ #category : 'accessing' }
LLMLoggingStep >> logOutput: aBoolean [

	logOutput := aBoolean
]

{ #category : 'accessing' }
LLMLoggingStep >> logger [

	^ logger
]

{ #category : 'accessing' }
LLMLoggingStep >> logger: aBlock [
	"Set a custom logging block: [ :message | ... ]"

	logger := aBlock
]

{ #category : 'running' }
LLMLoggingStep >> processContext: aContext [

	| startTime result elapsed |
	logInput ifTrue: [
		self log: '[' , logLevel , '] Step "' , wrappedStep name
			, '" input: ' , (aContext output ifNil: [ 'nil' ]) printString ].

	startTime := DateAndTime now.
	result := wrappedStep processContext: aContext.
	elapsed := DateAndTime now - startTime.

	logOutput ifTrue: [
		self log: '[' , logLevel , '] Step "' , wrappedStep name
			, '" output: ' , (result output ifNil: [ 'nil' ]) printString
			, ' (' , elapsed asMilliSeconds printString , 'ms)' ].

	^ result
]

{ #category : 'validating' }
LLMLoggingStep >> validate [

	wrappedStep ifNil: [
		LLMValidationError signal:
			'LoggingStep requires a wrapped step' ].
	^ true
]

{ #category : 'accessing' }
LLMLoggingStep >> wrappedStep [

	^ wrappedStep
]

{ #category : 'accessing' }
LLMLoggingStep >> wrappedStep: aStep [

	wrappedStep := aStep
]
