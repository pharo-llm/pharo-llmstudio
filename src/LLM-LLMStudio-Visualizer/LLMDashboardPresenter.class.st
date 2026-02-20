Class {
	#name : 'LLMDashboardPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'tracer',
		'runListPresenter',
		'notebook',
		'flowPresenter',
		'executionTablePresenter',
		'conversationPresenter',
		'metricsPresenter',
		'toolbar',
		'statusBar'
	],
	#category : 'LLM-LLMStudio-Visualizer-UI',
	#package : 'LLM-LLMStudio-Visualizer',
	#tag : 'UI'
}

{ #category : 'opening' }
LLMDashboardPresenter class >> openOn: aTracer [
	"Open the dashboard on a pipeline tracer."

	^ (self new
		   tracer: aTracer;
		   yourself) open
]

{ #category : 'opening' }
LLMDashboardPresenter class >> openOnPipeline: aPipeline [
	"Convenience: create a tracer and open the dashboard."

	| tracer |
	tracer := LLMPipelineTracer on: aPipeline.
	^ self openOn: tracer
]

{ #category : 'private' }
LLMDashboardPresenter >> buildToolbar [

	^ self newToolbar
		  addItem: (SpToolbarButtonPresenter new
				   label: 'Refresh';
				   icon: (self iconNamed: #smallUpdate);
				   action: [ self refreshAll ];
				   yourself);
		  addItem: (SpToolbarButtonPresenter new
				   label: 'Clear';
				   icon: (self iconNamed: #smallDelete);
				   action: [ self clearTraces ];
				   yourself);
		  addItem: (SpToolbarButtonPresenter new
				   label: 'Export';
				   icon: (self iconNamed: #smallSave);
				   action: [ self exportTrace ];
				   yourself);
		  yourself
]

{ #category : 'actions' }
LLMDashboardPresenter >> clearTraces [

	tracer ifNotNil: [
		tracer clearTraces.
		self refreshAll ]
]

{ #category : 'initialization' }
LLMDashboardPresenter >> connectPresenters [

	runListPresenter whenSelectionChangedDo: [ :selection |
		selection selectedItem ifNotNil: [ :trace |
			self showTrace: trace ] ]
]

{ #category : 'layout' }
LLMDashboardPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: toolbar expand: false;
		  add: (SpPanedLayout newLeftToRight
				   positionOfSlider: 30;
				   add: runListPresenter;
				   add: notebook;
				   yourself);
		  add: statusBar expand: false;
		  yourself
]

{ #category : 'actions' }
LLMDashboardPresenter >> exportTrace [
	"Export the selected trace as a text report."

	| trace report |
	trace := runListPresenter selectedItem.
	trace ifNil: [ ^ self ].
	report := self generateReport: trace.
	Clipboard clipboardText: report.
	self inform: 'Trace report copied to clipboard'
]

{ #category : 'private' }
LLMDashboardPresenter >> generateReport: aTrace [
	"Generate a text report for a trace."

	^ String streamContents: [ :s |
		  s
			  nextPutAll: '=== LLM Pipeline Execution Report ===';
			  cr;
			  nextPutAll: 'Pipeline: ';
			  nextPutAll: aTrace pipelineName;
			  cr;
			  nextPutAll: 'Status: ';
			  nextPutAll: aTrace statusLabel;
			  cr;
			  nextPutAll: 'Duration: ';
			  nextPutAll: aTrace totalDurationMs printString;
			  nextPutAll: 'ms';
			  cr;
			  nextPutAll: 'Total tokens: ';
			  nextPutAll: aTrace totalTokens printString;
			  cr;
			  nextPutAll: 'Steps: ';
			  nextPutAll: aTrace stepCount printString;
			  cr;
			  cr;
			  nextPutAll: '--- Step Details ---';
			  cr.
		  aTrace stepExecutions do: [ :step |
			  s
				  nextPutAll: step stepIndex printString;
				  nextPutAll: '. ';
				  nextPutAll: step stepName;
				  nextPutAll: ' (';
				  nextPutAll: step stepClassName;
				  nextPutAll: ') [';
				  nextPutAll: step status asString;
				  nextPutAll: '] ';
				  nextPutAll: step durationMs printString;
				  nextPutAll: 'ms';
				  cr.
			  s
				  nextPutAll: '   Input: ';
				  nextPutAll: (step input ifNil: [ 'nil' ]) printString truncateTo: 200;
				  cr.
			  s
				  nextPutAll: '   Output: ';
				  nextPutAll: (step output ifNil: [ 'nil' ]) printString truncateTo: 200;
				  cr.
			  step totalTokens > 0 ifTrue: [
				  s
					  nextPutAll: '   Tokens: ';
					  nextPutAll: step totalTokens printString;
					  cr ].
			  step isError ifTrue: [
				  s
					  nextPutAll: '   ERROR: ';
					  nextPutAll: (step error ifNil: [ 'unknown' ]);
					  cr ].
			  s cr ] ]
]

{ #category : 'initialization' }
LLMDashboardPresenter >> initializePresenters [

	toolbar := self buildToolbar.

	runListPresenter := LLMRunListPresenter new.

	flowPresenter := LLMPipelineFlowPresenter new.
	executionTablePresenter := LLMExecutionTablePresenter new.
	conversationPresenter := LLMConversationPresenter new.
	metricsPresenter := LLMMetricsPresenter new.

	notebook := self newNotebook
		            addPageTitle: 'Pipeline Flow'
		            provider: [ flowPresenter ];
		            addPageTitle: 'Execution Steps'
		            provider: [ executionTablePresenter ];
		            addPageTitle: 'Conversation'
		            provider: [ conversationPresenter ];
		            addPageTitle: 'Metrics'
		            provider: [ metricsPresenter ];
		            yourself.

	statusBar := self newStatusBar.

	self subscribeToTracer
]

{ #category : 'initialization' }
LLMDashboardPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'LLM Studio - Pipeline Dashboard';
		initialExtent: 1200 @ 700;
		whenClosedDo: [ self unsubscribeFromTracer ]
]

{ #category : 'actions' }
LLMDashboardPresenter >> refreshAll [

	tracer ifNil: [ ^ self ].
	runListPresenter traces: tracer traces.
	tracer lastTrace ifNotNil: [ :t | self showTrace: t ]
]

{ #category : 'actions' }
LLMDashboardPresenter >> showTrace: aTrace [
	"Update all panels with the selected trace."

	flowPresenter trace: aTrace.
	executionTablePresenter trace: aTrace.
	conversationPresenter trace: aTrace.
	metricsPresenter trace: aTrace
]

{ #category : 'private' }
LLMDashboardPresenter >> subscribeToTracer [

	tracer ifNil: [ ^ self ].
	tracer announcer
		when: LLMTraceCompletedAnnouncement
		do: [ :ann | self refreshAll ]
		for: self
]

{ #category : 'accessing' }
LLMDashboardPresenter >> tracer [

	^ tracer
]

{ #category : 'accessing' }
LLMDashboardPresenter >> tracer: aTracer [

	tracer := aTracer.
	self subscribeToTracer.
	self refreshAll
]

{ #category : 'private' }
LLMDashboardPresenter >> unsubscribeFromTracer [

	tracer ifNotNil: [
		tracer announcer unsubscribe: self ]
]
