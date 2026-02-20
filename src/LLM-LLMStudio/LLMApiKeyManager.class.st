Class {
	#name : 'LLMApiKeyManager',
	#superclass : 'Object',
	#instVars : [
		'keys'
	],
	#classInstVars : [
		'defaultInstance'
	],
	#category : 'LLM-LLMStudio-Connectors',
	#package : 'LLM-LLMStudio',
	#tag : 'Connectors'
}

{ #category : 'accessing' }
LLMApiKeyManager class >> default [

	^ defaultInstance ifNil: [ defaultInstance := self new ]
]

{ #category : 'instance creation' }
LLMApiKeyManager class >> new [

	^ super new initialize
]

{ #category : 'accessing' }
LLMApiKeyManager class >> reset [

	defaultInstance := nil
]

{ #category : 'accessing' }
LLMApiKeyManager >> apiKeyFor: aProvider [
	"Get the API key for a given provider name (e.g., #openai, #anthropic, #ollama).
	 First checks instance storage, then falls back to environment variables."

	^ keys
		  at: aProvider asSymbol
		  ifAbsent: [ self apiKeyFromEnvironment: aProvider ]
]

{ #category : 'private' }
LLMApiKeyManager >> apiKeyFromEnvironment: aProvider [
	"Look up API key from environment variables.
	 Conventions: OPENAI_API_KEY, ANTHROPIC_API_KEY, etc."

	| envVar |
	envVar := aProvider asUppercase , '_API_KEY'.
	^ OSEnvironment current
		  at: envVar
		  ifAbsent: [
			  LLMValidationError signal:
				  'No API key found for provider: ' , aProvider asString
				  , '. Set ' , envVar , ' environment variable or register the key.' ]
]

{ #category : 'initialization' }
LLMApiKeyManager >> initialize [

	keys := Dictionary new
]

{ #category : 'accessing' }
LLMApiKeyManager >> keys [

	^ keys
]

{ #category : 'printing' }
LLMApiKeyManager >> printOn: aStream [

	aStream
		nextPutAll: 'LLMApiKeyManager(';
		print: keys size;
		nextPutAll: ' providers)'
]

{ #category : 'accessing' }
LLMApiKeyManager >> registerKey: aString forProvider: aProvider [
	"Register an API key for a provider."

	keys at: aProvider asSymbol put: aString
]

{ #category : 'accessing' }
LLMApiKeyManager >> removeKeyForProvider: aProvider [

	keys removeKey: aProvider asSymbol ifAbsent: [  ]
]
