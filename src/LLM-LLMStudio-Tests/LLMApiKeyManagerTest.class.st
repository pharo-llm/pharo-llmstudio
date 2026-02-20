Class {
	#name : 'LLMApiKeyManagerTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Connectors',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Connectors'
}

{ #category : 'tests' }
LLMApiKeyManagerTest >> testMissingKeyRaisesError [

	| manager |
	manager := LLMApiKeyManager new.
	self
		should: [ manager apiKeyFor: #nonexistent ]
		raise: LLMValidationError
]

{ #category : 'tests' }
LLMApiKeyManagerTest >> testMultipleProviders [

	| manager |
	manager := LLMApiKeyManager new.
	manager registerKey: 'sk-openai' forProvider: #openai.
	manager registerKey: 'sk-anthropic' forProvider: #anthropic.
	self assert: (manager apiKeyFor: #openai) equals: 'sk-openai'.
	self assert: (manager apiKeyFor: #anthropic) equals: 'sk-anthropic'
]

{ #category : 'tests' }
LLMApiKeyManagerTest >> testOverwriteKey [

	| manager |
	manager := LLMApiKeyManager new.
	manager registerKey: 'old-key' forProvider: #openai.
	manager registerKey: 'new-key' forProvider: #openai.
	self assert: (manager apiKeyFor: #openai) equals: 'new-key'
]

{ #category : 'tests' }
LLMApiKeyManagerTest >> testRegisterAndRetrieveKey [

	| manager |
	manager := LLMApiKeyManager new.
	manager registerKey: 'sk-test-123' forProvider: #openai.
	self assert: (manager apiKeyFor: #openai) equals: 'sk-test-123'
]

{ #category : 'tests' }
LLMApiKeyManagerTest >> testRemoveKey [

	| manager |
	manager := LLMApiKeyManager new.
	manager registerKey: 'sk-test' forProvider: #openai.
	manager removeKeyForProvider: #openai.
	"Should now raise an error since key is removed and env var unlikely to exist"
	self
		should: [ manager apiKeyFor: #openai ]
		raise: LLMValidationError
]
