Class {
	#name : 'LLMModelConfigurationTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Models',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Models'
}

{ #category : 'tests' }
LLMModelConfigurationTest >> testDefaultValues [

	| config |
	config := LLMModelConfiguration new.
	self assert: config temperature equals: 0.7.
	self assert: config maxTokens equals: 1024
]

{ #category : 'tests' }
LLMModelConfigurationTest >> testCreativePreset [

	| config |
	config := LLMModelConfiguration creative.
	self assert: config temperature equals: 0.9.
	self assert: config topP equals: 0.95
]

{ #category : 'tests' }
LLMModelConfigurationTest >> testPrecisePreset [

	| config |
	config := LLMModelConfiguration precise.
	self assert: config temperature equals: 0.1.
	self assert: config topP equals: 0.1
]

{ #category : 'tests' }
LLMModelConfigurationTest >> testAsDictionary [

	| config dict |
	config := LLMModelConfiguration new.
	config temperature: 0.5.
	config maxTokens: 2048.
	dict := config asDictionary.
	self assert: (dict at: 'temperature') equals: 0.5.
	self assert: (dict at: 'max_tokens') equals: 2048
]

{ #category : 'tests' }
LLMModelConfigurationTest >> testStopSequences [

	| config dict |
	config := LLMModelConfiguration new.
	config stopSequences: #( '###' '---' ).
	dict := config asDictionary.
	self assert: (dict at: 'stop') equals: #( '###' '---' )
]

{ #category : 'tests' }
LLMModelConfigurationTest >> testExtraParameters [

	| config dict |
	config := LLMModelConfiguration new.
	config extraParameterAt: 'response_format' put: (Dictionary new
			 at: 'type' put: 'json_object';
			 yourself).
	dict := config asDictionary.
	self assert: ((dict at: 'response_format') at: 'type') equals: 'json_object'
]

{ #category : 'tests' }
LLMModelConfigurationTest >> testNilValuesNotIncluded [

	| config dict |
	config := LLMModelConfiguration new.
	dict := config asDictionary.
	self deny: (dict includesKey: 'top_p').
	self deny: (dict includesKey: 'frequency_penalty').
	self deny: (dict includesKey: 'presence_penalty')
]

{ #category : 'tests' }
LLMModelConfigurationTest >> testSeed [

	| config dict |
	config := LLMModelConfiguration new.
	config seed: 42.
	dict := config asDictionary.
	self assert: (dict at: 'seed') equals: 42
]
