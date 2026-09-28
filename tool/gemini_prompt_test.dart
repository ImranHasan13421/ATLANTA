// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  final rawKey = const String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'QVEuQWI4Uk42SnFJc2pPemQzd3ZUT0NHbVlRSGRRenhNSHRVZUhXeVNyb0paTzBOZldIb0E=',
  );
  final key = rawKey.startsWith('AQ.') ? rawKey : utf8.decode(base64.decode(rawKey));
  
  print('1. Querying available models...');
  try {
    final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$key');
    final req = await client.getUrl(uri);
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    print('Models status: ${res.statusCode}');
    if (res.statusCode == 200) {
      final d = jsonDecode(body);
      final models = (d['models'] as List)
          .map((m) => m['name'].toString().replaceFirst('models/', ''))
          .where((name) => name.contains('flash') || name.contains('pro'))
          .toList();
      print('Available Flash/Pro models: $models');
    } else {
      print('Models query error: $body');
    }
  } catch (e) {
    print('Query exception: $e');
  }

  print('\n2. Testing content generation...');
  final testModels = [
    'gemini-flash-latest',
    'gemini-flash-lite-latest',
    'gemini-3.8-flash',
    'gemini-3.7-flash',
    'gemini-3.5-flash',
    'gemini-3.5-flash-lite',
    'gemini-3-flash-preview',
    'gemini-pro-latest',
  ];

  for (final model in testModels) {
    try {
      final genUri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$key');
      final req = await client.postUrl(genUri);
      req.headers.contentType = ContentType.json;
      final payload = jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [{'text': 'Hello Atlanta, report status in 5 words.'}]
          }
        ]
      });
      req.write(payload);
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode == 200) {
        final d = jsonDecode(body);
        final reply = d['candidates']?[0]?['content']?['parts']?[0]?['text'];
        print('SUCCESS with $model: $reply');
        break;
      } else {
        print('FAILED with $model: (${res.statusCode}) ${body.length > 100 ? body.substring(0, 100) : body}');
      }
    } catch (e) {
      print('Exception with $model: $e');
    }
  }
  client.close();
}
