# Azure Speech Service Integration

## Overview

The Azure Speech Service has been integrated into the SayHello app to provide text-to-speech functionality for both input and translated output text.

## Features

- **Input Text Speech**: Listen to the text you've entered in the source language
- **Output Text Speech**: Listen to the translated text in the target language
- **Real-time Controls**: Start/stop speech playback with visual indicators
- **Multi-language Support**: Supports all languages available in the translator (English, Spanish, Japanese, Korean, Bengali)

## Azure Configuration

- **Service**: Azure Cognitive Services - Speech Service
- **Region**: East US (eastus)
- **Subscription Key**: Already configured in the service code
- **Endpoint**: https://eastus.tts.speech.microsoft.com/cognitiveservices/v1

## Supported Languages and Voices

| Language | Locale | Voice                | Gender |
| -------- | ------ | -------------------- | ------ |
| English  | en-US  | en-US-JennyNeural    | Female |
| Spanish  | es-ES  | es-ES-ElviraNeural   | Female |
| Japanese | ja-JP  | ja-JP-NanamiNeural   | Female |
| Korean   | ko-KR  | ko-KR-SunHiNeural    | Female |
| Bengali  | bn-BD  | bn-BD-NabanitaNeural | Female |

## UI Components

1. **Input Text Speech Button**: Located below the input text field

   - Icon: `volume_up` (when ready) / `stop` (when another audio is playing) / loading spinner (when speaking)
   - Tooltip: "Listen to text" / "Stop speech" / "Speaking..."

2. **Output Text Speech Button**: Located below the translated text
   - Icon: `volume_up` (when ready) / `stop` (when another audio is playing) / loading spinner (when speaking)
   - Tooltip: "Listen to translation" / "Stop speech" / "Speaking..."

## Technical Implementation

- **Service File**: `lib/services/azure_speech_service.dart`
- **Audio Package**: `audioplayers: ^5.2.1`
- **Audio Format**: MP3, 16kHz, 128kbps, mono
- **SSML Support**: Yes, with rate and pitch control capabilities

## Error Handling

- Network connectivity issues
- Invalid language selection
- Empty text input
- Azure service errors
- Audio playback failures

## Usage Flow

1. User enters text in the input field
2. Speech button becomes available below the text
3. User clicks the speech button to hear the text
4. After translation, another speech button appears below the translated text
5. User can listen to the translation in the target language
6. Users can stop any playing audio by clicking the stop button

## Dependencies Added

```yaml
audioplayers: ^5.2.1
```

## Notes

- Only one audio can play at a time
- Speech buttons are disabled when text is empty or contains errors
- The pronunciation section (transliteration) does not have speech functionality as requested
- All speech synthesis uses Azure's Neural voices for natural-sounding speech
