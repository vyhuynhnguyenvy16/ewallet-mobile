import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ai_chat_screen.dart';
import 'finance_screens.dart';

const _dashboardInk = Color(0xFF0F172A);
const _dashboardMuted = Color(0xFF94A3B8);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _blue = Color(0xFF2563EB);
  static const _sky = Color(0xFF0EA5E9);

  bool _balanceVisible = true;
  int _selectedTab = 0;
  Offset? _assistantPosition;
  int? _assistantPointer;
  Offset? _assistantPointerOrigin;
  Offset? _assistantPositionOrigin;
  final _dashboardStackKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final overlayStyle = _selectedTab == 0 || _selectedTab == 4
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FC),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final media = MediaQuery.of(context);
            final bottomLimit =
                constraints.maxHeight - media.viewPadding.bottom - 84;
            final position =
                _assistantPosition ?? Offset(16, media.viewPadding.top + 296);
            final maxTop = bottomLimit.clamp(
              media.viewPadding.top + 8,
              constraints.maxHeight - 64,
            );
            final clampedPosition = Offset(
              position.dx.clamp(8, constraints.maxWidth - 64),
              position.dy.clamp(media.viewPadding.top + 8, maxTop),
            );

            return Stack(
              key: _dashboardStackKey,
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final slideAnimation = Tween<Offset>(
                            begin: const Offset(0, 0.025),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: slideAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: _selectedTab == 0
                            ? SingleChildScrollView(
                                key: const ValueKey('overview-tab'),
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  children: [
                                    _buildBalanceHeader(),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        20,
                                        16,
                                        0,
                                      ),
                                      child: _buildShortcuts(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        14,
                                        16,
                                        0,
                                      ),
                                      child: _buildInsightCard(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        14,
                                        16,
                                        0,
                                      ),
                                      child: _buildGroupSplits(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        14,
                                        16,
                                        0,
                                      ),
                                      child: _buildRecentTransactions(),
                                    ),
                                  ],
                                ),
                              )
                            : FinanceScreen(
                                key: ValueKey(_selectedTab),
                                index: _selectedTab,
                                onLogout: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login',
                                    (_) => false,
                                  );
                                },
                              ),
                      ),
                    ),
                    _buildBottomNavigation(),
                  ],
                ),
                Positioned(
                  left: clampedPosition.dx,
                  top: clampedPosition.dy,
                  child: Listener(
                    key: const ValueKey('assistant-chat-drag-handle'),
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (event) {
                      final stackBox =
                          _dashboardStackKey.currentContext?.findRenderObject()
                              as RenderBox?;
                      if (stackBox != null) {
                        _assistantPointer = event.pointer;
                        _assistantPointerOrigin = stackBox.globalToLocal(
                          event.position,
                        );
                        _assistantPositionOrigin = clampedPosition;
                      }
                    },
                    onPointerMove: (event) {
                      if (event.pointer != _assistantPointer) return;
                      final stackBox =
                          _dashboardStackKey.currentContext?.findRenderObject()
                              as RenderBox?;
                      final pointerOrigin = _assistantPointerOrigin;
                      final positionOrigin = _assistantPositionOrigin;
                      if (stackBox == null ||
                          pointerOrigin == null ||
                          positionOrigin == null) {
                        return;
                      }
                      final pointerPosition = stackBox.globalToLocal(
                        event.position,
                      );
                      final nextPosition =
                          positionOrigin + pointerPosition - pointerOrigin;
                      setState(() {
                        _assistantPosition = Offset(
                          nextPosition.dx.clamp(8, constraints.maxWidth - 64),
                          nextPosition.dy.clamp(
                            media.viewPadding.top + 8,
                            maxTop,
                          ),
                        );
                      });
                    },
                    onPointerUp: (event) =>
                        _clearAssistantPointer(event.pointer),
                    onPointerCancel: (event) =>
                        _clearAssistantPointer(event.pointer),
                    child: _buildAssistantButton(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBalanceHeader() {
    final topInset = MediaQuery.viewPaddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào',
                      style: TextStyle(color: Color(0xFF667085), fontSize: 13),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Nguyễn Minh Khoa',
                      style: TextStyle(
                        color: _dashboardInk,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _notificationButton(),
              const SizedBox(width: 10),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3C4),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14F59E0B),
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'K',
                  style: TextStyle(
                    color: Color(0xFFB7791F),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            key: const ValueKey('home-balance-card'),
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3478F6),
                  Color(0xFF2563EB),
                  Color(0xFF1D4ED8),
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x222563EB),
                  blurRadius: 18,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Số dư ví',
                      style: TextStyle(
                        color: Color(0xBFFFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () =>
                          setState(() => _balanceVisible = !_balanceVisible),
                      tooltip: _balanceVisible
                          ? 'Ẩn số dư ví'
                          : 'Hiện số dư ví',
                      constraints: const BoxConstraints.tightFor(
                        width: 44,
                        height: 44,
                      ),
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        _balanceVisible
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                        color: const Color(0xBFFFFFFF),
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _balanceVisible ? '24.580.000đ' : '••••••••',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Expanded(
                      child: _MonthlyAmount(
                        title: 'THU THÁNG NÀY',
                        amount: '+18.500.000đ',
                        amountColor: Color(0xFF86EFAC),
                      ),
                    ),
                    SizedBox(
                      height: 32,
                      child: VerticalDivider(
                        width: 24,
                        thickness: 1,
                        color: Color(0x33FFFFFF),
                      ),
                    ),
                    Expanded(
                      child: _MonthlyAmount(
                        title: 'CHI THÁNG NÀY',
                        amount: '-7.240.000đ',
                        amountColor: Color(0xFFFCA5A5),
                      ),
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

  Widget _notificationButton() {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            onPressed: () => _showMessage('Bạn chưa có thông báo mới.'),
            tooltip: 'Thông báo',
            padding: EdgeInsets.zero,
            icon: const Icon(
              CupertinoIcons.bell_fill,
              color: Color(0xFF2563EB),
              size: 21,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShortcuts() {
    const shortcuts = [
      _ShortcutData(
        label: 'Nạp tiền',
        icon: CupertinoIcons.arrow_down_to_line,
        iconColor: Color(0xFF059669),
        iconBackground: Color(0xFFECFDF5),
        borderColor: Color(0xFFBBF7D0),
      ),
      _ShortcutData(
        label: 'Rút tiền',
        icon: CupertinoIcons.arrow_up_to_line,
        iconColor: Color(0xFF2563EB),
        iconBackground: Color(0xFFEFF6FF),
        borderColor: Color(0xFFBFDBFE),
      ),
      _ShortcutData(
        label: 'Chuyển tiền',
        icon: CupertinoIcons.arrow_right_arrow_left,
        iconColor: Color(0xFF7C3AED),
        iconBackground: Color(0xFFF5F3FF),
        borderColor: Color(0xFFDDD6FE),
      ),
      _ShortcutData(
        label: 'Thanh toán',
        icon: CupertinoIcons.creditcard,
        iconColor: Color(0xFFD97706),
        iconBackground: Color(0xFFFFF4D6),
        borderColor: Color(0xFFFDE68A),
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < shortcuts.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _ShortcutButton(
              data: shortcuts[i],
              onTap: () =>
                  _showMessage('${shortcuts[i].label} đang được chuẩn bị.'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFFEFCE8)],
        ),
        border: Border.all(color: const Color(0xFFE3EAF5)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C101828),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_blue, _sky]),
              borderRadius: BorderRadius.circular(11),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x402563EB),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI PHÂN TÍCH',
                  style: TextStyle(
                    color: _blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 13,
                      height: 1.45,
                    ),
                    children: [
                      TextSpan(text: 'Chi tiêu ăn uống tháng này tăng '),
                      TextSpan(
                        text: '23%',
                        style: TextStyle(
                          color: Color(0xFFDB2777),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: '. Bạn có muốn xem gợi ý tiết kiệm?'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(CupertinoIcons.chevron_right, color: _blue, size: 18),
        ],
      ),
    );
  }

  Widget _buildGroupSplits() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration,
      child: Column(
        children: [
          _SectionHeading(
            title: 'Chia tiền nhóm',
            onSeeAll: () => _showMessage('Đang mở danh sách chia tiền nhóm.'),
          ),
          const SizedBox(height: 14),
          const _GroupSplitRow(
            title: 'Du lịch Đà Lạt',
            members: ['K', 'L', 'A', 'G'],
            unpaidCount: '2 người chưa trả',
            amount: '850.000đ',
          ),
          const SizedBox(height: 8),
          const _GroupSplitRow(
            title: 'Tiệc sinh nhật Linh',
            members: ['K', 'N', 'P', '+3'],
            unpaidCount: '3 người chưa trả',
            amount: '1.200.000đ',
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    const transactions = [
      _TransactionData(
        initials: 'AU',
        name: 'Grab Food',
        category: 'Ăn uống',
        time: '10:30',
        amount: '-85.000đ',
        color: Color(0xFFDB2777),
        background: Color(0xFFFDF2F8),
      ),
      _TransactionData(
        initials: 'TN',
        name: 'Lương tháng 9',
        category: 'Thu nhập',
        time: '09:00',
        amount: '+18.500.000đ',
        color: Color(0xFF059669),
        background: Color(0xFFECFDF5),
        isIncome: true,
      ),
      _TransactionData(
        initials: 'MS',
        name: 'Shopee',
        category: 'Mua sắm',
        time: 'Hôm qua',
        amount: '-320.000đ',
        color: Color(0xFFD97706),
        background: Color(0xFFFFFBEB),
      ),
      _TransactionData(
        initials: 'CK',
        name: 'Bảo Linh',
        category: 'Chuyển tiền',
        time: 'Hôm qua',
        amount: '-500.000đ',
        color: Color(0xFF2563EB),
        background: Color(0xFFEFF6FF),
      ),
      _TransactionData(
        initials: 'HD',
        name: 'Điện nước tháng 9',
        category: 'Hóa đơn',
        time: '2 ngày trước',
        amount: '-450.000đ',
        color: Color(0xFF7C3AED),
        background: Color(0xFFF5F3FF),
      ),
    ];

    return Column(
      children: [
        _SectionHeading(
          title: 'Giao dịch gần đây',
          onSeeAll: () => _selectTab(1),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: _cardDecoration,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < transactions.length; i++) ...[
                _TransactionRow(data: transactions[i]),
                if (i < transactions.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    const tabs = [
      (label: 'Trang chủ', icon: Icons.home_outlined),
      (label: 'Giao dịch', icon: CupertinoIcons.doc_text),
      (label: 'QR Pay', icon: CupertinoIcons.qrcode),
      (label: 'Ngân sách', icon: CupertinoIcons.chart_bar),
      (label: 'Tài khoản', icon: CupertinoIcons.person),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xF7FFFFFF),
        border: const Border(top: BorderSide(color: Color(0xFFE9EEF6))),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C101828),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < tabs.length; i++)
                _BottomNavItem(
                  label: tabs[i].label,
                  icon: tabs[i].icon,
                  isSelected: _selectedTab == i,
                  isPrimary: i == 2,
                  onTap: () => _selectTab(i),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantButton() {
    return Semantics(
      button: true,
      label: 'Chat với trợ lý AI tài chính',
      child: InkWell(
        key: const ValueKey('assistant-chat-button'),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const AiChatScreen())),
        customBorder: const CircleBorder(),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [_blue, _sky]),
            boxShadow: [
              BoxShadow(
                color: Color(0x662563EB),
                blurRadius: 24,
                offset: Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            child: Image.asset(
              'assets/chatbot-speech-bubble.png',
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  void _selectTab(int index) {
    setState(() => _selectedTab = index);
  }

  void _clearAssistantPointer(int pointer) {
    if (pointer != _assistantPointer) return;
    _assistantPointer = null;
    _assistantPointerOrigin = null;
    _assistantPositionOrigin = null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: const [
      BoxShadow(color: Color(0x0C101828), blurRadius: 16, offset: Offset(0, 4)),
    ],
  );
}

class _MonthlyAmount extends StatelessWidget {
  const _MonthlyAmount({
    required this.title,
    required this.amount,
    required this.amountColor,
  });

  final String title;
  final String amount;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0x99FFFFFF),
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            amount,
            style: TextStyle(
              color: amountColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ShortcutData {
  const _ShortcutData({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.borderColor,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color borderColor;
}

class _ShortcutButton extends StatelessWidget {
  const _ShortcutButton({required this.data, required this.onTap});

  final _ShortcutData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const labelStyle = TextStyle(
          color: Color(0xFF475569),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        );
        var label = data.label;
        if (label == 'Chuyển tiền') {
          final painter = TextPainter(
            text: TextSpan(
              text: 'Chuyển tiền',
              style: labelStyle.copyWith(
                fontFamily: Theme.of(context).textTheme.bodySmall?.fontFamily,
              ),
            ),
            textDirection: Directionality.of(context),
            maxLines: 1,
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          if (painter.width > constraints.maxWidth - 10) {
            label = 'Giao dịch';
          }
        }

        return Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: data.borderColor.withValues(alpha: 0.75)),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 14),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: data.iconBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(data.icon, color: data.iconColor, size: 22),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: labelStyle,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF2563EB),
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text('Xem tất cả'),
        ),
      ],
    );
  }
}

class _GroupSplitRow extends StatelessWidget {
  const _GroupSplitRow({
    required this.title,
    required this.members,
    required this.unpaidCount,
    required this.amount,
  });

  final String title;
  final List<String> members;
  final String unpaidCount;
  final String amount;

  static const _avatarColors = [
    Color(0xFF3C8CDD),
    Color(0xFF8C3CDD),
    Color(0xFFDD3C8C),
    Color(0xFFDD8C3C),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        border: Border.all(color: const Color(0xFFE0E7FF)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(
                      width: 64,
                      height: 20,
                      child: Stack(
                        children: [
                          for (var i = 0; i < members.length; i++)
                            Positioned(
                              left: i * 14,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color:
                                      _avatarColors[i % _avatarColors.length],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  members[i],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        unpaidCount,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _dashboardMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  color: Color(0xFFD97706),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Đang chờ',
                  style: TextStyle(
                    color: Color(0xFFD97706),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionData {
  const _TransactionData({
    required this.initials,
    required this.name,
    required this.category,
    required this.time,
    required this.amount,
    required this.color,
    required this.background,
    this.isIncome = false,
  });

  final String initials;
  final String name;
  final String category;
  final String time;
  final String amount;
  final Color color;
  final Color background;
  final bool isIncome;
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.data});

  final _TransactionData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.background,
              border: Border.all(color: data.color.withValues(alpha: 0.14)),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              data.initials,
              style: TextStyle(
                color: data.color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: data.background,
                        border: Border.all(
                          color: data.color.withValues(alpha: 0.15),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        data.category,
                        style: TextStyle(color: data.color, fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        data.time,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _dashboardMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              data.amount,
              style: TextStyle(
                color: data.isIncome ? const Color(0xFF059669) : _dashboardInk,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isPrimary,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? const Color(0xFF2563EB)
        : const Color(0xFF94A3B8);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPrimary)
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E3A8A),
                        Color(0xFF2563EB),
                        Color(0xFF0EA5E9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x242563EB),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: Colors.white, size: 23),
                )
              else
                SizedBox(
                  height: 28,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Icon(
                      isSelected ? _selectedNavIcon(icon) : icon,
                      key: ValueKey((icon.codePoint, isSelected)),
                      color: color,
                      size:
                          icon == Icons.home_outlined ||
                              icon == CupertinoIcons.doc_text
                          ? 26
                          : 23,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF2563EB) : _dashboardMuted,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _selectedNavIcon(IconData icon) {
    if (icon == Icons.home_outlined) return Icons.home_rounded;
    if (icon == CupertinoIcons.doc_text) return CupertinoIcons.doc_text_fill;
    if (icon == CupertinoIcons.qrcode) return CupertinoIcons.qrcode;
    if (icon == CupertinoIcons.chart_bar) return CupertinoIcons.chart_bar_fill;
    if (icon == CupertinoIcons.person) return CupertinoIcons.person_fill;
    return icon;
  }
}
