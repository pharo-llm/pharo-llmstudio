Class {
	#name : 'LLMTokenBarMorph',
	#superclass : 'Morph',
	#instVars : [
		'trace',
		'barHeight',
		'barGap'
	],
	#category : 'LLM-LLMStudio-Visualizer-UI',
	#package : 'LLM-LLMStudio-Visualizer',
	#tag : 'UI'
}

{ #category : 'instance creation' }
LLMTokenBarMorph class >> new [

	^ super new initialize
]

{ #category : 'drawing' }
LLMTokenBarMorph >> drawBarForStep: aStep at: yPos maxTokens: maxTokens on: aCanvas [
	"Draw a single horizontal bar for a step's token usage."

	| inputWidth outputWidth totalWidth inputColor outputColor labelWidth |
	inputColor := Color fromHexString: '42A5F5'.
	outputColor := Color fromHexString: 'FFA726'.
	labelWidth := 120.

	maxTokens = 0 ifTrue: [ ^ self ].

	totalWidth := self bounds width - labelWidth - 80.
	inputWidth := (aStep inputTokens / maxTokens * totalWidth) ceiling.
	outputWidth := (aStep outputTokens / maxTokens * totalWidth) ceiling.

	"Step name label"
	aCanvas
		drawString: (aStep stepName truncateTo: 16)
		at: self bounds left + 4 @ (yPos + 2)
		font: nil
		color: Color black.

	"Input tokens bar (blue)"
	inputWidth > 0 ifTrue: [
		aCanvas
			fillRectangle:
			(self bounds left + labelWidth @ yPos extent:
				 inputWidth @ barHeight)
			color: inputColor ].

	"Output tokens bar (orange)"
	outputWidth > 0 ifTrue: [
		aCanvas
			fillRectangle:
			(self bounds left + labelWidth + inputWidth @ yPos extent:
				 outputWidth @ barHeight)
			color: outputColor ].

	"Token count label"
	aCanvas
		drawString:
		aStep inputTokens printString , '/' , aStep outputTokens printString
		at: self bounds left + labelWidth + inputWidth + outputWidth + 4
			@ (yPos + 2)
		font: nil
		color: Color darkGray
]

{ #category : 'drawing' }
LLMTokenBarMorph >> drawLegendOn: aCanvas [
	"Draw the color legend."

	| y x |
	y := self bounds top + 4.
	x := self bounds left + 4.

	aCanvas fillRectangle: (x @ y extent: 12 @ 12) color: (Color fromHexString: '42A5F5').
	aCanvas drawString: 'Input Tokens' at: x + 16 @ (y + 1) font: nil color: Color darkGray.

	aCanvas fillRectangle: (x + 130 @ y extent: 12 @ 12) color: (Color fromHexString: 'FFA726').
	aCanvas drawString: 'Output Tokens' at: x + 146 @ (y + 1) font: nil color: Color darkGray
]

{ #category : 'drawing' }
LLMTokenBarMorph >> drawOn: aCanvas [

	| executions maxTokens yPos |
	super drawOn: aCanvas.

	aCanvas fillRectangle: self bounds color: Color white.

	trace ifNil: [ ^ self ].

	executions := trace stepExecutions select: [ :s | s totalTokens > 0 ].
	executions ifEmpty: [
		aCanvas
			drawString: 'No token usage data'
			at: self bounds center - (60 @ 8)
			font: nil
			color: Color gray.
		^ self ].

	self drawLegendOn: aCanvas.

	maxTokens := (executions collect: [ :s |
		              s inputTokens max: s outputTokens ]) max.
	maxTokens = 0 ifTrue: [ ^ self ].

	yPos := self bounds top + 24.
	executions do: [ :step |
		self drawBarForStep: step at: yPos maxTokens: maxTokens on: aCanvas.
		yPos := yPos + barHeight + barGap ]
]

{ #category : 'initialization' }
LLMTokenBarMorph >> initialize [

	super initialize.
	barHeight := 20.
	barGap := 6.
	self extent: 500 @ 200.
	self color: Color white
]

{ #category : 'accessing' }
LLMTokenBarMorph >> trace [

	^ trace
]

{ #category : 'accessing' }
LLMTokenBarMorph >> trace: anExecutionTrace [

	| stepsWithTokens height |
	trace := anExecutionTrace.
	stepsWithTokens := trace
		                   ifNil: [ 0 ]
		                   ifNotNil: [
		                   (trace stepExecutions select: [ :s |
			                    s totalTokens > 0 ]) size ].
	height := 30 + (stepsWithTokens * (barHeight + barGap)).
	self extent: self width @ (height max: 60).
	self changed
]
