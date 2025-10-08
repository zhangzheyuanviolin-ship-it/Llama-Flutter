# Chat Template Integration Guide

## Overview

The `llama_flutter_android` plugin now includes built-in support for popular chat templates, making it easy to format conversations correctly for different models.

## Supported Templates

### 1. ChatML (Qwen 2/2.5, Command-R)
**Models:** Qwen 2, Qwen 2.5, Command-R, Hermes

**Format:**
```
<|im_start|>system
You are a helpful assistant.<|im_end|>
<|im_start|>user
Hello!<|im_end|>
<|im_start|>assistant
```

**Special tokens:**
- Start: `<|im_start|>`
- End: `<|im_end|>`
- EOS: `<|endoftext|>` (auto-added by model)

### 2. Llama-3/3.1/3.3
**Models:** Llama-3, Llama-3.1, Llama-3.3

**Format:**
```
<|begin_of_text|><|start_header_id|>system<|end_header_id|>

You are a helpful assistant.<|eot_id|>
<|start_header_id|>user<|end_header_id|>

Hello!<|eot_id|>
<|start_header_id|>assistant<|end_header_id|>
```

**Special tokens:**
- BOS: `<|begin_of_text|>`
- Header start: `<|start_header_id|>`
- Header end: `<|end_header_id|>`
- EOT: `<|eot_id|>` (End-of-Turn)

### 3. Llama-2
**Models:** Llama-2, Code Llama

**Format:**
```
<s>[INST] <<SYS>>
You are a helpful assistant.
<</SYS>>

Hello! [/INST] Hi there!</s><s>[INST] How are you? [/INST]
```

**Special tokens:**
- BOS: `<s>`
- EOS: `</s>`
- System delimiters: `<<SYS>>` and `<</SYS>>`

### 4. QwQ-32B (Reasoning Model)
**Models:** QwQ-32B-Preview

**Format:**
```
<|im_start|>user
Why is the sky blue?<|im_end|>
<|im_start|>assistant
<think>
[Model's chain-of-thought reasoning appears here]
</think>
The sky appears blue because...
```

**Special features:**
- Uses ChatML base with thinking tags
- `<think>` tag may need client-side injection during streaming
- History must exclude `<think>...</think>` blocks for subsequent turns

### 5. Mistral/Mixtral
**Models:** Mistral-7B, Mixtral-8x7B, Mixtral-8x22B

**Format:**
```
<s>[INST] System prompt

Hello! [/INST]Hi there!</s>[INST] How are you? [/INST]
```

**Special tokens:**
- BOS: `<s>`
- EOS: `</s>`
- No dedicated system token (include in first [INST])

### 6. DeepSeek Coder
**Models:** DeepSeek-Coder-V2, DeepSeek-Coder-V3.1

**Format:**
```
<｜begin▁of▁sentence｜>You are an expert programmer. User: Write a function
Assistant: Here's the function...
```

### 7. DeepSeek R1 (Reasoning)
**Models:** DeepSeek-R1, DeepSeek-V3.1

**Format:**
```
<｜begin▁of▁sentence｜>You are helpful.<｜User｜>Question<｜Assistant｜></think>Answer
```

**Special features:**
- Includes `</think>` even in non-thinking mode
- Supports thinking mode with `<think>reasoning</think>` blocks

### 8. Gemma/Gemma 2
**Models:** Gemma, Gemma 2, CodeGemma

**Format:**
```
<start_of_turn>user
Hello!<end_of_turn>
<start_of_turn>model
Hi there!<end_of_turn><eos>
<start_of_turn>user
How are you?<end_of_turn>
<start_of_turn>model
```

**Special tokens:**
- Turn start: `<start_of_turn>`
- Turn end: `<end_of_turn>`
- EOS: `<eos>` (Gemma 2 uses dual termination)

### 9. Phi-2/Phi-3
**Models:** Phi-2, Phi-3, Phi-3.5

**Format:**
```
<|system|>
You are a helpful assistant.<|end|>
<|user|>
Hello!<|end|>
<|assistant|>
```

### 10. Alpaca
**Models:** Alpaca, Alpaca-LoRA

**Format:**
```
Below is an instruction that describes a task.

### Instruction:
Hello!

### Response:
```

### 11. Vicuna
**Models:** Vicuna, Wizard-Vicuna

**Format:**
```
A chat between a curious user and an artificial intelligence assistant.

USER: Hello!
ASSISTANT:
```

## Usage

### Automatic Template Detection

The plugin automatically detects the template based on the model filename:

```dart
final controller = LlamaController();

// Load model - template auto-detected from filename
await controller.loadModel(
  modelPath: '/path/to/Qwen2-0.5B-Instruct-Q4_K_M.gguf',
  nThreads: 4,
  contextSize: 2048,
);

// Use chat API - template is automatically applied
final messages = [
  ChatMessage(role: 'system', content: 'You are a helpful assistant.'),
  ChatMessage(role: 'user', content: 'Hello!'),
];

await controller.generateChat(
  messages: messages,
  onToken: (token) => print(token),
);
```

### Manual Template Selection

You can override the auto-detection:

```dart
await controller.generateChat(
  messages: messages,
  template: 'chatml', // or 'llama2', 'alpaca', etc.
  onToken: (token) => print(token),
);
```

### Raw Prompt (Legacy)

You can still use raw prompts without templates:

```dart
await controller.generate(
  prompt: 'Your pre-formatted prompt here',
  onToken: (token) => print(token),
);
```

## Example: Complete Chat App

```dart
import 'package:llama_flutter_android/llama_flutter_android.dart';

class ChatService {
  final LlamaController _controller = LlamaController();
  final List<ChatMessage> _history = [];
  
  Future<void> loadModel(String modelPath) async {
    await _controller.loadModel(
      modelPath: modelPath,
      nThreads: 4,
      contextSize: 2048,
    );
  }
  
  Stream<String> sendMessage(String userMessage) async* {
    // Add user message to history
    _history.add(ChatMessage(
      role: 'user',
      content: userMessage,
    ));
    
    // Generate response
    final responseBuffer = StringBuffer();
    
    await _controller.generateChat(
      messages: _history,
      maxTokens: 256,
      temperature: 0.7,
      onToken: (token) {
        responseBuffer.write(token);
        // Yield each token for streaming UI
      },
    );
    
    // Add assistant response to history
    _history.add(ChatMessage(
      role: 'assistant',
      content: responseBuffer.toString(),
    ));
  }
  
  void dispose() {
    _controller.dispose();
  }
}
```

## API Reference

### ChatMessage

```dart
class ChatMessage {
  final String role;    // 'system', 'user', or 'assistant'
  final String content; // Message text
  
  ChatMessage({
    required this.role,
    required this.content,
  });
}
```

### generateChat()

```dart
Future<void> generateChat({
  required List<ChatMessage> messages,
  String? template,           // Optional: 'chatml', 'llama2', etc.
  int maxTokens = 512,
  double temperature = 0.7,
  double topP = 0.9,
  int topK = 40,
  required void Function(String token) onToken,
  void Function()? onDone,
  void Function(String error)? onError,
});
```

### getSupportedTemplates()

```dart
List<String> getSupportedTemplates()
```

Returns: `['chatml', 'qwen', 'llama3', 'llama2', 'alpaca', 'vicuna', 'phi', 'gemma']`

## Template Auto-Detection Rules

The plugin detects templates based on model filename:

| Keyword in Filename | Template Used |
|---------------------|---------------|
| `qwen`             | ChatML        |
| `llama-3`, `llama3` | ChatML        |
| `llama-2`, `llama2` | Llama-2       |
| `phi`              | Phi           |
| `gemma`            | Gemma         |
| `alpaca`           | Alpaca        |
| `vicuna`           | Vicuna        |
| *(default)*        | ChatML        |

## Testing Templates

You can test template formatting:

```dart
final controller = LlamaController();

// Get supported templates
final templates = controller.getSupportedTemplates();
print('Supported: $templates');

// Test formatting without loading model
final messages = [
  ChatMessage(role: 'system', content: 'You are helpful.'),
  ChatMessage(role: 'user', content: 'Hi'),
];

// This would be formatted as:
// <|im_start|>system
// You are helpful.<|im_end|>
// <|im_start|>user
// Hi<|im_end|>
// <|im_start|>assistant
```

## Migration from Raw Prompts

**Before (manual formatting):**
```dart
final prompt = '''
<|im_start|>system
You are a helpful assistant.<|im_end|>
<|im_start|>user
$userMessage<|im_end|>
<|im_start|>assistant
''';

await controller.generate(prompt: prompt, ...);
```

**After (automatic):**
```dart
final messages = [
  ChatMessage(role: 'system', content: 'You are a helpful assistant.'),
  ChatMessage(role: 'user', content: userMessage),
];

await controller.generateChat(messages: messages, ...);
```

## Benefits

1. **No more manual formatting** - Plugin handles all template syntax
2. **Multi-model support** - Switch models without changing code
3. **Automatic detection** - Works out of the box
4. **Conversation history** - Maintain context easily
5. **Type-safe** - Compile-time checks for message structure

## Advanced: Custom Templates

If you need a custom template, you can use raw prompts:

```dart
String customFormat(List<ChatMessage> messages) {
  final buffer = StringBuffer();
  for (final msg in messages) {
    buffer.write('[${msg.role.toUpperCase()}]: ${msg.content}\n');
  }
  return buffer.toString();
}

await controller.generate(
  prompt: customFormat(messages),
  onToken: onToken,
);
```

## Troubleshooting

### Model generates gibberish
- **Cause:** Wrong template format
- **Fix:** Manually specify template: `template: 'chatml'`

### Model doesn't respond
- **Cause:** Missing system message
- **Fix:** Add system message at start of conversation

### Model continues user message
- **Cause:** Template not properly closed
- **Fix:** Use `generateChat()` instead of `generate()`

## See Also

- [Quick Start Guide](QUICK_START.md)
- [API Documentation](README.md)
- [Example App](example/)
