import 'dart:convert';
import 'package:http/http.dart' as http;

/// 🔧 AZURE TRANSLATOR SERVICE SETUP GUIDE
/// ========================================
///
/// TO USE THIS SERVICE, YOU NEED TO:
///
/// 1. 🌐 CREATE AZURE ACCOUNT:
///    - Go to https://portal.azure.com
///    - Create a new "Translator" resource
///    - Choose your subscription and resource group
///
/// 2. 🔑 GET YOUR CREDENTIALS:
///    - In Azure Portal, go to your Translator resource
///    - Click "Keys and Endpoint" in the left menu
///    - Copy "Key 1" (subscription key)
///    - Note your "Region" (e.g., eastus, westus2)
///
/// 3. � REPLACE THE VALUES BELOW:
///    - Replace 'YOUR_AZURE_SUBSCRIPTION_KEY' with your actual key
///    - Replace 'YOUR_AZURE_REGION' with your actual region
///    - Optionally modify the endpoint if needed
///
/// 4. 🎯 CUSTOMIZE (OPTIONAL):
///    - Add more languages in _languageCodes map below
///    - Add more fallback phrases in _getFallbackTranslation method
///
/// 💡 The service will use fallback translations when Azure is not configured
/// ========================================

class AzureTranslatorService {
  // � TODO: REPLACE WITH YOUR ACTUAL AZURE CREDENTIALS
  static const String _subscriptionKey =
      '6KLEhYPw2bD1idWMKwvtj5pSDq9DtjUqscfbrKpG1k6zqLXxaiCQJQQJ99BHACYeBjFXJ3w3AAAbACOGTgk5'; // � Put your Azure subscription key here
  static const String _region =
      'eastus'; // 🌍 Put your Azure region here (e.g., 'eastus', 'westus2')
  static const String _endpoint =
      'https://api.cognitive.microsofttranslator.com'; // 🔧 Usually no need to change this

  // 🌍 TODO: Add more language mappings here if you want to support additional languages
  // Current supported languages: English, Spanish, Japanese, Korean, Bengali
  // Azure Translator supports 100+ languages - add them here with their ISO codes
  static const Map<String, String> _languageCodes = {
    'English': 'en',
    'Spanish': 'es',
    'Japanese': 'ja',
    'Korean': 'ko',
    'Bengali': 'bn',
    // 📝 ADD MORE LANGUAGES HERE:
    // 'French': 'fr',
    // 'German': 'de',
    // 'Chinese Simplified': 'zh-Hans',
    // 'Arabic': 'ar',
    // 'Hindi': 'hi',
    // etc...
  };

  /// Translates text from source language to target language using Azure Translator
  static Future<String> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      // 🔑 AZURE CREDENTIALS CHECK:
      // Make sure you have replaced the placeholder values above with your actual credentials!
      if (_subscriptionKey == 'YOUR_AZURE_SUBSCRIPTION_KEY' ||
          _region == 'YOUR_AZURE_REGION') {
        // Use fallback translation
        return _getFallbackTranslation(text, targetLanguage) ??
            'Azure credentials not configured. Please replace the placeholder values in the code.';
      }

      // Get language codes
      final sourceCode = _languageCodes[sourceLanguage];
      final targetCode = _languageCodes[targetLanguage];

      if (sourceCode == null || targetCode == null) {
        throw Exception(
          'Unsupported language: $sourceLanguage or $targetLanguage',
        );
      }

      // Prepare the request
      final url = Uri.parse(
        '$_endpoint/translate?api-version=3.0&from=$sourceCode&to=$targetCode',
      );

      // 🌐 AZURE API CALL: This makes the actual translation request to Azure
      // The headers contain your subscription key and region
      final headers = {
        'Ocp-Apim-Subscription-Key':
            _subscriptionKey, // 🔑 Your Azure key from constants above
        'Ocp-Apim-Subscription-Region':
            _region, // 🌍 Your Azure region from constants above
        'Content-Type': 'application/json',
      };

      final body = jsonEncode([
        {'text': text},
      ]);

      // Make the API call
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        if (responseData.isNotEmpty &&
            responseData[0]['translations'] != null &&
            responseData[0]['translations'].isNotEmpty) {
          return responseData[0]['translations'][0]['text'];
        } else {
          throw Exception('Invalid response format from Azure Translator');
        }
      } else {
        throw Exception(
          'Translation failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      // Return fallback translation or error message
      return _getFallbackTranslation(text, targetLanguage) ??
          'Translation failed: ${e.toString()}';
    }
  }

  /// Detects the language of the input text
  static Future<String> detectLanguage(String text) async {
    try {
      // 🔑 AZURE CREDENTIALS CHECK FOR LANGUAGE DETECTION:
      // Make sure you have replaced the placeholder values above with your actual credentials!
      if (_subscriptionKey == 'YOUR_AZURE_SUBSCRIPTION_KEY' ||
          _region == 'YOUR_AZURE_REGION') {
        return 'Unknown';
      }

      final url = Uri.parse('$_endpoint/detect?api-version=3.0');

      final headers = {
        'Ocp-Apim-Subscription-Key': _subscriptionKey,
        'Ocp-Apim-Subscription-Region': _region,
        'Content-Type': 'application/json',
      };

      final body = jsonEncode([
        {'text': text},
      ]);

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        if (responseData.isNotEmpty && responseData[0]['language'] != null) {
          final detectedCode = responseData[0]['language'];

          // Convert back to language name
          for (final entry in _languageCodes.entries) {
            if (entry.value == detectedCode) {
              return entry.key;
            }
          }

          return 'Unknown';
        }
      }

      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Transliterates text to show phonetic pronunciation
  // 🔤 TRANSLITERATION: Converts text to phonetic script (e.g., Japanese to Romaji)
  // This helps users understand pronunciation of translated text
  static Future<String?> transliterateText({
    required String text,
    required String language,
  }) async {
    try {
      // 🔑 AZURE CREDENTIALS CHECK FOR TRANSLITERATION:
      if (_subscriptionKey == 'YOUR_AZURE_SUBSCRIPTION_KEY' ||
          _region == 'YOUR_AZURE_REGION') {
        return null; // No transliteration available without Azure
      }

      final languageCode = _languageCodes[language];
      if (languageCode == null) {
        return null;
      }

      // Only certain languages support transliteration
      final transliterationScripts = {
        'ja': 'Latn', // Japanese to Latin (Romaji)
        'ko': 'Latn', // Korean to Latin
        'bn': 'Latn', // Bengali to Latin
        'ar': 'Latn', // Arabic to Latin
        'hi': 'Latn', // Hindi to Latin
        'zh-Hans': 'Latn', // Chinese to Latin (Pinyin)
      };

      final targetScript = transliterationScripts[languageCode];
      if (targetScript == null) {
        return null; // Language doesn't support transliteration
      }

      final url = Uri.parse(
        '$_endpoint/transliterate?api-version=3.0&language=$languageCode&fromScript=&toScript=$targetScript',
      );

      final headers = {
        'Ocp-Apim-Subscription-Key': _subscriptionKey,
        'Ocp-Apim-Subscription-Region': _region,
        'Content-Type': 'application/json',
      };

      final body = jsonEncode([
        {'text': text},
      ]);

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        if (responseData.isNotEmpty && responseData[0]['text'] != null) {
          return responseData[0]['text'];
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Gets available translation languages
  // 📝 TODO: If you add more languages to _languageCodes above, they will automatically
  // appear here. This returns the list of supported languages for the UI.
  static List<String> getSupportedLanguages() {
    return _languageCodes.keys.toList();
  }

  /// Fallback translations for common phrases when Azure service is unavailable
  // 💡 FALLBACK SYSTEM: These translations are used when:
  // 1. Azure credentials are not configured
  // 2. Azure API is unavailable
  // 3. Network connection fails
  // 📝 TODO: Add more fallback phrases here if needed
  static String? _getFallbackTranslation(String text, String targetLanguage) {
    final fallbackTranslations = {
      // 📝 TODO: Add more common phrases here for better offline experience
      // Each phrase needs translations in all your supported languages
      "hello": {
        "English": "Hello",
        "Spanish": "Hola",
        "Japanese": "こんにちは",
        "Korean": "안녕하세요",
        "Bengali": "হ্যালো",
      },
      "goodbye": {
        "English": "Goodbye",
        "Spanish": "Adiós",
        "Japanese": "さようなら",
        "Korean": "안녕히 가세요",
        "Bengali": "বিদায়",
      },
      "thank you": {
        "English": "Thank you",
        "Spanish": "Gracias",
        "Japanese": "ありがとう",
        "Korean": "감사합니다",
        "Bengali": "ধন্যবাদ",
      },
      "yes": {
        "English": "Yes",
        "Spanish": "Sí",
        "Japanese": "はい",
        "Korean": "네",
        "Bengali": "হ্যাঁ",
      },
      "no": {
        "English": "No",
        "Spanish": "No",
        "Japanese": "いいえ",
        "Korean": "아니요",
        "Bengali": "না",
      },
      "please": {
        "English": "Please",
        "Spanish": "Por favor",
        "Japanese": "お願いします",
        "Korean": "부탁합니다",
        "Bengali": "অনুগ্রহ করে",
      },
      "excuse me": {
        "English": "Excuse me",
        "Spanish": "Disculpe",
        "Japanese": "すみません",
        "Korean": "실례합니다",
        "Bengali": "দুঃখিত",
      },
      "good morning": {
        "English": "Good morning",
        "Spanish": "Buenos días",
        "Japanese": "おはようございます",
        "Korean": "좋은 아침",
        "Bengali": "সুপ্রভাত",
      },
      "good night": {
        "English": "Good night",
        "Spanish": "Buenas noches",
        "Japanese": "おやすみなさい",
        "Korean": "안녕히 주무세요",
        "Bengali": "শুভ রাত্রি",
      },
      "how are you": {
        "English": "How are you?",
        "Spanish": "¿Cómo estás?",
        "Japanese": "元気ですか？",
        "Korean": "어떻게 지내세요?",
        "Bengali": "আপনি কেমন আছেন?",
      },
      // 💡 ADD MORE FALLBACK PHRASES HERE:
      // "I love you": {
      //   "English": "I love you",
      //   "Spanish": "Te amo",
      //   "Japanese": "愛してる",
      //   "Korean": "사랑해",
      //   "Bengali": "আমি তোমাকে ভালোবাসি",
      // },
    };

    final normalizedText = text.toLowerCase().trim();
    return fallbackTranslations[normalizedText]?[targetLanguage];
  }

  /// Checks if the Azure Translator service is properly configured
  // ✅ CONFIGURATION CHECK: This method verifies if Azure credentials are set up
  // Returns true when the placeholder values have been replaced with actual credentials
  static Future<bool> isConfigured() async {
    return _subscriptionKey != 'YOUR_AZURE_SUBSCRIPTION_KEY' &&
        _region != 'YOUR_AZURE_REGION' &&
        _subscriptionKey.isNotEmpty &&
        _region.isNotEmpty;
  }
}
