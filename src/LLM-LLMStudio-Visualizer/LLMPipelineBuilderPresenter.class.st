Class {
	#name : 'LLMPipelineBuilderPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'nameInput',
		'providerDropdown',
		'modelDropdown',
		'promptTemplateText',
		'temperatureInput',
		'maxTokensInput',
		'parserDropdown',
		'apiKeyInput',
		'ollamaHostInput',
		'ollamaPortInput',
		'createButton',
		'createAndRunButton',
		'cancelButton',
		'statusLabel',
		'onPipelineCreated',
		'onPipelineCreatedAndRun'
	],
	#category : 'LLM-LLMStudio-Visualizer-UI',
	#package : 'LLM-LLMStudio-Visualizer',
	#tag : 'UI'
}

{ #category : 'instance creation' }
LLMPipelineBuilderPresenter class >> open [
	"Open the pipeline builder as a standalone window."

	^ self new open
]

{ #category : 'instance creation' }
LLMPipelineBuilderPresenter class >> openWithCallback: aBlock [
	"Open the builder with a callback that receives the created pipeline."

	^ (self new
		   onPipelineCreated: aBlock;
		   yourself) open
]

{ #category : 'instance creation' }
LLMPipelineBuilderPresenter class >> openWithRunCallback: aBlock [
	"Open the builder with a callback that receives the pipeline and signals to run it."

	^ (self new
		   onPipelineCreatedAndRun: aBlock;
		   yourself) open
]

{ #category : 'as yet unclassified' }
LLMPipelineBuilderPresenter >> buildModel [
	"Create the LLM model based on the selected provider and model."

	| provider modelName model |
	provider := providerDropdown selectedItem.
	modelName := modelDropdown selectedItem.

	provider = 'OpenAI' ifTrue: [
		model := LLMOpenAIModel modelId: modelName.
		apiKeyInput text trimBoth ifNotEmpty: [ :key |
			model apiKeyManager registerKey: key forProvider: #openai ] ].

	provider = 'Anthropic' ifTrue: [
		model := LLMAnthropicModel modelId: modelName.
		apiKeyInput text trimBoth ifNotEmpty: [ :key |
			model apiKeyManager registerKey: key forProvider: #anthropic ] ].

	provider = 'Ollama' ifTrue: [
		model := LLMOllamaModel modelId: modelName.
		ollamaHostInput text trimBoth ifNotEmpty: [ :h |
			model host: h ].
		ollamaPortInput text trimBoth ifNotEmpty: [ :p |
			model port: p asInteger ] ].

	model configuration temperature: temperatureInput text trimBoth asNumber.
	model configuration maxTokens: maxTokensInput text trimBoth asInteger.
	^ model
]

{ #category : 'as yet unclassified' }
LLMPipelineBuilderPresenter >> buildParser [
	"Create the output parser based on the selected parser type."

	| parserType |
	parserType := parserDropdown selectedItem.
	parserType = 'None' ifTrue: [ ^ nil ].
	parserType = 'String' ifTrue: [ ^ LLMStringOutputParser new ].
	parserType = 'JSON' ifTrue: [ ^ LLMJsonOutputParser new ].
	parserType = 'List' ifTrue: [ ^ LLMListOutputParser new ].
	^ nil
]

{ #category : 'as yet unclassified' }
LLMPipelineBuilderPresenter >> buildPipeline [
	"Create a complete pipeline from the current form values."

	| pipeline model parser promptText |
	promptText := promptTemplateText text trimBoth.
	promptText ifEmpty: [
		statusLabel label: 'Error: Prompt template is required.'.
		^ nil ].

	pipeline := LLMPipeline new.
	pipeline name: nameInput text trimBoth ifEmpty: [ 'My Pipeline' ].

	"Add prompt step"
	pipeline addStep: (LLMPromptStep template: promptText).

	"Add model step"
	[
		model := self buildModel.
		pipeline addStep: (LLMModelStep model: model) ]
		on: Error
		do: [ :err |
			statusLabel label: 'Error building model: ' , err messageText.
			^ nil ].

	"Add parser step if selected"
	parser := self buildParser.
	parser ifNotNil: [
		pipeline addStep: (LLMParserStep parser: parser) ].

	statusLabel label: 'Pipeline "' , pipeline name , '" created successfully.'.
	^ pipeline
]

{ #category : 'as yet unclassified' }
LLMPipelineBuilderPresenter >> connectPresenters [

	providerDropdown whenSelectionChangedDo: [ :selection |
		self updateModelsForProvider: selection selectedItem.
		self updateProviderFields ]
]

{ #category : 'as yet unclassified' }
LLMPipelineBuilderPresenter >> createAndRunPipeline [
	"Build the pipeline and signal the dashboard to run it."

	| pipeline |
	pipeline := self buildPipeline.
	pipeline ifNil: [ ^ self ].
	onPipelineCreatedAndRun ifNotNil: [ :blk | blk value: pipeline ].
	self window ifNotNil: [ :w | w close ]
]

{ #category : 'as yet unclassified' }
LLMPipelineBuilderPresenter >> createPipeline [
	"Build the pipeline and pass it to the callback."

	| pipeline |
	pipeline := self buildPipeline.
	pipeline ifNil: [ ^ self ].
	onPipelineCreated ifNotNil: [ :blk | blk value: pipeline ].
	self window ifNotNil: [ :w | w close ]
]

{ #category : 'as yet unclassified' }
LLMPipelineBuilderPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 8;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 8;
				   add: (SpBoxLayout newTopToBottom
							spacing: 2;
							add: (self newLabel label: 'Pipeline Name') expand: false;
							add: nameInput expand: false;
							yourself);
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 8;
				   add: (SpBoxLayout newTopToBottom
							spacing: 2;
							add: (self newLabel label: 'Provider') expand: false;
							add: providerDropdown expand: false;
							yourself);
				   add: (SpBoxLayout newTopToBottom
							spacing: 2;
							add: (self newLabel label: 'Model') expand: false;
							add: modelDropdown expand: false;
							yourself);
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newTopToBottom
				   spacing: 2;
				   add: (self newLabel label: 'API Key (or set env var)') expand: false;
				   add: apiKeyInput expand: false;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 8;
				   add: (SpBoxLayout newTopToBottom
							spacing: 2;
							add: (self newLabel label: 'Ollama Host') expand: false;
							add: ollamaHostInput expand: false;
							yourself);
				   add: (SpBoxLayout newTopToBottom
							spacing: 2;
							add: (self newLabel label: 'Ollama Port') expand: false;
							add: ollamaPortInput expand: false;
							yourself);
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newTopToBottom
				   spacing: 2;
				   add: (self newLabel label: 'Prompt Template (use {variable} for inputs)') expand: false;
				   add: promptTemplateText;
				   yourself);
		  add: (SpBoxLayout newLeftToRight
				   spacing: 8;
				   add: (SpBoxLayout newTopToBottom
							spacing: 2;
							add: (self newLabel label: 'Temperature') expand: false;
							add: temperatureInput expand: false;
							yourself);
				   add: (SpBoxLayout newTopToBottom
							spacing: 2;
							add: (self newLabel label: 'Max Tokens') expand: false;
							add: maxTokensInput expand: false;
							yourself);
				   add: (SpBoxLayout newTopToBottom
							spacing: 2;
							add: (self newLabel label: 'Output Parser') expand: false;
							add: parserDropdown expand: false;
							yourself);
				   yourself)
		  expand: false;
		  add: statusLabel expand: false;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 8;
				   add: createButton;
				   add: createAndRunButton;
				   add: cancelButton;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : 'as yet unclassified' }
LLMPipelineBuilderPresenter >> initializePresenters [

	nameInput := self newTextInput.
	nameInput text: 'My Pipeline'.
	nameInput placeholder: 'Enter pipeline name'.

	providerDropdown := self newDropList.
	providerDropdown items: #( 'OpenAI' 'Anthropic' 'Ollama' ).
	providerDropdown display: [ :item | item ].

	modelDropdown := self newDropList.
	self updateModelsForProvider: 'OpenAI'.
	modelDropdown display: [ :item | item ].

	apiKeyInput := self newTextInput.
	apiKeyInput placeholder: 'sk-... or leave empty to use env var'.

	ollamaHostInput := self newTextInput.
	ollamaHostInput text: 'localhost'.
	ollamaHostInput placeholder: 'localhost'.

	ollamaPortInput := self newTextInput.
	ollamaPortInput text: '11434'.
	ollamaPortInput placeholder: '11434'.

	promptTemplateText := self newText.
	promptTemplateText text: 'Translate the following text to {language}: {text}'.

	temperatureInput := self newTextInput.
	temperatureInput text: '0.7'.

	maxTokensInput := self newTextInput.
	maxTokensInput text: '1024'.

	parserDropdown := self newDropList.
	parserDropdown items: #( 'String' 'None' 'JSON' 'List' ).
	parserDropdown display: [ :item | item ].

	statusLabel := self newLabel.
	statusLabel label: 'Configure your pipeline and click Create.'.

	createButton := self newButton.
	createButton
		label: 'Create Pipeline';
		icon: (self iconNamed: #smallAdd);
		action: [ self createPipeline ].

	createAndRunButton := self newButton.
	createAndRunButton
		label: 'Create & Run';
		icon: (self iconNamed: #smallDoIt);
		action: [ self createAndRunPipeline ].

	cancelButton := self newButton.
	cancelButton
		label: 'Cancel';
		icon: (self iconNamed: #smallCancel);
		action: [ self window ifNotNil: [ :w | w close ] ]
]

{ #category : 'as yet unclassified' }
LLMPipelineBuilderPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'LLM Studio - Pipeline Builder';
		initialExtent: 600 @ 550
]

{ #category : 'as yet unclassified' }
LLMPipelineBuilderPresenter >> onPipelineCreated: aBlock [

	onPipelineCreated := aBlock
]

{ #category : 'as yet unclassified' }
LLMPipelineBuilderPresenter >> onPipelineCreatedAndRun: aBlock [

	onPipelineCreatedAndRun := aBlock
]

{ #category : 'as yet unclassified' }
LLMPipelineBuilderPresenter >> updateModelsForProvider: aProviderString [
	"Update the model dropdown based on the selected provider."

	| models |
	aProviderString = 'OpenAI' ifTrue: [
		models := #( 'gpt-4o' 'gpt-4o-mini' 'gpt-4-turbo' 'gpt-4' ) ].
	aProviderString = 'Anthropic' ifTrue: [
		models := #( 'claude-3-5-sonnet-20241022' 'claude-3-opus-20240229' 'claude-3-haiku-20240307' ) ].
	aProviderString = 'Ollama' ifTrue: [
		models := #( 'llama3' 'mistral' 'codellama' 'phi' 'gemma' ) ].
	models ifNil: [ models := #( 'gpt-4o' ) ].
	modelDropdown items: models
]

{ #category : 'as yet unclassified' }
LLMPipelineBuilderPresenter >> updateProviderFields [
	"Show/hide fields based on the selected provider."

	"Ollama fields visibility is handled by layout; API key label contextual hint"
	| provider |
	provider := providerDropdown selectedItem.
	provider = 'Ollama'
		ifTrue: [ statusLabel label: 'Ollama: No API key required. Ensure Ollama is running locally.' ]
		ifFalse: [ statusLabel label: 'Configure your pipeline and click Create.' ]
]
