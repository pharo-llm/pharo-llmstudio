Class {
	#name : 'LLMConversationPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'messageList',
		'messageDetail',
		'headerLabel',
		'trace'
	],
	#category : 'LLM-LLMStudio-Visualizer-UI',
	#package : 'LLM-LLMStudio-Visualizer',
	#tag : 'UI'
}

{ #category : 'initialization' }
LLMConversationPresenter >> connectPresenters [

	messageList whenSelectionChangedDo: [ :selection |
		selection selectedItem ifNotNil: [ :msg |
			messageDetail text: msg content ] ]
]

{ #category : 'layout' }
LLMConversationPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: headerLabel expand: false;
		  add: (SpPanedLayout newTopToBottom
				   positionOfSlider: 60;
				   add: messageList;
				   add: messageDetail;
				   yourself);
		  yourself
]

{ #category : 'private' }
LLMConversationPresenter >> formatMessage: aMessage [
	"Format a chat message for display."

	| prefix |
	prefix := aMessage role asUppercase.
	^ '[' , prefix , '] '
	  , (aMessage content truncateTo: 120)
]

{ #category : 'initialization' }
LLMConversationPresenter >> initializePresenters [

	headerLabel := self newLabel label: 'Conversation History'.

	messageList := self newTable
		               addColumn:
			               (SpStringTableColumn
				                title: 'Role'
				                evaluated: [ :msg | msg role asUppercase ]);
		               addColumn:
			               (SpStringTableColumn
				                title: 'Content'
				                evaluated: [ :msg |
					                msg content truncateTo: 150 ]);
		               yourself.

	messageDetail := self newText
		                 beNotEditable;
		                 yourself
]

{ #category : 'accessing' }
LLMConversationPresenter >> trace: anExecutionTrace [

	trace := anExecutionTrace.
	trace
		ifNil: [ messageList items: #() ]
		ifNotNil: [
			| allMessages |
			allMessages := trace messages asArray.
			messageList items: allMessages.
			messageDetail text: '' ]
]
