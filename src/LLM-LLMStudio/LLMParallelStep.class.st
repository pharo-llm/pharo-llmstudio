Class {
	#name : 'LLMParallelStep',
	#superclass : 'LLMPipelineStep',
	#instVars : [
		'branches'
	],
	#category : 'LLM-LLMStudio-Core',
	#package : 'LLM-LLMStudio',
	#tag : 'Core'
}

{ #category : 'instance creation' }
LLMParallelStep class >> new [

	^ super new initialize
]

{ #category : 'instance creation' }
LLMParallelStep class >> branches: aDictionary [
	"Create with named branches: { #translation -> translatePipeline. #summary -> summaryPipeline }"

	| instance |
	instance := self new.
	aDictionary associationsDo: [ :assoc |
		instance addBranch: assoc key step: assoc value ].
	^ instance
]

{ #category : 'building' }
LLMParallelStep >> addBranch: aName step: aStep [

	branches at: aName put: aStep.
	^ self
]

{ #category : 'accessing' }
LLMParallelStep >> branches [

	^ branches
]

{ #category : 'initialization' }
LLMParallelStep >> initialize [

	branches := OrderedDictionary new
]

{ #category : 'running' }
LLMParallelStep >> processContext: aContext [
	"Execute all branches with copies of the context, then merge results."

	| results |
	results := Dictionary new.
	branches keysAndValuesDo: [ :branchName :step |
		| branchContext branchResult |
		branchContext := aContext copy.
		branchResult := step processContext: branchContext.
		results at: branchName put: branchResult output ].
	aContext at: #parallelResults put: results.
	aContext output: results.
	^ aContext
]

{ #category : 'printing' }
LLMParallelStep >> printOn: aStream [

	aStream
		nextPutAll: 'LLMParallelStep(';
		print: branches size;
		nextPutAll: ' branches)'
]

{ #category : 'validating' }
LLMParallelStep >> validate [

	branches ifEmpty: [
		LLMValidationError signal:
			'ParallelStep requires at least one branch' ].
	branches valuesDo: [ :step | step validate ].
	^ true
]
