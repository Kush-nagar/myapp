// lib/services/storage_tips_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service to generate storage tips and tricks for ingredients using Gemini API
class StorageTipsService {
  final String apiKey;
  final String model;

  StorageTipsService({required this.apiKey, this.model = 'gemini-2.5-flash'});

  /// Generate comprehensive storage tips for the provided ingredients
  Future<Map<String, dynamic>> generateStorageTips(
    List<String> ingredients,
  ) async {
    final prompt =
        '''
You are a professional food storage expert and nutritionist. Generate comprehensive storage tips and recommendations for the following ingredients/food items. 

ONLY OUTPUT a JSON object (no markdown, no explanation text outside JSON).

The JSON must have this exact structure:
{
  "generalTips": [
    "string - general storage principle that applies to multiple items"
  ],
  "itemSpecificTips": [
    {
      "ingredient": "string - name of the ingredient",
      "storageMethod": "string - best storage method (refrigerate, freeze, room temperature, etc.)",
      "location": "string - specific location (pantry, fridge, freezer, counter, etc.)",
      "container": "string - best container type (airtight, breathable bag, wrapped, etc.)",
      "shelfLife": "string - expected shelf life with proper storage",
      "tips": [
        "string - specific tip for this ingredient"
      ],
      "signs": {
        "freshness": ["string - signs that indicate freshness"],
        "spoilage": ["string - signs that indicate spoilage/when to discard"]
      },
      "preparation": "string - any prep needed before storage (wash, dry, trim, etc.)"
    }
  ],
  "categoryTips": {
    "vegetables": [
      "string - tips specific to vegetable storage"
    ],
    "fruits": [
      "string - tips specific to fruit storage"
    ],
    "proteins": [
      "string - tips specific to protein storage"
    ],
    "grains": [
      "string - tips specific to grain/dry goods storage"
    ],
    "herbs": [
      "string - tips specific to herb storage"
    ],
    "dairy": [
      "string - tips specific to dairy storage"
    ]
  },
  "environmentalFactors": {
    "temperature": "string - optimal temperature ranges",
    "humidity": "string - humidity considerations",
    "light": "string - light exposure guidelines",
    "airflow": "string - ventilation requirements"
  },
  "extendShelfLife": [
    "string - advanced techniques to maximize freshness and shelf life"
  ],
  "foodSafety": [
    "string - critical food safety reminders"
  ]
}

Input ingredients: ${jsonEncode(ingredients)}

Provide detailed, practical, and scientifically accurate storage advice. Focus on:
1. Maximizing shelf life and maintaining nutritional value
2. Preventing spoilage and food waste
3. Maintaining optimal flavor, texture, and appearance
4. Food safety considerations
5. Cost-effective storage solutions
6. Easy-to-implement tips for home storage

Return nothing else than the JSON object.
''';

    final body = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
          ],
        },
      ],
    };

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
    );

    final headers = {
      'Content-Type': 'application/json',
      'x-goog-api-key': apiKey,
    };

    final resp = await http.post(uri, headers: headers, body: jsonEncode(body));

    if (resp.statusCode != 200) {
      throw Exception(
        'Gemini API error ${resp.statusCode}: ${resp.body.length > 300 ? resp.body.substring(0, 300) : resp.body}',
      );
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final modelText = _extractText(decoded);

    if (modelText.isEmpty) {
      throw Exception('No text returned by Gemini: ${resp.body}');
    }

    // Parse JSON strictly
    try {
      final parsed = jsonDecode(modelText);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      }
    } catch (e) {
      // Fallback: try to extract JSON from text
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(modelText);
      if (jsonMatch != null) {
        try {
          return jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
        } catch (_) {}
      }
    }

    // Last resort: return a basic structure with the raw text
    return {
      "generalTips": [modelText.trim()],
      "itemSpecificTips": [],
      "categoryTips": {},
      "environmentalFactors": {},
      "extendShelfLife": [],
      "foodSafety": [],
    };
  }

  /// Generate quick storage recommendations for immediate use
  Future<List<Map<String, dynamic>>> generateQuickTips(
    List<String> ingredients,
  ) async {
    final prompt =
        '''
You are a food storage expert. Provide quick, actionable storage tips for these ingredients.

ONLY OUTPUT a JSON array (no markdown, no explanation text outside JSON).

Each item in the array should have this structure:
{
  "ingredient": "string - ingredient name",
  "quickTip": "string - one sentence storage tip",
  "icon": "string - suggested icon name (store, ac_unit, room, kitchen, etc.)",
  "priority": "string - High, Medium, or Low based on urgency"
}

Input ingredients: ${jsonEncode(ingredients)}

Focus on the most critical storage advice that prevents immediate spoilage.
Return nothing else than the JSON array.
''';

    final body = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
          ],
        },
      ],
    };

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
    );

    final headers = {
      'Content-Type': 'application/json',
      'x-goog-api-key': apiKey,
    };

    final resp = await http.post(uri, headers: headers, body: jsonEncode(body));

    if (resp.statusCode != 200) {
      throw Exception(
        'Gemini API error ${resp.statusCode}: ${resp.body.length > 300 ? resp.body.substring(0, 300) : resp.body}',
      );
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final modelText = _extractText(decoded);

    if (modelText.isEmpty) {
      throw Exception('No text returned by Gemini: ${resp.body}');
    }

    // Parse JSON strictly
    try {
      final parsed = jsonDecode(modelText);
      if (parsed is List) {
        return parsed
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (e) {
      // Fallback: try to extract JSON array from text
      final arrayMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(modelText);
      if (arrayMatch != null) {
        try {
          return (jsonDecode(arrayMatch.group(0)!) as List<dynamic>)
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        } catch (_) {}
      }
    }

    // Last resort: return basic tips for each ingredient
    return ingredients
        .map(
          (ingredient) => {
            "ingredient": ingredient,
            "quickTip": "Store properly to maintain freshness",
            "icon": "store",
            "priority": "Medium",
          },
        )
        .toList();
  }

  String _extractText(Map<String, dynamic> decoded) {
    String fullText = '';
    if (decoded.containsKey('candidates')) {
      for (final c in decoded['candidates'] as List<dynamic>) {
        final content = c['content'];
        if (content is Map && content['parts'] is List) {
          for (final p in content['parts']) {
            if (p is Map && p['text'] is String) {
              fullText += p['text'];
            }
          }
        }
      }
    }
    return fullText.trim();
  }
}
