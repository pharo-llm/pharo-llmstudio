Class {
	#name : 'BaselineOfLLMStudio',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfLLMLLMStudio',
	#package : 'BaselineOfLLMLLMStudio'
}

{ #category : 'baselines' }
BaselineOfLLMStudio >> baseline: spec [

	<baseline>
	spec for: #common do: [ spec package: 'LLM-LLMStudio' ]
]
