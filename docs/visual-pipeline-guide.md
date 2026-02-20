# LLM Studio - Visual Pipeline Guide

Complete guide for building, running, and inspecting LLM pipelines using the visual dashboard.

---

## Table of Contents

1. [Opening the Dashboard](#1-opening-the-dashboard)
2. [Dashboard Overview](#2-dashboard-overview)
3. [Creating a Pipeline (New Pipeline Button)](#3-creating-a-pipeline)
4. [Running a Pipeline (Run Button)](#4-running-a-pipeline)
5. [Re-Running a Pipeline (Re-Run Button)](#5-re-running-a-pipeline)
6. [Inspecting Results](#6-inspecting-results)
7. [Toolbar Reference](#7-toolbar-reference)
8. [Programmatic Usage](#8-programmatic-usage)
9. [End-to-End Examples](#9-end-to-end-examples)
10. [API Key Setup](#10-api-key-setup)
11. [Troubleshooting](#11-troubleshooting)

---

## 1. Opening the Dashboard

There are three ways to open the visual dashboard in a Pharo Playground or script:

### Option A: Fresh Dashboard (no pipeline yet)

```smalltalk
LLMDashboardPresenter open.
```

Opens an empty dashboard. Use the **New Pipeline** button to create a pipeline visually.

### Option B: Dashboard with an existing pipeline

```smalltalk
| pipeline |
pipeline := LLMPipeline new
    addStep: (LLMPromptStep template: 'Translate to {language}: {text}');
    addStep: (LLMModelStep model: LLMOpenAIModel gpt4o);
    addStep: (LLMParserStep parser: LLMStringOutputParser new);
    yourself.
pipeline name: 'Translation Pipeline'.

LLMDashboardPresenter openOnPipeline: pipeline.
```

### Option C: Dashboard from a tracer

```smalltalk
| pipeline tracer |
pipeline := LLMPipeline new
    addStep: (LLMPromptStep template: 'Summarize: {text}');
    addStep: (LLMModelStep model: LLMOpenAIModel gpt4oMini);
    yourself.
pipeline name: 'Summarizer'.

tracer := LLMPipelineTracer on: pipeline.
tracer openDashboard.
```

---

## 2. Dashboard Overview

The dashboard window has these regions:

```
+------------------------------------------------------------------+
|  [New Pipeline] [Run] [Re-Run] [Refresh] [Clear] [Export]        |  <- Toolbar
+------------------+-----------------------------------------------+
|                  |                                                 |
|  Pipeline Runs   |   [ Pipeline Flow | Execution Steps |          |
|  (left panel)    |     Conversation  | Metrics ]                  |
|                  |                                                 |
|  - Status        |   (tabbed content area)                        |
|  - Pipeline name |                                                 |
|  - Steps count   |                                                 |
|  - Duration      |                                                 |
|  - Tokens        |                                                 |
|                  |                                                 |
+------------------+-----------------------------------------------+
|  Status bar messages                                              |
+------------------------------------------------------------------+
```

**Left panel:** Lists all pipeline executions (runs), newest first. Click a row to inspect it.

**Right panel:** Four tabs showing details of the selected run:
- **Pipeline Flow** - Visual flow diagram of steps with color-coded status
- **Execution Steps** - Table with timing, tokens, and output for each step
- **Conversation** - Chat messages exchanged during execution
- **Metrics** - Performance summary, token usage chart

---

## 3. Creating a Pipeline

Click the **New Pipeline** button in the toolbar. This opens the **Pipeline Builder** dialog:

```
+--------------------------------------------------+
|  LLM Studio - Pipeline Builder                   |
+--------------------------------------------------+
|  Pipeline Name:  [My Pipeline              ]     |
|                                                   |
|  Provider: [OpenAI v]    Model: [gpt-4o      v]  |
|                                                   |
|  API Key: [sk-... or leave empty for env var  ]   |
|                                                   |
|  Ollama Host: [localhost]  Ollama Port: [11434]   |
|                                                   |
|  Prompt Template (use {variable} for inputs):     |
|  +---------------------------------------------+ |
|  | Translate the following text to {language}:  | |
|  | {text}                                       | |
|  +---------------------------------------------+ |
|                                                   |
|  Temperature: [0.7]  Max Tokens: [1024]           |
|  Output Parser: [String v]                        |
|                                                   |
|  Status: Configure your pipeline and click Create |
|                                                   |
|  [Create Pipeline] [Create & Run] [Cancel]        |
+--------------------------------------------------+
```

### Fields

| Field | Description |
|-------|-------------|
| **Pipeline Name** | Human-readable name for your pipeline |
| **Provider** | LLM provider: `OpenAI`, `Anthropic`, or `Ollama` |
| **Model** | Specific model ID (list updates per provider) |
| **API Key** | Your API key. Leave empty to use environment variables (`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`) |
| **Ollama Host/Port** | Only for Ollama provider. Defaults to `localhost:11434` |
| **Prompt Template** | Your prompt text. Use `{variable}` syntax for inputs. Example: `Translate to {language}: {text}` |
| **Temperature** | Controls randomness (0.0 = deterministic, 1.0 = creative). Default: `0.7` |
| **Max Tokens** | Maximum tokens in the response. Default: `1024` |
| **Output Parser** | How to parse the LLM output: `String` (trim whitespace), `JSON` (extract JSON), `List` (parse lists), `None` (raw) |

### Available Models

**OpenAI:** `gpt-4o`, `gpt-4o-mini`, `gpt-4-turbo`, `gpt-4`

**Anthropic:** `claude-3-5-sonnet-20241022`, `claude-3-opus-20240229`, `claude-3-haiku-20240307`

**Ollama (local):** `llama3`, `mistral`, `codellama`, `phi`, `gemma`

### Buttons

- **Create Pipeline** - Creates the pipeline and loads it into the dashboard. You can then click **Run** separately.
- **Create & Run** - Creates the pipeline AND immediately opens the Run dialog to execute it.
- **Cancel** - Closes the dialog without creating anything.

---

## 4. Running a Pipeline

Click the **Run** button in the toolbar. If the pipeline has template variables (e.g., `{language}`, `{text}`), the **Run Input** dialog appears:

```
+------------------------------------------+
|  LLM Studio - Run Pipeline               |
+------------------------------------------+
|  Enter input variables for execution:    |
|                                           |
|  language:                                |
|  [French                            ]    |
|                                           |
|  text:                                    |
|  [Hello, how are you today?         ]    |
|                                           |
|  Status: Fill in all fields and click Run |
|                                           |
|  [Run Pipeline]  [Cancel]                 |
+------------------------------------------+
```

The dialog auto-detects variables from `{variable}` placeholders in your prompt template and creates one input field per variable.

### What happens when you click Run Pipeline:

1. The input values are collected into a dictionary
2. The pipeline is executed through the `LLMPipelineTracer`
3. Each step runs sequentially: Prompt formatting -> Model call -> Output parsing
4. The execution is traced with timing, tokens, and status for each step
5. Results appear in the dashboard automatically
6. The status bar shows success or failure

If the pipeline has **no variables** (e.g., a fixed prompt), it runs immediately without showing the input dialog.

---

## 5. Re-Running a Pipeline

Click the **Re-Run** button to re-execute the pipeline with the **same inputs** as the last run. This is useful for:

- Testing consistency of LLM responses
- Comparing runs after changing model parameters
- Quick iteration without re-entering variables

If no previous run exists, Re-Run falls back to opening the Run dialog.

---

## 6. Inspecting Results

After a pipeline run, results are shown in the dashboard tabs:

### Pipeline Flow Tab

Visual flow diagram with color-coded step boxes:

```
+-------------+     +-------------+     +-------------+
| PromptStep  | --> | ModelStep   | --> | ParserStep  |
| [OK] 2ms    |     | [OK] 1523ms |     | [OK] 1ms    |
| 0 tokens    |     | 156 tokens  |     | 0 tokens    |
+-------------+     +-------------+     +-------------+
```

- **Green** = success
- **Red** = error
- **Blue** = running
- **Gray** = pending

Click a step box to see its details (input, output, timing, tokens, errors) in the panel below.

### Execution Steps Tab

Table with all steps and their details:

| # | Status | Step Name | Type | Duration | In Tokens | Out Tokens | Output Preview |
|---|--------|-----------|------|----------|-----------|------------|----------------|
| 1 | [OK] | LLMPromptStep | LLMPromptStep | 2ms | 0 | 0 | Translate to French: Hello... |
| 2 | [OK] | LLMModelStep | LLMModelStep | 1523ms | 42 | 114 | Bonjour, comment allez-vous... |
| 3 | [OK] | LLMParserStep | LLMParserStep | 1ms | 0 | 0 | Bonjour, comment allez-vous... |

Click a row to see full input/output in the detail panel below.

### Conversation Tab

Shows the messages exchanged with the LLM:

| Role | Content |
|------|---------|
| USER | Translate to French: Hello, how are you today? |
| ASSISTANT | Bonjour, comment allez-vous aujourd'hui ? |

### Metrics Tab

Performance summary:

```
Pipeline: Translation Pipeline
Status: Success
Total Duration: 1526ms
Steps: 3 (3 succeeded, 0 failed)
Success Rate: 100.0%
Average Step Duration: 508.7ms
Token Usage: 42 input + 114 output = 156 total
```

Plus a visual token usage bar chart showing input/output tokens per step.

---

## 7. Toolbar Reference

| Button | Icon | Action |
|--------|------|--------|
| **New Pipeline** | + | Opens the Pipeline Builder dialog to create a new pipeline |
| **Run** | ▶ | Runs the current pipeline (prompts for input variables) |
| **Re-Run** | ↻ | Re-runs with the same inputs as the last execution |
| **Refresh** | ↺ | Refreshes the dashboard data from the tracer |
| **Clear** | ✕ | Clears all execution traces from history |
| **Export** | 💾 | Copies a text report of the selected trace to clipboard |

---

## 8. Programmatic Usage

You can also build and run pipelines programmatically, then inspect them in the dashboard.

### Build and run, then open dashboard

```smalltalk
| pipeline tracer |
pipeline := LLMPipeline new
    addStep: (LLMPromptStep template: 'Write a haiku about {topic}');
    addStep: (LLMModelStep model: LLMOpenAIModel gpt4oMini);
    addStep: (LLMParserStep parser: LLMStringOutputParser new);
    yourself.
pipeline name: 'Haiku Generator'.

tracer := LLMPipelineTracer on: pipeline.
tracer runWith: { #topic -> 'programming' } asDictionary.
tracer openDashboard.
```

### Multiple runs, then inspect

```smalltalk
| pipeline tracer |
pipeline := LLMPipeline new
    addStep: (LLMPromptStep template: 'Translate to {language}: {text}');
    addStep: (LLMModelStep model: LLMAnthropicModel claude3Sonnet);
    addStep: (LLMParserStep parser: LLMStringOutputParser new);
    yourself.
pipeline name: 'Translator'.

tracer := LLMPipelineTracer on: pipeline.

"Run multiple translations"
tracer runWith: { #language -> 'French'. #text -> 'Hello world' } asDictionary.
tracer runWith: { #language -> 'Spanish'. #text -> 'Good morning' } asDictionary.
tracer runWith: { #language -> 'Japanese'. #text -> 'Thank you' } asDictionary.

"Open dashboard - all 3 runs visible in the left panel"
tracer openDashboard.
```

### Open empty dashboard and use buttons

```smalltalk
"Just open the UI - create everything from buttons"
LLMDashboardPresenter open.
```

Then use **New Pipeline** → configure → **Create & Run** → enter variables → results appear.

### Set pipeline on existing dashboard programmatically

```smalltalk
| dashboard pipeline |
dashboard := LLMDashboardPresenter open.

"Later, set a pipeline"
pipeline := LLMPipeline new
    addStep: (LLMPromptStep template: 'Explain {concept} simply');
    addStep: (LLMModelStep model: LLMOllamaModel llama3);
    yourself.
pipeline name: 'Explainer'.

dashboard tracer pipeline: pipeline.
```

---

## 9. End-to-End Examples

### Example 1: Translation Pipeline (OpenAI)

1. Open the dashboard: `LLMDashboardPresenter open`
2. Click **New Pipeline**
3. Fill in:
   - Name: `Translator`
   - Provider: `OpenAI`
   - Model: `gpt-4o-mini`
   - API Key: your key (or set `OPENAI_API_KEY` env var)
   - Prompt: `Translate the following text to {language}: {text}`
   - Temperature: `0.3`
   - Max Tokens: `512`
   - Parser: `String`
4. Click **Create & Run**
5. In the Run dialog, enter:
   - language: `French`
   - text: `Hello, how are you today?`
6. Click **Run Pipeline**
7. Watch results appear in the dashboard

### Example 2: Code Reviewer (Anthropic)

1. Open: `LLMDashboardPresenter open`
2. Click **New Pipeline**
3. Fill in:
   - Name: `Code Reviewer`
   - Provider: `Anthropic`
   - Model: `claude-3-5-sonnet-20241022`
   - Prompt: `Review this code for bugs and improvements:\n\n{code}`
   - Temperature: `0.2`
   - Max Tokens: `2048`
   - Parser: `String`
4. Click **Create & Run**
5. Enter your code in the `code` field
6. Click **Run Pipeline**

### Example 3: Local Ollama Summarizer

1. Ensure Ollama is running: `ollama serve`
2. Open: `LLMDashboardPresenter open`
3. Click **New Pipeline**
4. Fill in:
   - Name: `Summarizer`
   - Provider: `Ollama`
   - Model: `llama3`
   - Host: `localhost`, Port: `11434`
   - Prompt: `Summarize the following text in 3 bullet points:\n\n{text}`
   - Temperature: `0.5`
   - Parser: `String`
5. Click **Create & Run**
6. Paste your text, click **Run Pipeline**

### Example 4: JSON Extraction

```smalltalk
| pipeline |
pipeline := LLMPipeline new
    addStep: (LLMPromptStep template:
        'Extract the name, age, and city from: {text}. Return JSON with keys: name, age, city.');
    addStep: (LLMModelStep model: LLMOpenAIModel gpt4o);
    addStep: (LLMParserStep parser: LLMJsonOutputParser new);
    yourself.
pipeline name: 'Entity Extractor'.

LLMDashboardPresenter openOnPipeline: pipeline.
"Then click Run, enter text like: 'John is 30 years old and lives in Paris'"
```

---

## 10. API Key Setup

### Environment Variables (recommended)

Set these environment variables before launching Pharo:

```bash
# OpenAI
export OPENAI_API_KEY="sk-..."

# Anthropic
export ANTHROPIC_API_KEY="sk-ant-..."

# Ollama - no key needed (runs locally)
```

### In-Image Registration

```smalltalk
LLMApiKeyManager default registerKey: 'sk-...' forProvider: #openai.
LLMApiKeyManager default registerKey: 'sk-ant-...' forProvider: #anthropic.
```

### Via Pipeline Builder

Enter your API key directly in the **API Key** field of the Pipeline Builder dialog. The key is registered for the session.

---

## 11. Troubleshooting

### "No pipeline configured"
You need to create a pipeline first. Click **New Pipeline** or open the dashboard with `openOnPipeline:`.

### "Missing required variable: ..."
Your prompt template has `{variable}` placeholders but the Run dialog fields were left empty. Fill in all fields.

### "No API key found for provider: ..."
Set the environment variable (e.g., `OPENAI_API_KEY`) or enter the key in the Pipeline Builder or register it via `LLMApiKeyManager`.

### Pipeline fails with timeout
The default HTTP timeout may be too short. You can increase it programmatically:

```smalltalk
model := LLMOpenAIModel gpt4o.
model connector timeout: 120. "120 seconds"
```

### Ollama connection refused
Ensure Ollama is running (`ollama serve`) and listening on the configured host/port (default: `localhost:11434`).

### Dashboard doesn't update after run
Click **Refresh** in the toolbar. The dashboard auto-refreshes on trace completion, but if the UI thread is blocked, a manual refresh helps.

### Re-Run button does nothing
Re-Run requires at least one previous run. Use **Run** first to set initial inputs.
