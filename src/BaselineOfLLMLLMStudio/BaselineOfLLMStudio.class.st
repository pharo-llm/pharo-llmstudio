Class {
	#name : 'BaselineOfLLMStudio',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfLLMLLMStudio',
	#package : 'BaselineOfLLMLLMStudio'
}

{ #category : 'baselines' }
BaselineOfLLMStudio >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec
			package: 'LLM-LLMStudio';
			package: 'LLM-LLMStudio-Tests'
			with: [ spec requires: #( 'LLM-LLMStudio' ) ].
		spec
			group: 'Core' with: #( 'LLM-LLMStudio' );
			group: 'Tests' with: #( 'LLM-LLMStudio-Tests' );
			group: 'default' with: #( 'Core' 'Tests' ) ]
]
