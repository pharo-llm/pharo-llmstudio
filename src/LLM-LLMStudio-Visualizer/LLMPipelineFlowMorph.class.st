Class {
	#name : 'LLMPipelineFlowMorph',
	#superclass : 'Morph',
	#instVars : [
		'trace',
		'stepBoxes',
		'boxWidth',
		'boxHeight',
		'horizontalGap',
		'verticalPadding',
		'selectedIndex'
	],
	#category : 'LLM-LLMStudio-Visualizer-UI',
	#package : 'LLM-LLMStudio-Visualizer',
	#tag : 'UI'
}

{ #category : 'instance creation' }
LLMPipelineFlowMorph class >> new [

	^ super new initialize
]

{ #category : 'instance creation' }
LLMPipelineFlowMorph class >> on: anExecutionTrace [

	^ self new
		  trace: anExecutionTrace;
		  yourself
]

{ #category : 'private' }
LLMPipelineFlowMorph >> arrowColor [

	^ Color gray darker
]

{ #category : 'private' }
LLMPipelineFlowMorph >> colorForStatus: aStatus [

	aStatus = #success ifTrue: [ ^ Color fromHexString: '4CAF50' ].
	aStatus = #error ifTrue: [ ^ Color fromHexString: 'F44336' ].
	aStatus = #running ifTrue: [ ^ Color fromHexString: '2196F3' ].
	aStatus = #pending ifTrue: [ ^ Color fromHexString: '9E9E9E' ].
	^ Color fromHexString: 'BDBDBD'
]

{ #category : 'private' }
LLMPipelineFlowMorph >> computeRequiredExtent [
	"Calculate the total space needed."

	| executions rows cols totalWidth totalHeight |
	executions := trace ifNil: [ #() ] ifNotNil: [ trace stepExecutions ].
	executions ifEmpty: [ ^ 400 @ 200 ].

	cols := (executions size min: 5).
	rows := (executions size / cols) ceiling.
	totalWidth := (cols * (boxWidth + horizontalGap)) + horizontalGap.
	totalHeight := (rows * (boxHeight + verticalPadding)) + (verticalPadding * 2).
	^ totalWidth @ totalHeight
]

{ #category : 'drawing' }
LLMPipelineFlowMorph >> drawArrowFrom: startPoint to: endPoint on: aCanvas [
	"Draw a connector arrow between two step boxes."

	| midX |
	"If same row, draw horizontal arrow"
	(startPoint y closeTo: endPoint y)
		ifTrue: [
			aCanvas
				line: startPoint
				to: endPoint
				width: 2
				color: self arrowColor.
			"Arrow head"
			aCanvas
				line: endPoint
				to: endPoint - (8 @ 5)
				width: 2
				color: self arrowColor.
			aCanvas
				line: endPoint
				to: endPoint - (8 @ -5)
				width: 2
				color: self arrowColor ]
		ifFalse: [
			"Multi-row: draw L-shaped connector"
			midX := startPoint x.
			aCanvas
				line: startPoint
				to: midX @ endPoint y
				width: 2
				color: self arrowColor.
			aCanvas
				line: midX @ endPoint y
				to: endPoint
				width: 2
				color: self arrowColor ]
]

{ #category : 'drawing' }
LLMPipelineFlowMorph >> drawOn: aCanvas [
	"Draw the pipeline flow visualization."

	| executions x y cols col row prevRight prevBottom |
	super drawOn: aCanvas.

	"Background"
	aCanvas
		fillRectangle: self bounds
		color: (Color fromHexString: 'FAFAFA').

	trace ifNil: [
		self drawPlaceholderOn: aCanvas.
		^ self ].

	executions := trace stepExecutions.
	executions ifEmpty: [
		self drawPlaceholderOn: aCanvas.
		^ self ].

	cols := 5 min: executions size.
	stepBoxes := OrderedCollection new.
	prevRight := nil.
	prevBottom := nil.

	executions withIndexDo: [ :exec :idx |
		col := (idx - 1) \\ cols.
		row := (idx - 1) // cols.
		x := self bounds left + horizontalGap + (col * (boxWidth + horizontalGap)).
		y := self bounds top + verticalPadding + (row * (boxHeight + verticalPadding)).

		"Draw connector arrow from previous box"
		(idx > 1) ifTrue: [
			col > 0
				ifTrue: [ "Same row"
					self
						drawArrowFrom: prevRight @ (y + (boxHeight / 2))
						to: x @ (y + (boxHeight / 2))
						on: aCanvas ]
				ifFalse: [ "New row - connect from end of previous row"
					prevBottom ifNotNil: [
						self
							drawArrowFrom: prevRight @ prevBottom
							to: x @ y
							on: aCanvas ] ] ].

		"Draw the step box"
		self drawStepBox: exec at: x @ y index: idx on: aCanvas.
		stepBoxes add: (Rectangle left: x right: x + boxWidth top: y bottom: y + boxHeight).

		prevRight := x + boxWidth.
		prevBottom := y + boxHeight ]
]

{ #category : 'drawing' }
LLMPipelineFlowMorph >> drawPlaceholderOn: aCanvas [
	"Draw a placeholder when no trace data is available."

	| center |
	center := self bounds center.
	aCanvas
		drawString: 'No pipeline execution data'
		at: center - (100 @ 8)
		font: nil
		color: Color gray
]

{ #category : 'drawing' }
LLMPipelineFlowMorph >> drawStepBox: aStepExecution at: aPoint index: anIndex on: aCanvas [
	"Draw a single step box with status indicator, name, and timing."

	| boxRect statusColor nameStr timeStr isSelected borderColor textY |
	boxRect := aPoint extent: boxWidth @ boxHeight.
	statusColor := self colorForStatus: aStepExecution status.
	isSelected := selectedIndex = anIndex.
	borderColor := isSelected
		               ifTrue: [ Color fromHexString: '1565C0' ]
		               ifFalse: [ statusColor ].

	"Shadow"
	aCanvas
		fillRectangle: (boxRect translateBy: 2 @ 2)
		color: (Color gray alpha: 0.2).

	"Box background"
	aCanvas fillRectangle: boxRect color: Color white.

	"Status bar at top"
	aCanvas
		fillRectangle: (aPoint extent: boxWidth @ 4)
		color: statusColor.

	"Border"
	aCanvas
		frameRectangle: boxRect
		width: (isSelected ifTrue: [ 3 ] ifFalse: [ 1 ])
		color: borderColor.

	"Step index and name"
	textY := aPoint y + 10.
	nameStr := anIndex printString , '. '
	            , (aStepExecution stepName truncateTo: 18).
	aCanvas
		drawString: nameStr
		at: aPoint x + 8 @ textY
		font: nil
		color: Color black.

	"Class name"
	aCanvas
		drawString: (aStepExecution stepClassName truncateTo: 22)
		at: aPoint x + 8 @ (textY + 16)
		font: nil
		color: Color gray.

	"Duration"
	timeStr := aStepExecution durationMs printString , 'ms'.
	aCanvas
		drawString: timeStr
		at: aPoint x + 8 @ (textY + 32)
		font: nil
		color: Color darkGray.

	"Token count if available"
	aStepExecution totalTokens > 0 ifTrue: [
		aCanvas
			drawString: aStepExecution totalTokens printString , ' tok'
			at: aPoint x + 8 @ (textY + 48)
			font: nil
			color: (Color fromHexString: '1565C0') ].

	"Status icon"
	aCanvas
		drawString: aStepExecution statusLabel
		at: (aPoint x + boxWidth - 40) @ (textY)
		font: nil
		color: statusColor
]

{ #category : 'event handling' }
LLMPipelineFlowMorph >> handlesMouseDown: evt [

	^ true
]

{ #category : 'initialization' }
LLMPipelineFlowMorph >> initialize [

	super initialize.
	boxWidth := 180.
	boxHeight := 80.
	horizontalGap := 30.
	verticalPadding := 25.
	stepBoxes := OrderedCollection new.
	self extent: 800 @ 300.
	self color: (Color fromHexString: 'FAFAFA')
]

{ #category : 'event handling' }
LLMPipelineFlowMorph >> mouseDown: evt [
	"Handle click to select a step."

	| localPoint |
	localPoint := evt position.
	stepBoxes withIndexDo: [ :rect :idx |
		(rect containsPoint: localPoint) ifTrue: [
			selectedIndex := idx.
			self changed.
			^ self ] ].
	selectedIndex := nil.
	self changed
]

{ #category : 'accessing' }
LLMPipelineFlowMorph >> selectedIndex [

	^ selectedIndex
]

{ #category : 'accessing' }
LLMPipelineFlowMorph >> selectedStepExecution [

	(selectedIndex isNil or: [ trace isNil ]) ifTrue: [ ^ nil ].
	^ trace stepExecutions at: selectedIndex ifAbsent: [ nil ]
]

{ #category : 'accessing' }
LLMPipelineFlowMorph >> trace [

	^ trace
]

{ #category : 'accessing' }
LLMPipelineFlowMorph >> trace: anExecutionTrace [

	trace := anExecutionTrace.
	self extent: self computeRequiredExtent.
	self changed
]
