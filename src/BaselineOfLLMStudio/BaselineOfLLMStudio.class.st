Class {
	#name : 'BaselineOfLLMStudio',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfLLMStudio',
	#package : 'BaselineOfLLMStudio'
}

{ #category : 'baselines' }
BaselineOfLLMStudio >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec baseline: 'NeoJSON' with: [ spec repository: 'github://svenvc/NeoJSON/repository' ].
		spec
			package: 'LLM-LLMStudio';
			package: 'LLM-LLMStudio-Visualizer'
			with: [ spec requires: #( 'LLM-LLMStudio' ) ];
			package: 'LLM-LLMStudio-Tests'
			with: [ spec requires: #( 'LLM-LLMStudio' ) ];
			package: 'LLM-LLMStudio-Visualizer-Tests'
			with: [ spec requires: #( 'LLM-LLMStudio-Visualizer' 'LLM-LLMStudio-Tests' ) ].
		spec
			group: 'Core' with: #( 'LLM-LLMStudio' );
			group: 'Visualizer' with: #( 'LLM-LLMStudio-Visualizer' );
			group: 'Tests' with: #( 'LLM-LLMStudio-Tests' 'LLM-LLMStudio-Visualizer-Tests' );
			group: 'default' with: #( 'Core' 'Visualizer' 'Tests' ) ]
]
