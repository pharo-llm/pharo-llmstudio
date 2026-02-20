Class {
	#name : 'LLMStepDetailPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'headerLabel',
		'inputText',
		'outputText',
		'infoText',
		'inputLabel',
		'outputLabel'
	],
	#category : 'LLM-LLMStudio-Visualizer-UI',
	#package : 'LLM-LLMStudio-Visualizer',
	#tag : 'UI'
}

{ #category : 'layout' }
LLMStepDetailPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: headerLabel expand: false;
		  add: infoText expand: false;
		  add: (SpPanedLayout newLeftToRight
				   positionOfSlider: 50;
				   add: (SpBoxLayout newTopToBottom
						    add: inputLabel expand: false;
						    add: inputText;
						    yourself);
				   add: (SpBoxLayout newTopToBottom
						    add: outputLabel expand: false;
						    add: outputText;
						    yourself);
				   yourself);
		  yourself
]

{ #category : 'private' }
LLMStepDetailPresenter >> formatInfoFor: aStepExecution [

	^ String streamContents: [ :s |
		  s
			  nextPutAll: 'Step: ';
			  nextPutAll: aStepExecution stepName;
			  nextPutAll: '  |  Type: ';
			  nextPutAll: aStepExecution stepClassName;
			  nextPutAll: '  |  Status: ';
			  nextPutAll: aStepExecution status asString;
			  nextPutAll: '  |  Duration: ';
			  nextPutAll: aStepExecution durationMs printString;
			  nextPutAll: 'ms'.
		  aStepExecution totalTokens > 0 ifTrue: [
			  s
				  nextPutAll: '  |  Tokens: ';
				  nextPutAll: aStepExecution inputTokens printString;
				  nextPutAll: ' in / ';
				  nextPutAll: aStepExecution outputTokens printString;
				  nextPutAll: ' out' ].
		  aStepExecution isError ifTrue: [
			  s
				  nextPutAll: '  |  Error: ';
				  nextPutAll: (aStepExecution error ifNil: [ 'unknown' ]) ] ]
]

{ #category : 'initialization' }
LLMStepDetailPresenter >> initializePresenters [

	headerLabel := self newLabel label: 'Step Details'.
	infoText := self newLabel label: 'Select a step to view details'.

	inputLabel := self newLabel label: 'Input'.
	outputLabel := self newLabel label: 'Output'.

	inputText := self newText
		             beNotEditable;
		             yourself.
	outputText := self newText
		              beNotEditable;
		              yourself
]

{ #category : 'accessing' }
LLMStepDetailPresenter >> stepExecution: aStepExecution [

	aStepExecution
		ifNil: [
			infoText label: 'Select a step to view details'.
			inputText text: ''.
			outputText text: '' ]
		ifNotNil: [
			infoText label: (self formatInfoFor: aStepExecution).
			inputText text:
				(aStepExecution input ifNil: [ '(no input)' ]) printString.
			outputText text:
				(aStepExecution output ifNil: [ '(no output)' ]) printString ]
]
