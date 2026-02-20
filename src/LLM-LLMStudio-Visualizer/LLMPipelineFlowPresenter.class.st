Class {
	#name : 'LLMPipelineFlowPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'flowMorphPresenter',
		'flowMorph',
		'detailPresenter',
		'headerLabel'
	],
	#category : 'LLM-LLMStudio-Visualizer-UI',
	#package : 'LLM-LLMStudio-Visualizer',
	#tag : 'UI'
}

{ #category : 'layout' }
LLMPipelineFlowPresenter >> defaultLayout [

	^ SpPanedLayout newTopToBottom
		  positionOfSlider: 55;
		  add: (SpBoxLayout newTopToBottom
				   spacing: 4;
				   add: headerLabel expand: false;
				   add: (SpScrollableLayout with: flowMorphPresenter);
				   yourself);
		  add: detailPresenter;
		  yourself
]

{ #category : 'initialization' }
LLMPipelineFlowPresenter >> initializePresenters [

	headerLabel := self newLabel label: 'Pipeline Flow'.

	flowMorph := LLMPipelineFlowMorph new.
	flowMorphPresenter := self newMorph morph: flowMorph.

	detailPresenter := LLMStepDetailPresenter new
]

{ #category : 'accessing' }
LLMPipelineFlowPresenter >> trace: anExecutionTrace [

	flowMorph trace: anExecutionTrace.
	flowMorphPresenter morph: flowMorph.
	detailPresenter stepExecution: nil
]
