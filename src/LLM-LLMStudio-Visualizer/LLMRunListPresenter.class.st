Class {
	#name : 'LLMRunListPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'table',
		'headerLabel'
	],
	#category : 'LLM-LLMStudio-Visualizer-UI',
	#package : 'LLM-LLMStudio-Visualizer',
	#tag : 'UI'
}

{ #category : 'layout' }
LLMRunListPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: headerLabel expand: false;
		  add: table;
		  yourself
]

{ #category : 'initialization' }
LLMRunListPresenter >> initializePresenters [

	headerLabel := self newLabel label: 'Pipeline Runs'.

	table := self newTable
		         addColumn:
			         (SpStringTableColumn
				          title: 'Status'
				          evaluated: [ :trace | trace statusLabel ]);
		         addColumn:
			         (SpStringTableColumn
				          title: 'Pipeline'
				          evaluated: [ :trace | trace pipelineName ]);
		         addColumn:
			         (SpStringTableColumn
				          title: 'Steps'
				          evaluated: [ :trace | trace stepCount printString ]);
		         addColumn:
			         (SpStringTableColumn
				          title: 'Duration'
				          evaluated: [ :trace |
					          trace totalDurationMs printString , 'ms' ]);
		         addColumn:
			         (SpStringTableColumn
				          title: 'Tokens'
				          evaluated: [ :trace | trace totalTokens printString ]);
		         yourself
]

{ #category : 'accessing' }
LLMRunListPresenter >> selectedItem [

	^ table selectedItem
]

{ #category : 'accessing' }
LLMRunListPresenter >> traces: aCollection [

	table items: aCollection asArray reversed
]

{ #category : 'events' }
LLMRunListPresenter >> whenSelectionChangedDo: aBlock [

	table whenSelectionChangedDo: aBlock
]
