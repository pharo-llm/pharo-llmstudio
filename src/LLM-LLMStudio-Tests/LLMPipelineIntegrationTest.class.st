Class {
	#name : 'LLMPipelineIntegrationTest',
	#superclass : 'TestCase',
	#category : 'LLM-LLMStudio-Tests-Integration',
	#package : 'LLM-LLMStudio-Tests',
	#tag : 'Integration'
}

{ #category : 'tests' }
LLMPipelineIntegrationTest >> testChatPromptPipeline [
	"Pipeline with chat prompt template"

	| chatTemplate pipeline result mockModel |
	chatTemplate := LLMChatPromptTemplate new
		                addSystemMessage: 'You are a translator. Translate to {language}.';
		                addUserMessage: '{text}';
		                yourself.
	mockModel := LLMMockModel respondingWith: 'Hola mundo'.
	pipeline := LLMPipeline new
		            addStep: (LLMPromptStep chatTemplate: chatTemplate);
		            addStep: (LLMModelStep model: mockModel);
		            addStep: (LLMParserStep parser: LLMStringOutputParser new);
		            yourself.
	result := pipeline runWith: {
			          (#language -> 'Spanish').
			          (#text -> 'Hello world') } asDictionary.
	self assert: result output equals: 'Hola mundo'.

	"Verify messages were sent correctly"
	self assert: mockModel callCount equals: 1.
	self assert: mockModel lastCapturedMessages size equals: 2.
	self assert: mockModel lastCapturedMessages first isSystem
]

{ #category : 'tests' }
LLMPipelineIntegrationTest >> testConditionalPipeline [
	"Pipeline with conditional branching"

	| pipeline result |
	pipeline := LLMPipeline new
		            addStep: (LLMConditionalStep
					             condition: [ :ctx | (ctx at: #format) = 'json' ]
					             ifTrue: (LLMPipeline new
							              addStep: (LLMPromptStep template: 'Return JSON for: {query}');
							              addStep: (LLMModelStep model:
										               (LLMMockModel respondingWith: '{"answer": "42"}'));
							              addStep:
								              (LLMParserStep parser: LLMJsonOutputParser new);
							              yourself)
					             ifFalse: (LLMPipeline new
							              addStep: (LLMPromptStep template: 'Answer: {query}');
							              addStep: (LLMModelStep model:
										               (LLMMockModel respondingWith: 'The answer is 42'));
							              addStep: (LLMParserStep parser:
										               LLMStringOutputParser new);
							              yourself));
		            yourself.
	result := pipeline runWith: {
			          (#format -> 'json').
			          (#query -> 'What is 6*7?') } asDictionary.
	self assert: (result output at: 'answer') equals: '42'
]

{ #category : 'tests' }
LLMPipelineIntegrationTest >> testMapWithModelPipeline [
	"Map a pipeline over multiple items"

	| itemPipeline mapStep result |
	itemPipeline := LLMPipeline new
		                addStep: (LLMBlockStep block: [ :ctx |
					                 ctx at: #prompt put: 'Process: ' , ctx output asString.
					                 ctx ]);
		                addStep: (LLMModelStep model:
						                 (LLMMockModel respondingWith: 'processed'));
		                yourself.
	mapStep := LLMMapStep step: itemPipeline.
	result := mapStep runWith:
		          { (#items -> #( 'item1' 'item2' 'item3' )) } asDictionary.
	self assert: result output size equals: 3.
	self assert: (result output allSatisfy: [ :r | r = 'processed' ])
]

{ #category : 'tests' }
LLMPipelineIntegrationTest >> testMemoryWithMockModel [
	"Pipeline with memory tracking conversation"

	| memory mockModel memoryStep modelStep pipeline result |
	memory := LLMBufferMemory withSystemMessage: 'You are helpful.'.
	mockModel := LLMMockModel respondingWithSequence: #( 'Response 1' 'Response 2' ).
	memoryStep := LLMMemoryStep memory: memory.
	modelStep := LLMModelStep model: mockModel.

	"First turn"
	pipeline := LLMPipeline new
		            addStep: memoryStep;
		            addStep: modelStep;
		            yourself.
	result := pipeline runWith: { (#input -> 'Hello') } asDictionary.
	self assert: result output equals: 'Response 1'.

	"Record assistant response"
	memoryStep recordAssistantOutput: result.

	"Second turn"
	result := pipeline runWith: { (#input -> 'Follow up') } asDictionary.
	self assert: result output equals: 'Response 2'.

	"Memory should have system + 2 user + 1 assistant = 4 messages sent"
	self assert: memory size equals: 3.
	self assert: mockModel callCount equals: 2
]

{ #category : 'tests' }
LLMPipelineIntegrationTest >> testMockModelCapturesRequests [

	| mockModel pipeline |
	mockModel := LLMMockModel respondingWith: 'response'.
	pipeline := LLMPipeline new
		            addStep: (LLMPromptStep template: 'Hello {name}');
		            addStep: (LLMModelStep model: mockModel);
		            yourself.
	pipeline runWith: { (#name -> 'World') } asDictionary.
	self assert: mockModel callCount equals: 1.
	self assert: mockModel capturedRequests size equals: 1
]

{ #category : 'tests' }
LLMPipelineIntegrationTest >> testParallelBranchesMerging [
	"Parallel execution with result merging"

	| pipeline result |
	pipeline := LLMPipeline new
		            addStep: (LLMParallelStep new
					             addBranch: #upper step: (LLMBlockStep block: [ :ctx |
								              ctx output: 'HELLO'.
								              ctx ]);
					             addBranch: #lower step: (LLMBlockStep block: [ :ctx |
								              ctx output: 'hello'.
								              ctx ]);
					             yourself);
		            addStep: (LLMBlockStep block: [ :ctx |
					             | results |
					             results := ctx output.
					             ctx output:
						             (results at: #upper) , ' - ' , (results at: #lower).
					             ctx ]);
		            yourself.
	result := pipeline runWith: Dictionary new.
	self assert: result output equals: 'HELLO - hello'
]

{ #category : 'tests' }
LLMPipelineIntegrationTest >> testPipelineChaining [
	"Chain two pipelines using then:"

	| translate summarize combined result |
	translate := LLMPipeline new
		             addStep:
			             (LLMPromptStep template: 'Translate: {text}');
		             addStep: (LLMModelStep model:
					              (LLMMockModel respondingWith: 'Texte traduit'));
		             addStep:
			             (LLMParserStep parser: LLMStringOutputParser new);
		             yourself.
	summarize := LLMBlockStep block: [ :ctx |
		             ctx
			             output: 'Summary: ' , ctx output asString;
			             yourself ].
	combined := translate then: summarize.
	result := combined runWith: {
			          (#text -> 'Hello world') } asDictionary.
	self assert: result output equals: 'Summary: Texte traduit'
]

{ #category : 'tests' }
LLMPipelineIntegrationTest >> testPromptToModelToJsonParser [
	"Full pipeline with JSON parsing"

	| pipeline result |
	pipeline := LLMPipeline new
		            addStep: (LLMPromptStep template: 'Extract entities from: {text}');
		            addStep: (LLMModelStep model:
						         (LLMMockModel respondingWith: '{"entities": ["Paris", "France"]}'));
		            addStep: (LLMParserStep parser: (LLMJsonOutputParser extractKey: 'entities'));
		            yourself.
	result := pipeline runWith: { (#text -> 'Paris is the capital of France') } asDictionary.
	self assert: result output equals: #( 'Paris' 'France' )
]

{ #category : 'tests' }
LLMPipelineIntegrationTest >> testPromptToModelToParser [
	"Full pipeline: prompt template -> mock model -> string parser"

	| pipeline result |
	pipeline := LLMPipeline new
		            addStep: (LLMPromptStep template: 'Translate to {language}: {text}');
		            addStep: (LLMModelStep model: (LLMMockModel respondingWith: 'Bonjour le monde'));
		            addStep: (LLMParserStep parser: LLMStringOutputParser new);
		            yourself.
	result := pipeline runWith: {
			          (#language -> 'French').
			          (#text -> 'Hello world') } asDictionary.
	self assert: result output equals: 'Bonjour le monde'
]
