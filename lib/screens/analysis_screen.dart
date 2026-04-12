import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coinsight/models/analysis_provider.dart';
import 'package:coinsight/models/watchlist_provider.dart';
import 'package:coinsight/widgets/chat_bubble.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_disposed || !_scrollController.hasClients) return;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_disposed || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage(AnalysisProvider provider) {
    final text = _controller.text.trim();
    if (text.isEmpty || provider.isLoading) return;

    final watchlist = context.read<WatchlistProvider>().watchlistCoins;
    _controller.clear();
    provider.sendMessage(text, watchlistCoins: watchlist).then((_) {
      _scrollToBottom();
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalysisProvider>(
      builder: (context, provider, _) {
        if (!provider.hasApiKey) {
          return _buildNoApiKeyState(context);
        }
        return Column(
          children: [
            Expanded(
              child: provider.messages.isEmpty
                  ? _buildEmptyState()
                  : _buildMessageList(provider),
            ),
            if (provider.error != null) _buildErrorBar(provider),
            _buildInputBar(provider),
          ],
        );
      },
    );
  }

  Widget _buildNoApiKeyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.key, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              'API Key Required',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your Anthropic API key in Settings to start chatting with CoinSight AI.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              'CoinSight AI',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask about crypto trends, coin analysis, or blockchain concepts. '
              'Your watchlist data is shared for context.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip('Analyze my watchlist'),
                _buildSuggestionChip('Bitcoin outlook?'),
                _buildSuggestionChip('Explain DeFi'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Consumer<AnalysisProvider>(
      builder: (context, provider, _) {
        return ActionChip(
          label: Text(text, style: const TextStyle(fontSize: 13)),
          backgroundColor: const Color(0xFF252525),
          onPressed: () {
            _controller.text = text;
            _sendMessage(provider);
          },
        );
      },
    );
  }

  Widget _buildMessageList(AnalysisProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.messages.length) {
          return _buildTypingIndicator();
        }
        final message = provider.messages[index];
        return AnimatedSlide(
          duration: const Duration(milliseconds: 250),
          offset: Offset.zero,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: 1.0,
            child: ChatBubble(
              text: message.content,
              isUser: message.role == 'user',
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Thinking...',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBar(AnalysisProvider provider) {
    return Dismissible(
      key: ValueKey(provider.error),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => provider.clearError(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        child: Row(
          children: [
            Icon(Icons.error_outline,
                size: 16, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                provider.error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => provider.clearError(),
              child: Icon(Icons.close,
                  size: 16, color: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(AnalysisProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(
          top: BorderSide(
            color: Colors.grey[800]!.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (provider.messages.isNotEmpty)
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.grey[600]),
                onPressed: () => _confirmClearChat(provider),
                tooltip: 'Clear chat',
              ),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                enabled: !provider.isLoading,
                onSubmitted: (_) => _sendMessage(provider),
                decoration: InputDecoration(
                  hintText: provider.isLoading
                      ? 'Waiting for response...'
                      : 'Ask about crypto...',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.send,
                color: provider.isLoading
                    ? Colors.grey[700]
                    : Theme.of(context).colorScheme.primary,
              ),
              onPressed:
                  provider.isLoading ? null : () => _sendMessage(provider),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearChat(AnalysisProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text('Clear chat?'),
        content: const Text('This will delete all messages in this conversation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearChat();
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Clear',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
