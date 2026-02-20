# LLM Studio Documentation

## Guides

- [Visual Pipeline Guide](visual-pipeline-guide.md) - Complete guide for building, running, and inspecting LLM pipelines from the visual dashboard UI. Covers all toolbar buttons, the Pipeline Builder, the Run dialog, and end-to-end examples.

## Quick Start

Open a Pharo Playground and evaluate:

```smalltalk
"Option 1: Open empty dashboard, create everything from buttons"
LLMDashboardPresenter open.

"Option 2: Open dashboard with a pre-built pipeline"
LLMDashboardPresenter openOnPipeline: (LLMPipeline new
    addStep: (LLMPromptStep template: 'Translate to {language}: {text}');
    addStep: (LLMModelStep model: LLMOpenAIModel gpt4o);
    addStep: (LLMParserStep parser: LLMStringOutputParser new);
    name: 'Translator';
    yourself).
```

Then use the toolbar buttons: **New Pipeline** to create, **Run** to execute, **Re-Run** to repeat.
