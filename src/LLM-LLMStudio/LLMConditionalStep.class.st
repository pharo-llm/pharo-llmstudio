Class {
	#name : 'LLMConditionalStep',
	#superclass : 'LLMPipelineStep',
	#instVars : [
		'conditionBlock',
		'trueStep',
		'falseStep'
	],
	#category : 'LLM-LLMStudio-Core',
	#package : 'LLM-LLMStudio',
	#tag : 'Core'
}

{ #category : 'instance creation' }
LLMConditionalStep class >> condition: aBlock ifTrue: aTrueStep [

	^ self new
		  conditionBlock: aBlock;
		  trueStep: aTrueStep;
		  yourself
]

{ #category : 'instance creation' }
LLMConditionalStep class >> condition: aBlock ifTrue: aTrueStep ifFalse: aFalseStep [

	^ self new
		  conditionBlock: aBlock;
		  trueStep: aTrueStep;
		  falseStep: aFalseStep;
		  yourself
]

{ #category : 'accessing' }
LLMConditionalStep >> conditionBlock [

	^ conditionBlock
]

{ #category : 'accessing' }
LLMConditionalStep >> conditionBlock: aBlock [

	conditionBlock := aBlock
]

{ #category : 'accessing' }
LLMConditionalStep >> falseStep [

	^ falseStep
]

{ #category : 'accessing' }
LLMConditionalStep >> falseStep: aStep [

	falseStep := aStep
]

{ #category : 'running' }
LLMConditionalStep >> processContext: aContext [

	(conditionBlock value: aContext)
		ifTrue: [ ^ trueStep processContext: aContext ]
		ifFalse: [
			falseStep
				ifNotNil: [ ^ falseStep processContext: aContext ]
				ifNil: [ ^ aContext ] ]
]

{ #category : 'accessing' }
LLMConditionalStep >> trueStep [

	^ trueStep
]

{ #category : 'accessing' }
LLMConditionalStep >> trueStep: aStep [

	trueStep := aStep
]

{ #category : 'validating' }
LLMConditionalStep >> validate [

	conditionBlock ifNil: [
		LLMValidationError signal:
			'ConditionalStep requires a condition block' ].
	trueStep ifNil: [
		LLMValidationError signal:
			'ConditionalStep requires at least a trueStep' ].
	^ true
]
