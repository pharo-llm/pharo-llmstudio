Class {
	#name : 'LLMMapStep',
	#superclass : 'LLMPipelineStep',
	#instVars : [
		'wrappedStep',
		'inputKey',
		'outputKey',
		'collectResults'
	],
	#category : 'LLM-LLMStudio-Core',
	#package : 'LLM-LLMStudio',
	#tag : 'Core'
}

{ #category : 'instance creation' }
LLMMapStep class >> step: aStep [

	^ self new
		  wrappedStep: aStep;
		  yourself
]

{ #category : 'instance creation' }
LLMMapStep class >> step: aStep inputKey: aKey [

	^ self new
		  wrappedStep: aStep;
		  inputKey: aKey;
		  yourself
]

{ #category : 'instance creation' }
LLMMapStep class >> new [

	^ super new initialize
]

{ #category : 'accessing' }
LLMMapStep >> collectResults [

	^ collectResults
]

{ #category : 'accessing' }
LLMMapStep >> collectResults: aBoolean [

	collectResults := aBoolean
]

{ #category : 'initialization' }
LLMMapStep >> initialize [

	collectResults := true
]

{ #category : 'accessing' }
LLMMapStep >> inputKey [

	^ inputKey ifNil: [ #items ]
]

{ #category : 'accessing' }
LLMMapStep >> inputKey: aSymbol [

	inputKey := aSymbol
]

{ #category : 'accessing' }
LLMMapStep >> outputKey [

	^ outputKey ifNil: [ #mappedResults ]
]

{ #category : 'accessing' }
LLMMapStep >> outputKey: aSymbol [

	outputKey := aSymbol
]

{ #category : 'running' }
LLMMapStep >> processContext: aContext [
	"Apply the wrapped step to each item in the collection."

	| items results |
	items := aContext at: self inputKey ifAbsent: [
		         aContext output ifNil: [ #() ] ].
	items isCollection ifFalse: [
		LLMValidationError signal:
			'MapStep expects a collection as input' ].

	results := items collect: [ :item |
		           | itemContext |
		           itemContext := aContext copy.
		           itemContext output: item.
		           itemContext at: #item put: item.
		           (wrappedStep processContext: itemContext) output ].

	collectResults ifTrue: [
		aContext at: self outputKey put: results asArray ].
	aContext output: results asArray.
	^ aContext
]

{ #category : 'accessing' }
LLMMapStep >> wrappedStep [

	^ wrappedStep
]

{ #category : 'accessing' }
LLMMapStep >> wrappedStep: aStep [

	wrappedStep := aStep
]

{ #category : 'validating' }
LLMMapStep >> validate [

	wrappedStep ifNil: [
		LLMValidationError signal: 'MapStep requires a wrapped step' ].
	^ true
]
