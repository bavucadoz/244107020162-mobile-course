import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/chat_message.dart';
import '../providers/ai_chat_provider.dart';

enum _ApiKeyDialogAction { delete }

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;
    _messageController.clear();
    await ref.read(aiChatControllerProvider.notifier).sendMessage(text);
    _scrollToLatest();
  }

  Future<void> _showApiKeyDialog() async {
    final hasKey = await ref.read(aiChatRepositoryProvider).hasApiKey();
    if (!mounted) return;

    // The dialog owns its TextEditingController. This is important because
    // showDialog's Future can complete as soon as pop is requested, while the
    // reverse route animation may still be rebuilding the TextField.
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => _ApiKeyDialog(hasKey: hasKey),
    );

    if (!mounted || result == null) return;

    try {
      _showMessage('Menyimpan pengaturan API key...');
      final notifier = ref.read(aiChatControllerProvider.notifier);
      if (result == _ApiKeyDialogAction.delete) {
        await notifier.removeApiKey();
        if (!mounted) return;
        ref.invalidate(aiApiKeyConfiguredProvider);
        _showMessage('API key dihapus dari perangkat.');
      } else if (result is String) {
        await notifier.saveApiKey(result);
        if (!mounted) return;
        ref.invalidate(aiApiKeyConfiguredProvider);
        _showMessage('API key berhasil disimpan.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('API key gagal disimpan. Periksa kembali perangkat.');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatControllerProvider);
    ref.listen(aiChatControllerProvider, (previous, next) {
      final previousLast = previous?.messages.isNotEmpty == true
          ? previous!.messages.last.text
          : '';
      final nextLast = next.messages.isNotEmpty ? next.messages.last.text : '';
      if (previous?.messages.length != next.messages.length ||
          previousLast != nextLast) {
        _scrollToLatest();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, size: 21),
            SizedBox(width: 8),
            Text('CampusMate AI'),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('ai-settings-button'),
            tooltip: 'Atur API key',
            onPressed: _showApiKeyDialog,
            icon: const Icon(Icons.key_outlined),
          ),
          IconButton(
            tooltip: 'Percakapan baru',
            onPressed: chatState.isLoading
                ? null
                : () => ref.read(aiChatControllerProvider.notifier).clearConversation(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.privacy_tip_outlined, size: 19),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Jangan kirim NIK, kata sandi, token, nomor telepon, alamat, atau data rahasia. Jawaban AI perlu diperiksa kembali.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: chatState.messages.isEmpty
                ? const _WelcomeView()
                : ListView.builder(
                    key: const Key('ai-chat-messages'),
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      final isPending = chatState.isLoading &&
                          index == chatState.messages.length - 1 &&
                          message.role == ChatRole.model &&
                          message.text.isEmpty;
                      return _MessageBubble(
                        message: message,
                        isPending: isPending,
                      );
                    },
                  ),
          ),
          if (chatState.errorMessage != null)
            Container(
              key: const Key('ai-error-fallback'),
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chatState.errorMessage!),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => ref
                          .read(aiChatControllerProvider.notifier)
                          .retryLastMessage(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba lagi'),
                    ),
                  ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('ai-chat-input'),
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 2000,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Tulis pertanyaan...',
                        counterText: '',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    key: const Key('ai-send-button'),
                    onPressed: chatState.isLoading ? null : _sendMessage,
                    icon: chatState.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ApiKeyDialog extends StatefulWidget {
  const _ApiKeyDialog({required this.hasKey});

  final bool hasKey;

  @override
  State<_ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<_ApiKeyDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    // The controller is disposed with the dialog State, after Flutter has
    // removed the TextField subtree (including its transition widgets).
    _controller.dispose();
    super.dispose();
  }

  void _closeDialog([Object? result]) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Pengaturan Gemini API'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.hasKey
                ? 'API key sudah tersimpan. Masukkan key baru untuk menggantinya.'
                : 'Masukkan Gemini API key. Key disimpan menggunakan secure storage.',
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('gemini-api-key-field'),
            controller: _controller,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            maxLines: 1,
            decoration: const InputDecoration(
              labelText: 'Gemini API key',
              hintText: 'Tempel API key di sini',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jangan bagikan API key kepada orang lain atau memasukkannya ke repository Git.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        if (widget.hasKey)
          TextButton(
            onPressed: () => _closeDialog(_ApiKeyDialogAction.delete),
            child: const Text('Hapus key'),
          ),
        TextButton(
          onPressed: () => _closeDialog(),
          child: const Text('Batal'),
        ),
        FilledButton(
          key: const Key('save-gemini-api-key-button'),
          onPressed: () {
            final key = _controller.text.trim();
            if (key.isEmpty) return;
            _closeDialog(key);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class _WelcomeView extends StatelessWidget {
  const _WelcomeView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Halo, saya CampusMate!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Asisten AI untuk membantu memahami materi, menyusun ide, dan meningkatkan produktivitas belajar.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Atur Gemini API key melalui ikon kunci untuk mulai mengobrol.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, this.isPending = false});

  final ChatMessage message;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: isPending
            ? const SizedBox(
                width: 42,
                height: 18,
                child: LinearProgressIndicator(),
              )
            : SelectableText(message.text),
      ),
    );
  }
}
