[![Pharo 13 & 14](https://img.shields.io/badge/Pharo-13%20%7C%2014-2c98f0.svg)](https://github.com/pharo-llm/pharo-llmstudio)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/pharo-llm/pharo-llmstudio/blob/master/LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/pharo-llm/pharo-llmstudio/pulls)
[![Status: Active](https://img.shields.io/badge/status-active-success.svg)](https://github.com/pharo-llm/pharo-llmstudio/)
[![CI](https://github.com/pharo-llm/pharo-llmstudio/actions/workflows/CI.yml/badge.svg)](https://github.com/pharo-llm/pharo-llmstudio/actions/workflows/CI.yml)

# Pharo-LLMStudio

A professional LLM pipeline framework for Pharo Smalltalk. Build composable, reusable AI workflows with support for multiple LLM providers (OpenAI, Anthropic, Ollama), prompt templating, output parsing, memory management, tool calling, and advanced pipeline orchestration.

## Installation

```smalltalk
Metacello new
    baseline: 'LLMStudio';
    repository: 'github://pharo-llm/pharo-llmstudio:main/src';
    load.
```

To load only the core (without tests):

```smalltalk
Metacello new
    baseline: 'LLMStudio';
    repository: 'github://pharo-llm/pharo-llmstudio:main/src';
    load: 'Core'.
```

## Quick Start

```smalltalk
"1. Configure your API key"
LLMApiKeyManager default registerKey: 'sk-your-key' forProvider: #openai.

"2. Build a simple pipeline"
pipeline := LLMPipeline new
    addStep: (LLMPromptStep template: 'Translate to {language}: {text}');
    addStep: (LLMModelStep model: LLMOpenAIModel gpt4o);
    addStep: (LLMParserStep parser: LLMStringOutputParser new);
    yourself.

"3. Run it"
result := pipeline runWith: {
    #language -> 'French'.
    #text -> 'Hello world'
} asDictionary.

result output. "=> 'Bonjour le monde'"
```

## Architecture

LLMStudio is built around a pipeline architecture where each step transforms a shared context:

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  Prompt   │───>│  Model   │───>│  Parser  │───>│  Output  │
│   Step    │    │   Step   │    │   Step   │    │          │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
       │              │               │               │
       └──────────────┴───────────────┴───────────────┘
                    LLMPipelineContext
```

### Core Concepts

| Concept | Class | Description |
|---------|-------|-------------|
| **Pipeline** | `LLMPipeline` | Sequential chain of steps |
| **Context** | `LLMPipelineContext` | Shared state flowing through the pipeline |
| **Step** | `LLMPipelineStep` | Abstract base for all pipeline steps |

## Features

### Prompt Templates

Simple variable substitution with `{variable}` syntax:

```smalltalk
"Simple template"
template := LLMPromptTemplate template: 'Summarize: {text}'.
template format: { #text -> 'Long article...' } asDictionary.
"=> 'Summarize: Long article...'"

"Chat prompt with multiple messages"
chatTemplate := LLMChatPromptTemplate new
    addSystemMessage: 'You are a {role} specializing in {domain}.';
    addUserMessage: '{question}';
    yourself.

messages := chatTemplate format: {
    #role -> 'professor'.
    #domain -> 'physics'.
    #question -> 'What is quantum entanglement?'
} asDictionary.

"Partial templates (pre-fill some variables)"
template := (LLMPromptTemplate template: '{greeting} {name}!')
    partial: { #greeting -> 'Hello' } asDictionary.
template format: { #name -> 'World' } asDictionary.
"=> 'Hello World!'"
```

### Few-Shot Prompts

```smalltalk
fewShot := LLMFewShotPromptTemplate new.
fewShot prefix: 'Classify the sentiment of the following text:'.
fewShot suffix: 'Text: {input}\nSentiment:'.
fewShot exampleTemplate: 'Text: {input}\nSentiment: {output}'.
fewShot addExample: { #input -> 'I love this!'. #output -> 'positive' } asDictionary.
fewShot addExample: { #input -> 'This is terrible'. #output -> 'negative' } asDictionary.

prompt := fewShot format: { #input -> 'Pretty good actually' } asDictionary.
```

### LLM Providers

Three built-in providers with consistent API:

```smalltalk
"OpenAI"
openai := LLMOpenAIModel gpt4o.
openai configuration temperature: 0.3.

"Anthropic Claude"
claude := LLMAnthropicModel claude3Sonnet.
claude systemPrompt: 'You are a helpful coding assistant.'.

"Ollama (local)"
ollama := LLMOllamaModel llama3.
ollama host: 'localhost'.
ollama port: 11434.

"Model configuration presets"
model := LLMOpenAIModel gpt4o.
model configuration: LLMModelConfiguration creative.  "High temperature"
model configuration: LLMModelConfiguration precise.   "Low temperature"
```

### Output Parsers

Transform LLM text output into structured data:

```smalltalk
"String (with trimming)"
LLMStringOutputParser new parse: '  Hello World  '.
"=> 'Hello World'"

"JSON"
LLMJsonOutputParser new parse: '{"name": "Alice", "age": 30}'.
"=> a Dictionary('name'->'Alice', 'age'->30)"

"JSON with key extraction"
(LLMJsonOutputParser extractKey: 'answer') parse: '{"answer": "42"}'.
"=> '42'"

"Regex"
(LLMRegexOutputParser pattern: '\d+') parse: 'The answer is 42'.
"=> '42'"

"List (auto-strips markers)"
LLMListOutputParser new parse: '- Apple
- Banana
- Cherry'.
"=> #('Apple' 'Banana' 'Cherry')"
```

### Memory

Maintain conversation state across pipeline runs:

```smalltalk
"Full buffer memory"
memory := LLMBufferMemory withSystemMessage: 'You are a helpful tutor.'.

"Sliding window (keeps last N messages)"
memory := LLMSlidingWindowMemory windowSize: 20.
memory systemMessage: 'You are a helpful tutor.'.

"Use in a pipeline"
memoryStep := LLMMemoryStep memory: memory.
pipeline := LLMPipeline new
    addStep: memoryStep;
    addStep: (LLMModelStep model: myModel);
    yourself.

"First turn"
result := pipeline runWith: { #input -> 'What is Pharo?' } asDictionary.
memoryStep recordAssistantOutput: result.

"Second turn (memory preserves context)"
result := pipeline runWith: { #input -> 'Tell me more about its history.' } asDictionary.
memoryStep recordAssistantOutput: result.
```

### Tool Calling

Define tools that the LLM can invoke:

```smalltalk
"Define tools"
calculator := LLMTool
    name: 'calculator'
    description: 'Evaluate a mathematical expression'
    parameters: (Dictionary new
        at: 'type' put: 'object';
        at: 'properties' put: (Dictionary new
            at: 'expression' put: (Dictionary new
                at: 'type' put: 'string';
                at: 'description' put: 'The math expression to evaluate';
                yourself);
            yourself);
        yourself)
    block: [ :input |
        Compiler evaluate: (input at: 'expression') ].

"Tool registry"
registry := LLMToolRegistry new.
registry addTool: calculator.

"Tool step with agent loop"
toolStep := LLMToolStep registry: registry model: myModel.
toolStep maxIterations: 5.
result := toolStep runWithInput: 'What is 6 * 7?'.
```

### Pipeline Composition

#### Chaining with `then:`

```smalltalk
"Chain steps fluently"
pipeline := (LLMPromptStep template: 'Translate: {text}')
    then: (LLMModelStep model: myModel)
    then: (LLMParserStep parser: LLMStringOutputParser new).
```

#### Nested Pipelines

```smalltalk
"Pipelines are steps too - nest them freely"
translatePipeline := LLMPipeline new
    addStep: (LLMPromptStep template: 'Translate to {language}: {text}');
    addStep: (LLMModelStep model: myModel);
    addStep: (LLMParserStep parser: LLMStringOutputParser new);
    yourself.

summarizePipeline := LLMPipeline new
    addStep: (LLMBlockStep block: [ :ctx | ctx at: #text put: ctx output. ctx ]);
    addStep: (LLMPromptStep template: 'Summarize: {text}');
    addStep: (LLMModelStep model: myModel);
    addStep: (LLMParserStep parser: LLMStringOutputParser new);
    yourself.

fullPipeline := LLMPipeline new
    addStep: translatePipeline;
    addStep: summarizePipeline;
    yourself.
```

### Advanced Steps

#### Conditional Branching

```smalltalk
step := LLMConditionalStep
    condition: [ :ctx | (ctx at: #language) = 'code' ]
    ifTrue: codePipeline
    ifFalse: textPipeline.
```

#### Parallel Execution

```smalltalk
parallel := LLMParallelStep new
    addBranch: #translation step: translatePipeline;
    addBranch: #summary step: summarizePipeline;
    addBranch: #sentiment step: sentimentPipeline;
    yourself.

result := parallel runWith: { #text -> 'Hello world' } asDictionary.
result output at: #translation.  "=> translated text"
result output at: #summary.      "=> summary"
result output at: #sentiment.    "=> sentiment"
```

#### Map (Apply to Collection)

```smalltalk
"Process each item through a pipeline"
mapStep := LLMMapStep step: translatePipeline.
mapStep inputKey: #sentences.

result := mapStep runWith: {
    #sentences -> #('Hello' 'Goodbye' 'Thank you')
} asDictionary.
result output. "=> #('Bonjour' 'Au revoir' 'Merci')"
```

#### Retry with Backoff

```smalltalk
retryStep := LLMRetryStep step: riskyModelStep maxRetries: 3.
retryStep backoffStrategy: #exponential.  "1s, 2s, 4s..."
retryStep retryOn: { LLMApiError. LLMRateLimitError }.
retryStep onRetry: [ :error :attempt |
    Transcript show: 'Retry #', attempt printString, ': ', error messageText; cr ].
```

#### Logging / Observability

```smalltalk
loggedStep := LLMLoggingStep
    step: modelStep
    logger: [ :msg | MyLogger info: msg ].
loggedStep logLevel: #debug.
```

#### Custom Block Steps

```smalltalk
"Quick transformations without creating a class"
step := LLMBlockStep block: [ :ctx |
    ctx output: (ctx output asString copyReplaceAll: 'AI' with: 'Artificial Intelligence').
    ctx ].
```

### API Key Management

```smalltalk
"Register keys directly"
LLMApiKeyManager default registerKey: 'sk-...' forProvider: #openai.
LLMApiKeyManager default registerKey: 'sk-ant-...' forProvider: #anthropic.

"Or set environment variables (auto-detected):"
"  OPENAI_API_KEY=sk-..."
"  ANTHROPIC_API_KEY=sk-ant-..."

"Per-model key manager"
keyManager := LLMApiKeyManager new.
keyManager registerKey: 'sk-project-specific' forProvider: #openai.
model := LLMOpenAIModel gpt4o.
model apiKeyManager: keyManager.
```

### Error Handling

LLMStudio provides a structured error hierarchy:

| Error Class | Description |
|-------------|-------------|
| `LLMError` | Base error class |
| `LLMApiError` | HTTP API errors (with status code and body) |
| `LLMRateLimitError` | Rate limit exceeded (429) with retry-after |
| `LLMTimeoutError` | Request timeout |
| `LLMValidationError` | Configuration/validation errors |

```smalltalk
[ pipeline runWith: vars ]
    on: LLMRateLimitError do: [ :e |
        "Wait and retry"
        (Delay forSeconds: e retryAfterSeconds) wait.
        e retry ]
    on: LLMApiError do: [ :e |
        Transcript show: 'API Error ', e statusCode printString, ': ', e responseBody ].
```

## Class Reference

### Pipeline Core (`LLM-LLMStudio-Core`)

| Class | Description |
|-------|-------------|
| `LLMPipeline` | Sequential pipeline of steps |
| `LLMPipelineStep` | Abstract base for all steps |
| `LLMPipelineContext` | Shared mutable context |
| `LLMBlockStep` | Wrap a Smalltalk block as a step |
| `LLMConditionalStep` | if/else branching |
| `LLMParallelStep` | Execute branches concurrently |
| `LLMRetryStep` | Retry with configurable backoff |
| `LLMMapStep` | Apply a step to each item in a collection |
| `LLMLoggingStep` | Observability wrapper |

### Prompts (`LLM-LLMStudio-Prompts`)

| Class | Description |
|-------|-------------|
| `LLMPromptTemplate` | Text template with `{variable}` substitution |
| `LLMChatPromptTemplate` | Multi-message chat template |
| `LLMFewShotPromptTemplate` | Few-shot learning prompt |
| `LLMChatMessage` | Single chat message (system/user/assistant) |
| `LLMPromptStep` | Pipeline step for prompt formatting |

### Models (`LLM-LLMStudio-Models`)

| Class | Description |
|-------|-------------|
| `LLMAbstractModel` | Abstract base model |
| `LLMOpenAIModel` | OpenAI API (GPT-4, GPT-4o, etc.) |
| `LLMAnthropicModel` | Anthropic API (Claude 3, etc.) |
| `LLMOllamaModel` | Local Ollama models (Llama, Mistral, etc.) |
| `LLMModelConfiguration` | Temperature, max tokens, etc. |
| `LLMModelStep` | Pipeline step for model invocation |

### Parsers (`LLM-LLMStudio-Parsers`)

| Class | Description |
|-------|-------------|
| `LLMOutputParser` | Abstract base parser |
| `LLMStringOutputParser` | Plain text with trimming |
| `LLMJsonOutputParser` | JSON to dictionary (handles code blocks) |
| `LLMRegexOutputParser` | Regex-based extraction |
| `LLMListOutputParser` | Split into list (strips markers) |
| `LLMParserStep` | Pipeline step for output parsing |

### Memory (`LLM-LLMStudio-Memory`)

| Class | Description |
|-------|-------------|
| `LLMMemory` | Abstract base memory |
| `LLMBufferMemory` | Full conversation buffer |
| `LLMSlidingWindowMemory` | Last N messages |
| `LLMMemoryStep` | Pipeline step for memory injection |

### Tools (`LLM-LLMStudio-Tools`)

| Class | Description |
|-------|-------------|
| `LLMTool` | Tool definition with execution block |
| `LLMToolRegistry` | Collection of named tools |
| `LLMToolResult` | Result from tool execution |
| `LLMToolStep` | Agent loop for tool-calling models |

### Connectors (`LLM-LLMStudio-Connectors`)

| Class | Description |
|-------|-------------|
| `LLMHttpConnector` | HTTP client for API communication |
| `LLMApiKeyManager` | API key storage and environment lookup |

## Extending LLMStudio

### Custom Pipeline Step

```smalltalk
LLMPipelineStep subclass: #MyCustomStep
    instanceVariableNames: 'myConfig'
    classVariableNames: ''
    package: 'MyPackage'.

MyCustomStep >> processContext: aContext
    | input transformed |
    input := aContext output.
    transformed := "... your logic ...".
    aContext output: transformed.
    ^ aContext
```

### Custom Model Provider

```smalltalk
LLMAbstractModel subclass: #MyCustomModel
    instanceVariableNames: ''
    classVariableNames: ''
    package: 'MyPackage'.

MyCustomModel >> providerName
    ^ #myProvider

MyCustomModel >> completionEndpoint
    ^ '/v1/completions'

MyCustomModel >> createDefaultConnector
    | conn |
    conn := LLMHttpConnector baseUrl: 'https://api.myprovider.com'.
    conn headerAt: 'Authorization'
         put: 'Bearer ', (self apiKeyManager apiKeyFor: self providerName).
    ^ conn

MyCustomModel >> buildRequestBody: messages
    ^ Dictionary new
        at: 'model' put: modelId;
        at: 'messages' put: (self normalizeMessages: messages);
        yourself
```

### Custom Output Parser

```smalltalk
LLMOutputParser subclass: #MyXmlParser
    instanceVariableNames: ''
    classVariableNames: ''
    package: 'MyPackage'.

MyXmlParser >> parse: aString
    "Parse XML from LLM output"
    ^ XMLDOMParser parse: aString
```

## Testing

LLMStudio includes `LLMMockModel` for testing pipelines without API calls:

```smalltalk
"Fixed response"
mock := LLMMockModel respondingWith: 'Expected response'.

"Sequential responses"
mock := LLMMockModel respondingWithSequence: #(
    'First response'
    'Second response'
    'Third response'
).

"Verify interactions"
pipeline runWith: vars.
mock callCount.             "=> 1"
mock lastCapturedMessages.  "=> the messages sent"
mock capturedRequests.      "=> all requests made"
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
