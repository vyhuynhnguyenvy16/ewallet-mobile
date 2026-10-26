import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const _chatBlue = Color(0xFF2563EB);
const _chatNavy = Color(0xFF1E3A8A);
const _chatSky = Color(0xFF0EA5E9);
const _chatMuted = Color(0xFF667085);

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  static const _suggestions = [
    'Chi tiêu tháng này thế nào?',
    'Tôi có thể tiết kiệm thêm không?',
    'Danh mục nào tốn nhiều nhất?',
    'Dự báo cuối tháng của tôi?',
  ];

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          'Xin chào Khoa! Tôi là trợ lý AI tài chính của bạn. Tôi có thể phân tích chi tiêu, đưa ra gợi ý tiết kiệm và trả lời các câu hỏi về tài chính của bạn.',
      isAssistant: true,
      time: '09:23',
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              children: [
                for (final message in _messages)
                  _MessageBubble(message: message),
                if (_messages.length == 1) ...[
                  const SizedBox(height: 14),
                  for (final suggestion in _suggestions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _SuggestionButton(
                          label: suggestion,
                          onPressed: () => _sendMessage(suggestion),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.viewPaddingOf(context).top + 12,
        16,
        16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_chatNavy, _chatBlue, _chatSky],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Đóng trò chuyện',
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0x2EFFFFFF),
              minimumSize: const Size(40, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(CupertinoIcons.back, size: 19),
          ),
          const SizedBox(width: 12),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0x2EFFFFFF),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.sparkles,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trợ lý AI Tài chính',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Row(
                  children: [
                    _OnlineDot(),
                    SizedBox(width: 6),
                    Text(
                      'Đang hoạt động',
                      style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    final canSend = _messageController.text.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.viewInsetsOf(context).bottom > 0
            ? 10
            : MediaQuery.viewPaddingOf(context).bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E7FF))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F2563EB),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48, maxHeight: 120),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FC),
                border: Border.all(color: const Color(0xFFE0E7FF), width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submitMessage(),
                decoration: const InputDecoration(
                  hintText: 'Hỏi về tài chính của bạn...',
                  hintStyle: TextStyle(color: _chatMuted, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 13),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: canSend ? _submitMessage : null,
              tooltip: 'Gửi tin nhắn',
              style: IconButton.styleFrom(
                backgroundColor: canSend ? _chatBlue : const Color(0xFFF1F5F9),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFF1F5F9),
                disabledForegroundColor: _chatMuted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(CupertinoIcons.paperplane_fill, size: 19),
            ),
          ),
        ],
      ),
    );
  }

  void _submitMessage() {
    _sendMessage(_messageController.text);
  }

  void _sendMessage(String value) {
    final text = value.trim();
    if (text.isEmpty) return;

    final time = TimeOfDay.now().format(context);
    setState(() {
      _messages.add(_ChatMessage(text: text, isAssistant: false, time: time));
      _messageController.clear();
      _messages.add(
        _ChatMessage(text: _answerFor(text), isAssistant: true, time: time),
      );
    });
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

  String _answerFor(String question) {
    if (question == _suggestions[0]) {
      return 'Tháng 9 bạn đã chi tổng 7.240.000đ — thấp hơn 8% so với tháng 8. Danh mục tốn nhiều nhất là Ăn uống (2.850.000đ), tiếp theo là Mua sắm (1.920.000đ). Bạn đang kiểm soát chi tiêu khá tốt.';
    }
    if (question == _suggestions[1]) {
      return 'Dựa trên các khoản chi hiện tại, bạn có thể đặt mục tiêu tiết kiệm bằng cách theo dõi ngân sách Ăn uống và Mua sắm. Hãy kiểm tra các giao dịch định kỳ để tìm khoản có thể giảm.';
    }
    if (question == _suggestions[2]) {
      return 'Ăn uống đang là danh mục chi tiêu lớn nhất với 2.850.000đ, tiếp theo là Mua sắm với 1.920.000đ.';
    }
    if (question == _suggestions[3]) {
      return 'Tổng chi tháng này hiện là 7.240.000đ. Đây là ước tính dựa trên dữ liệu giao dịch đang hiển thị; hãy theo dõi ngân sách để cập nhật khi có giao dịch mới.';
    }
    return 'Mình chưa kết nối dịch vụ AI nên chưa thể phân tích câu hỏi này. Bạn có thể thử một trong các câu hỏi gợi ý để xem thông tin tài chính mẫu.';
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isAssistant,
    required this.time,
  });

  final String text;
  final bool isAssistant;
  final String time;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    if (message.isAssistant) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const _AssistantAvatar(size: 32),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border.fromBorderSide(
                        BorderSide(color: Color(0xFFE0E7FF), width: 1.5),
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x122563EB),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message.text,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Text(
                      message.time,
                      style: const TextStyle(color: _chatMuted, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 290),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_chatBlue, _chatSky]),
                borderRadius: BorderRadius.circular(
                  16,
                ).copyWith(bottomRight: const Radius.circular(4)),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Text(
                message.time,
                style: const TextStyle(color: _chatMuted, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionButton extends StatelessWidget {
  const _SuggestionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _chatBlue,
        backgroundColor: const Color(0xFFF5F7FC),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        side: const BorderSide(color: Color(0xFFBFDBFE)),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}

class _AssistantAvatar extends StatelessWidget {
  const _AssistantAvatar({this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_chatBlue, _chatSky]),
        borderRadius: BorderRadius.circular(size * 0.34),
      ),
      alignment: Alignment.center,
      child: Text(
        'AI',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.3,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: Color(0xFF34D399),
        shape: BoxShape.circle,
      ),
    );
  }
}
