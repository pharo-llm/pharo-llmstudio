Class {
	#name : 'LLMExecutionTablePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'table',
		'detailPresenter',
		'headerLabel',
		'trace'
	],
	#category : 'LLM-LLMStudio-Visualizer-UI',
	#package : 'LLM-LLMStudio-Visualizer',
	#tag : 'UI'
}

{ #category : 'initialization' }
LLMExecutionTablePresenter >> connectPresenters [

	table whenSelectionChangedDo: [ :selection |
		selection selectedItem ifNotNil: [ :step |
			detailPresenter stepExecution: step ] ]
]

{ #category : 'layout' }
LLMExecutionTablePresenter >> defaultLayout [

	^ SpPanedLayout newTopToBottom
		  positionOfSlider: 50;
		  add: (SpBoxLayout newTopToBottom
				   spacing: 4;
				   add: headerLabel expand: false;
				   add: table;
				   yourself);
		  add: detailPresenter;
		  yourself
]

{ #category : 'initialization' }
LLMExecutionTablePresenter >> initializePresenters [

	headerLabel := self newLabel label: 'Execution Steps'.

	table := self newTable
		         addColumn:
			         (SpStringTableColumn
				          title: '#'
				          evaluated: [ :step | step stepIndex printString ]);
		         addColumn:
			         (SpStringTableColumn
				          title: 'Status'
				          evaluated: [ :step | step statusLabel ]);
		         addColumn:
			         (SpStringTableColumn
				          title: 'Step Name'
				          evaluated: [ :step | step stepName ]);
		         addColumn:
			         (SpStringTableColumn
				          title: 'Type'
				          evaluated: [ :step | step stepClassName ]);
		         addColumn:
			         (SpStringTableColumn
				          title: 'Duration'
				          evaluated: [ :step |
					          step durationMs printString , 'ms' ]);
		         addColumn:
			         (SpStringTableColumn
				          title: 'In Tokens'
				          evaluated: [ :step |
					          step inputTokens printString ]);
		         addColumn:
			         (SpStringTableColumn
				          title: 'Out Tokens'
				          evaluated: [ :step |
					          step outputTokens printString ]);
		         addColumn:
			         (SpStringTableColumn
				          title: 'Output Preview'
				          evaluated: [ :step |
					          (step output ifNil: [ '' ]) printString
						          truncateTo: 80 ]);
		         yourself.

	detailPresenter := LLMStepDetailPresenter new
]

{ #category : 'accessing' }
LLMExecutionTablePresenter >> trace: anExecutionTrace [

	trace := anExecutionTrace.
	trace
		ifNil: [ table items: #() ]
		ifNotNil: [ table items: trace stepExecutions asArray ]
]
