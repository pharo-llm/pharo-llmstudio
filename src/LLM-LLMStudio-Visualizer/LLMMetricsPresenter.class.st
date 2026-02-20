Class {
	#name : 'LLMMetricsPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'summaryText',
		'stepBreakdownTable',
		'tokenBarMorphPresenter',
		'tokenBarMorph',
		'headerLabel',
		'trace'
	],
	#category : 'LLM-LLMStudio-Visualizer-UI',
	#package : 'LLM-LLMStudio-Visualizer',
	#tag : 'UI'
}

{ #category : 'private' }
LLMMetricsPresenter >> buildSummaryFor: aTrace [

	^ String streamContents: [ :s |
		  s
			  nextPutAll: '--- Pipeline Execution Summary ---';
			  cr; cr;
			  nextPutAll: 'Pipeline: ';
			  nextPutAll: aTrace pipelineName;
			  cr;
			  nextPutAll: 'Status: ';
			  nextPutAll: aTrace statusLabel;
			  cr;
			  nextPutAll: 'Total Duration: ';
			  nextPutAll: aTrace totalDurationMs printString;
			  nextPutAll: 'ms';
			  cr;
			  nextPutAll: 'Steps: ';
			  nextPutAll: aTrace stepCount printString;
			  nextPutAll: ' (';
			  nextPutAll: aTrace completedSteps size printString;
			  nextPutAll: ' succeeded, ';
			  nextPutAll: aTrace errorSteps size printString;
			  nextPutAll: ' failed)';
			  cr;
			  nextPutAll: 'Success Rate: ';
			  nextPutAll: aTrace successRate printString;
			  nextPutAll: '%';
			  cr;
			  nextPutAll: 'Avg Step Duration: ';
			  nextPutAll: aTrace avgStepDurationMs printString;
			  nextPutAll: 'ms';
			  cr; cr;
			  nextPutAll: '--- Token Usage ---';
			  cr;
			  nextPutAll: 'Input Tokens: ';
			  nextPutAll: aTrace totalInputTokens printString;
			  cr;
			  nextPutAll: 'Output Tokens: ';
			  nextPutAll: aTrace totalOutputTokens printString;
			  cr;
			  nextPutAll: 'Total Tokens: ';
			  nextPutAll: aTrace totalTokens printString;
			  cr; cr;
			  nextPutAll: '--- Input Variables ---';
			  cr.
		  aTrace inputVariables keysAndValuesDo: [ :k :v |
			  s
				  nextPutAll: '  ';
				  nextPutAll: k asString;
				  nextPutAll: ': ';
				  nextPutAll: v printString truncateTo: 100;
				  cr ].
		  s
			  cr;
			  nextPutAll: '--- Final Output ---';
			  cr;
			  nextPutAll:
				  (aTrace finalOutput ifNil: [ '(none)' ]) printString
					  truncateTo: 500 ]
]

{ #category : 'layout' }
LLMMetricsPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: headerLabel expand: false;
		  add: (SpPanedLayout newLeftToRight
				   positionOfSlider: 45;
				   add: (SpBoxLayout newTopToBottom
						    add: (self newLabel label: 'Summary') expand: false;
						    add: summaryText;
						    yourself);
				   add: (SpBoxLayout newTopToBottom
						    add: (self newLabel label: 'Per-Step Breakdown')
						    expand: false;
						    add: stepBreakdownTable;
						    add: tokenBarMorphPresenter;
						    yourself);
				   yourself);
		  yourself
]

{ #category : 'initialization' }
LLMMetricsPresenter >> initializePresenters [

	headerLabel := self newLabel label: 'Metrics & Performance'.

	summaryText := self newText
		               beNotEditable;
		               yourself.

	stepBreakdownTable := self newTable
		                      addColumn:
			                      (SpStringTableColumn
				                       title: 'Step'
				                       evaluated: [ :step | step stepName ]);
		                      addColumn:
			                      (SpStringTableColumn
				                       title: 'Duration'
				                       evaluated: [ :step |
					                       step durationMs printString , 'ms' ]);
		                      addColumn:
			                      (SpStringTableColumn
				                       title: '% Time'
				                       evaluated: [ :step |
					                       self percentTimeFor: step ]);
		                      addColumn:
			                      (SpStringTableColumn
				                       title: 'Tokens'
				                       evaluated: [ :step |
					                       step totalTokens printString ]);
		                      addColumn:
			                      (SpStringTableColumn
				                       title: '% Tokens'
				                       evaluated: [ :step |
					                       self percentTokensFor: step ]);
		                      yourself.

	tokenBarMorph := LLMTokenBarMorph new.
	tokenBarMorphPresenter := self newMorph morph: tokenBarMorph
]

{ #category : 'private' }
LLMMetricsPresenter >> percentTimeFor: aStep [

	| total |
	trace ifNil: [ ^ '0%' ].
	total := trace totalDurationMs.
	total = 0 ifTrue: [ ^ '0%' ].
	^ ((aStep durationMs / total * 100) asFloat round: 1) printString
	  , '%'
]

{ #category : 'private' }
LLMMetricsPresenter >> percentTokensFor: aStep [

	| total |
	trace ifNil: [ ^ '0%' ].
	total := trace totalTokens.
	total = 0 ifTrue: [ ^ '0%' ].
	^ ((aStep totalTokens / total * 100) asFloat round: 1) printString
	  , '%'
]

{ #category : 'accessing' }
LLMMetricsPresenter >> trace: anExecutionTrace [

	trace := anExecutionTrace.
	trace
		ifNil: [
			summaryText text: ''.
			stepBreakdownTable items: #() ]
		ifNotNil: [
			summaryText text: (self buildSummaryFor: trace).
			stepBreakdownTable items: trace stepExecutions asArray.
			tokenBarMorph trace: trace.
			tokenBarMorphPresenter morph: tokenBarMorph ]
]
