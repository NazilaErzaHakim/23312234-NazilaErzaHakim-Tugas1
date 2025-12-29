import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isTyping;

  ChatState({
    required this.messages,
    this.isLoading = false,
    this.isTyping = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isTyping,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class AiNotifier extends Notifier<ChatState> {
  late GenerativeModel _model;

  @override
  ChatState build() {
    _initModel();
    return ChatState(messages: []);
  }

  void _initModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      state = ChatState(
        messages: [
          ChatMessage(text: 'API Key Gemini tidak ditemukan', isUser: false),
        ],
      );
      return;
    }

    _model = GenerativeModel(
      model: 'gemini-3-flash-preview', // CEPAT
      apiKey: apiKey,
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(text: text, isUser: true),
      ],
      isLoading: true,
      isTyping: true,
    );

    try {
      final response = await _model.generateContent([
        Content.text(
          "Anda adalah asisten AI untuk mahasiswa Informatika. "
          "Jawab menggunakan Bahasa Indonesia yang sopan, singkat, dan jelas "
          "(maksimal 5 kalimat).\n\nPertanyaan: $text",
        ),
      ]);

      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            text: response.text ?? 'Maaf, saya tidak dapat menjawab.',
            isUser: false,
          ),
        ],
        isLoading: false,
        isTyping: false,
      );
    } catch (e) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(text: 'Error: $e', isUser: false),
        ],
        isLoading: false,
        isTyping: false,
      );
    }
  }
}

final aiProvider = NotifierProvider<AiNotifier, ChatState>(() => AiNotifier());
