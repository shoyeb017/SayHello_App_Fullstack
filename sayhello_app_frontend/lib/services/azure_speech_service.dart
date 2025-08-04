import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AzureSpeechService {
  // Azure Speech Service credentials
  static const String _subscriptionKey =
      '4oosJGSxuX6UBZsqpISOhDXJr3gNeSIlVmc9MuxHM1Zp4dm7JUHdJQQJ99BHACYeBjFXJ3w3AAAYACOGt6HR';
  static const String _region = 'eastus';

  // Text-to-Speech endpoint
  static String get _ttsEndpoint =>
      'https://$_region.tts.speech.microsoft.com/cognitiveservices/v1';

  // Audio player instance
  static final AudioPlayer _audioPlayer = AudioPlayer();

  // Language mapping for Azure Speech Service
  static const Map<String, Map<String, String>> _languageVoiceMapping = {
    'English': {
      'locale': 'en-US',
      'voice': 'en-US-JennyNeural',
      'gender': 'Female',
    },
    'Spanish': {
      'locale': 'es-ES',
      'voice': 'es-ES-ElviraNeural',
      'gender': 'Female',
    },
    'Japanese': {
      'locale': 'ja-JP',
      'voice': 'ja-JP-NanamiNeural',
      'gender': 'Female',
    },
    'Korean': {
      'locale': 'ko-KR',
      'voice': 'ko-KR-SunHiNeural',
      'gender': 'Female',
    },
    'Bengali': {
      'locale': 'bn-BD',
      'voice': 'bn-BD-NabanitaNeural',
      'gender': 'Female',
    },
  };

  /// Check if Azure Speech Service is properly configured
  static Future<bool> isConfigured() async {
    try {
      // Test the service with a simple request
      final response = await http.get(
        Uri.parse(
          'https://$_region.tts.speech.microsoft.com/cognitiveservices/voices/list',
        ),
        headers: {'Ocp-Apim-Subscription-Key': _subscriptionKey},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Convert text to speech and play it
  static Future<bool> speakText({
    required String text,
    required String language,
    double rate = 1.0, // Speech rate (0.5 to 2.0)
    double pitch = 1.0, // Speech pitch (0.5 to 2.0)
  }) async {
    try {
      if (text.trim().isEmpty) {
        throw Exception('Text cannot be empty');
      }

      // Get voice configuration for the language
      final voiceConfig = _languageVoiceMapping[language];
      if (voiceConfig == null) {
        throw Exception('Language not supported: $language');
      }

      // Create SSML (Speech Synthesis Markup Language) content
      final ssml = _buildSSML(
        text: text,
        voice: voiceConfig['voice']!,
        rate: rate,
        pitch: pitch,
      );

      // Make request to Azure Speech Service
      final response = await http.post(
        Uri.parse(_ttsEndpoint),
        headers: {
          'Ocp-Apim-Subscription-Key': _subscriptionKey,
          'Content-Type': 'application/ssml+xml',
          'X-Microsoft-OutputFormat': 'audio-16khz-128kbitrate-mono-mp3',
          'User-Agent': 'SayHello-App',
        },
        body: utf8.encode(ssml),
      );

      if (response.statusCode == 200) {
        // Play the audio directly from bytes
        await _playAudioFromBytes(response.bodyBytes);
        return true;
      } else {
        throw Exception(
          'Speech synthesis failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Azure Speech Service error: $e');
      return false;
    }
  }

  /// Build SSML content for speech synthesis
  static String _buildSSML({
    required String text,
    required String voice,
    double rate = 1.0,
    double pitch = 1.0,
  }) {
    // Ensure rate and pitch are within valid ranges
    rate = rate.clamp(0.5, 2.0);
    pitch = pitch.clamp(0.5, 2.0);

    // Convert rate to percentage
    final ratePercent = ((rate - 1.0) * 100).round();
    final rateString = ratePercent >= 0
        ? '+${ratePercent}%'
        : '${ratePercent}%';

    // Convert pitch to percentage
    final pitchPercent = ((pitch - 1.0) * 100).round();
    final pitchString = pitchPercent >= 0
        ? '+${pitchPercent}%'
        : '${pitchPercent}%';

    return '''<?xml version="1.0" encoding="UTF-8"?>
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="en-US">
  <voice name="$voice">
    <prosody rate="$rateString" pitch="$pitchString">
      ${_escapeXml(text)}
    </prosody>
  </voice>
</speak>''';
  }

  /// Escape XML special characters
  static String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Play audio from bytes
  static Future<void> _playAudioFromBytes(List<int> audioBytes) async {
    try {
      // Convert bytes to Uint8List
      final uint8List = Uint8List.fromList(audioBytes);

      // Play audio from bytes
      await _audioPlayer.play(BytesSource(uint8List));
    } catch (e) {
      throw Exception('Failed to play audio: $e');
    }
  }

  /// Stop current speech playback
  static Future<void> stopSpeaking() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping speech: $e');
    }
  }

  /// Check if currently speaking
  static Future<bool> isSpeaking() async {
    try {
      final state = await _audioPlayer.getCurrentPosition();
      return state != null && state.inMilliseconds > 0;
    } catch (e) {
      return false;
    }
  }

  /// Get available voices for a language
  static Map<String, String>? getVoiceForLanguage(String language) {
    return _languageVoiceMapping[language];
  }

  /// Get all supported languages
  static List<String> getSupportedLanguages() {
    return _languageVoiceMapping.keys.toList();
  }

  /// Dispose audio player resources
  static Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      print('Error disposing audio player: $e');
    }
  }
}
