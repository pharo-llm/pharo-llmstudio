Class {
	#name : 'LLMTraceCompletedAnnouncement',
	#superclass : 'Announcement',
	#instVars : [
		'trace'
	],
	#category : 'LLM-LLMStudio-Visualizer-Events',
	#package : 'LLM-LLMStudio-Visualizer',
	#tag : 'Events'
}

{ #category : 'accessing' }
LLMTraceCompletedAnnouncement >> trace [

	^ trace
]

{ #category : 'accessing' }
LLMTraceCompletedAnnouncement >> trace: anExecutionTrace [

	trace := anExecutionTrace
]
