Class {
	#name : 'LLMRunInputPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'variableInputs',
		'runButton',
		'cancelButton',
		'statusLabel',
		'headerLabel',
		'onRun',
		'variableNames',
		'lastInputs'
	],
	#category : 'LLM-LLMStudio-Visualizer-UI',
	#package : 'LLM-LLMStudio-Visualizer',
	#tag : 'UI'
}

{ #category : 'as yet unclassified' }
LLMRunInputPresenter class >> openForVariables: aCollection onRun: aBlock [
	"Open the input dialog for the given variable names with a run callback."

	^ (self new
		   variableNames: aCollection;
		   onRun: aBlock;
		   yourself) open
]

{ #category : 'as yet unclassified' }
LLMRunInputPresenter class >> openForVariables: aCollection withDefaults: aDict onRun: aBlock [
	"Open with pre-filled default values."

	^ (self new
		   variableNames: aCollection;
		   lastInputs: aDict;
		   onRun: aBlock;
		   yourself) open
]

{ #category : 'private' }
LLMRunInputPresenter >> buildVariableFields [
	"Dynamically create text input fields for each variable."

	variableInputs := OrderedCollection new.
	variableNames do: [ :varName |
		| input |
		input := self newTextInput.
		input placeholder: 'Enter value for ' , varName.
		lastInputs ifNotNil: [
			(lastInputs includesKey: varName) ifTrue: [
				input text: (lastInputs at: varName) asString ] ].
		variableInputs add: (varName -> input) ]
]

{ #category : 'private' }
LLMRunInputPresenter >> collectInputs [
	"Collect all variable inputs into a dictionary."

	| inputs |
	inputs := Dictionary new.
	variableInputs do: [ :assoc |
		| value |
		value := assoc value text trimBoth.
		value ifEmpty: [
			statusLabel label: 'Error: Please fill in all variables.'.
			^ nil ].
		inputs at: assoc key put: value ].
	^ inputs
]

{ #category : 'private' }
LLMRunInputPresenter >> defaultLayout [

	| layout |
	layout := SpBoxLayout newTopToBottom spacing: 8.
	layout add: headerLabel expand: false.

	variableInputs ifNotNil: [
		variableInputs do: [ :assoc |
			layout
				add: (SpBoxLayout newTopToBottom
						 spacing: 2;
						 add: (self newLabel label: assoc key) expand: false;
						 add: assoc value expand: false;
						 yourself)
				expand: false ] ].

	layout add: statusLabel expand: false.
	layout
		add: (SpBoxLayout newLeftToRight
				 spacing: 8;
				 add: runButton;
				 add: cancelButton;
				 yourself)
		expand: false.

	^ layout
]

{ #category : 'private' }
LLMRunInputPresenter >> initializePresenters [ 

	headerLabel := self newLabel.
	headerLabel label: 'Enter input variables for pipeline execution:'.

	statusLabel := self newLabel.
	statusLabel label: 'Fill in all fields and click Run.'.

	runButton := self newButton.
	runButton
		label: 'Run Pipeline';
		icon: (self iconNamed: #smallDoIt);
		action: [ self runPipeline ].

	cancelButton := self newButton.
	cancelButton
		label: 'Cancel';
		icon: (self iconNamed: #smallCancel);
		action: [ self window ifNotNil: [ :w | w close ] ].

	variableInputs := OrderedCollection new
]

{ #category : 'private' }
LLMRunInputPresenter >> initializeWindow: aWindowPresenter [

	| height |
	height := 150 + (variableNames size * 55) min: 600.
	aWindowPresenter
		title: 'LLM Studio - Run Pipeline';
		initialExtent: 500 @ height
]

{ #category : 'private' }
LLMRunInputPresenter >> lastInputs [

	^ lastInputs
]

{ #category : 'private' }
LLMRunInputPresenter >> lastInputs: aDictionary [

	lastInputs := aDictionary
]

{ #category : 'private' }
LLMRunInputPresenter >> onRun: aBlock [

	onRun := aBlock
]

{ #category : 'private' }
LLMRunInputPresenter >> runPipeline [
	"Collect inputs and execute the pipeline."

	| inputs |
	inputs := self collectInputs.
	inputs ifNil: [ ^ self ].
	statusLabel label: 'Running pipeline...'.
	onRun ifNotNil: [ :blk | blk value: inputs ].
	self window ifNotNil: [ :w | w close ]
]

{ #category : 'private' }
LLMRunInputPresenter >> variableNames [

	^ variableNames
]

{ #category : 'private' }
LLMRunInputPresenter >> variableNames: aCollection [

	variableNames := aCollection asArray.
	self buildVariableFields
]
