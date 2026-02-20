Class {
	#name : 'LLMResponseTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Core',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Core'
}

{ #category : 'tests' }
LLMResponseTest >> testCreateWithContent [

	| response |
	response := LLMResponse content: 'Hello World'.
	self assert: response content equals: 'Hello World'.
	self deny: response hasToolCalls
]

{ #category : 'tests' }
LLMResponseTest >> testDefaultTokens [

	| response |
	response := LLMResponse new.
	self assert: response inputTokens equals: 0.
	self assert: response outputTokens equals: 0.
	self assert: response totalTokens equals: 0
]

{ #category : 'tests' }
LLMResponseTest >> testFromAnthropicDictionary [

	| dict response |
	dict := Dictionary new.
	dict at: 'content' put: {
			(Dictionary new
				 at: 'type' put: 'text';
				 at: 'text' put: 'Anthropic response';
				 yourself) }.
	dict at: 'role' put: 'assistant'.
	dict at: 'stop_reason' put: 'end_turn'.
	dict at: 'model' put: 'claude-3'.
	dict at: 'usage' put: (Dictionary new
			 at: 'input_tokens' put: 15;
			 at: 'output_tokens' put: 25;
			 yourself).
	response := LLMResponse fromDictionary: dict.
	self assert: response content equals: 'Anthropic response'.
	self assert: response role equals: 'assistant'.
	self assert: response inputTokens equals: 15.
	self assert: response outputTokens equals: 25
]

{ #category : 'tests' }
LLMResponseTest >> testFromOpenAIDictionary [

	| dict response |
	dict := Dictionary new.
	dict at: 'choices' put: {
			(Dictionary new
				 at: 'message'
				 put: (Dictionary new
						  at: 'role' put: 'assistant';
						  at: 'content' put: 'OpenAI response';
						  yourself);
				 at: 'finish_reason' put: 'stop';
				 yourself) }.
	dict at: 'model' put: 'gpt-4'.
	dict at: 'usage' put: (Dictionary new
			 at: 'prompt_tokens' put: 10;
			 at: 'completion_tokens' put: 20;
			 yourself).
	response := LLMResponse fromDictionary: dict.
	self assert: response content equals: 'OpenAI response'.
	self assert: response role equals: 'assistant'.
	self assert: response finishReason equals: 'stop'.
	self assert: response model equals: 'gpt-4'.
	self assert: response inputTokens equals: 10.
	self assert: response outputTokens equals: 20.
	self assert: response totalTokens equals: 30
]

{ #category : 'tests' }
LLMResponseTest >> testToolCalls [

	| response |
	response := LLMResponse new.
	self deny: response hasToolCalls.
	response toolCalls: {
			(Dictionary new
				 at: 'name' put: 'search';
				 yourself) }.
	self assert: response hasToolCalls
]
