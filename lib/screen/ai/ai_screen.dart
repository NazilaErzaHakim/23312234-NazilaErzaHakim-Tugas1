import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nazilaerzahakim/providers/ai_provider.dart';
import 'package:nazilaerzahakim/providers/theme_provider.dart';

class AiScreen extends ConsumerWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(aiProvider);
    final notifier = ref.read(aiProvider.notifier);
    final controller = TextEditingController();
    final scrollController = ScrollController();

    ref.listen(aiProvider, (_, __) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Column(
          children: [
            Text(
              'Nazila AI Assistant ✨',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Smart helper for Student',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00BFA5), Color(0xFF1DE9B6), Color(0xFF64FFDA)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode_rounded),
            onPressed: () {
              ref.read(themeProvider.notifier).state = !ref.read(themeProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(14),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: chatState.messages[index]);
              },
            ),
          ),

          // indikator AI mengetik
          if (chatState.isTyping)
            const Padding(
              padding: EdgeInsets.only(left: 18, bottom: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '🤖 AI sedang mengetik...',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

          if (chatState.isLoading) const LinearProgressIndicator(minHeight: 2),

          ChatInput(
            controller: controller,
            onSend: () {
              notifier.sendMessage(controller.text);
              controller.clear();
            },
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF00BFA5), Color(0xFF1DE9B6)],
                )
              : const LinearGradient(
                  colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInput({super.key, required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Tanya apa saja ke AI...',
                  filled: true,
                  fillColor: const Color(0xFFF1F3F6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF00BFA5),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
