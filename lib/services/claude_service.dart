import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ClaudeService {
  static const _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-sonnet-4-20250514';
  static const _apiVersion = '2023-06-01';
  static const _timeout = Duration(seconds: 30);

  final http.Client _client;
  String? _apiKey;

  ClaudeService({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey;

  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  void setApiKey(String key) {
    _apiKey = key;
  }

  Future<String> sendMessage({
    required String userMessage,
    List<ChatMessage> history = const [],
    String? systemPrompt,
  }) async {
    if (!hasApiKey) {
      throw ClaudeException('API key not set. Go to Settings to add it.');
    }

    final messages = [
      ...history.map((m) => m.toJson()),
      {'role': 'user', 'content': userMessage},
    ];

    final body = <String, dynamic>{
      'model': _model,
      'max_tokens': 1024,
      'messages': messages,
    };

    if (systemPrompt != null) {
      body['system'] = systemPrompt;
    }

    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': _apiKey!,
              'anthropic-version': _apiVersion,
            },
            body: json.encode(body),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw ClaudeException('Request timed out. Please try again.');
    }

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        final content = data['content'] as List<dynamic>?;
        if (content == null || content.isEmpty) {
          throw ClaudeException('Empty response from Claude.');
        }
        return content
            .where((block) => block['type'] == 'text')
            .map((block) => block['text'] as String)
            .join('\n');
      } on FormatException {
        throw ClaudeException('Invalid response from server.');
      }
    } else if (response.statusCode == 401) {
      throw ClaudeException('Invalid API key. Check your key in Settings.');
    } else if (response.statusCode == 429) {
      throw ClaudeException('Rate limited. Please wait a moment.');
    } else {
      try {
        final data = json.decode(response.body);
        final errorMsg = data['error']?['message'] ?? 'Unknown error';
        throw ClaudeException('API error: $errorMsg');
      } on FormatException {
        throw ClaudeException('API error (${response.statusCode})');
      }
    }
  }

  void dispose() {
    _client.close();
  }
}

class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, String> toJson() => {
        'role': role,
        'content': content,
      };
}

class ClaudeException implements Exception {
  final String message;
  ClaudeException(this.message);

  @override
  String toString() => message;
}
