Class {
	#name : 'LLMStepCompletedAnnouncement',
	#superclass : 'Announcement',
	#instVars : [
		'stepExecution'
	],
	#category : 'LLM-LLMStudio-Visualizer-Events',
	#package : 'LLM-LLMStudio-Visualizer',
	#tag : 'Events'
}

{ #category : 'accessing' }
LLMStepCompletedAnnouncement >> stepExecution [

	^ stepExecution
]

{ #category : 'accessing' }
LLMStepCompletedAnnouncement >> stepExecution: aStepExecution [

	stepExecution := aStepExecution
]
