import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const _blue = Color(0xFF2563EB);
const _navy = Color(0xFF1E3A8A);
const _sky = Color(0xFF0EA5E9);
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _pale = Color(0xFFF5F7FC);

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({required this.index, required this.onLogout, super.key});

  final int index;
  final VoidCallback onLogout;

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final _searchController = TextEditingController();
  final _questionController = TextEditingController();

  String _transactionCategory = 'Tất cả';
  int _qrMode = 0;
  int _budgetMode = 0;
  bool _scanningBill = false;
  String? _accountDetail;
  String? _selectedGroup;

  @override
  void dispose() {
    _searchController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.index) {
      case 1:
        return _transactionsScreen();
      case 2:
        return _qrScreen();
      case 3:
        return _budgetScreen();
      case 4:
        return _accountScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _transactionsScreen() {
    final visibleTransactions = _transactions.where((transaction) {
      final categoryMatches =
          _transactionCategory == 'Tất cả' ||
          transaction.category == _transactionCategory;
      final query = _searchController.text.trim().toLowerCase();
      final searchMatches =
          query.isEmpty ||
          transaction.name.toLowerCase().contains(query) ||
          transaction.category.toLowerCase().contains(query);
      return categoryMatches && searchMatches;
    }).toList();

    return _page(
      children: [
        _gradientHeader(
          title: 'Lịch sử giao dịch',
          bottom: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm giao dịch...',
                  hintStyle: const TextStyle(color: Color(0xCCFFFFFF)),
                  prefixIcon: const Icon(
                    CupertinoIcons.search,
                    color: Colors.white,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0x2EFFFFFF),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0x40FFFFFF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0x40FFFFFF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _Pill(
                label: category,
                selected: _transactionCategory == category,
                large: true,
                onTap: () => setState(() => _transactionCategory = category),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: _cardDecoration,
            clipBehavior: Clip.antiAlias,
            child: visibleTransactions.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('Không tìm thấy giao dịch')),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < visibleTransactions.length; i++) ...[
                        _TransactionTile(transaction: visibleTransactions[i]),
                        if (i < visibleTransactions.length - 1)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                          ),
                      ],
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _qrScreen() {
    if (_scanningBill) {
      return _page(
        children: [
          _simpleHeader(
            title: 'Quét hóa đơn OCR',
            onBack: () => setState(() => _scanningBill = false),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () =>
                        _message('Tính năng chọn ảnh hóa đơn sẽ sớm khả dụng.'),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFBFDBFE),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x122563EB),
                            blurRadius: 12,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              CupertinoIcons.doc_text_viewfinder,
                              color: _blue,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Tải ảnh hóa đơn',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Chụp ảnh hoặc chọn từ thư viện để nhận diện thông tin giao dịch.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _muted,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 22),
                          OutlinedButton.icon(
                            onPressed: () => _message(
                              'Tính năng chọn ảnh hóa đơn sẽ sớm khả dụng.',
                            ),
                            icon: const Icon(CupertinoIcons.photo),
                            label: const Text('Chọn ảnh hóa đơn'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(CupertinoIcons.sparkles, color: _blue, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Tự động trích xuất',
                            style: TextStyle(
                              color: _blue,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Số tiền • Đơn vị bán hàng • Ngày giao dịch',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_qrMode == 1) {
      return _qrScanner();
    }

    return _page(
      children: [
        _gradientHeader(
          title: 'QR Thanh toán',
          subtitle: 'Cho / nhận tiền qua mã QR',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              _segmentedControl(
                labels: const ['Mã của tôi', 'Quét QR'],
                selected: _qrMode,
                onSelected: (value) => setState(() => _qrMode = value),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16, bottom: 16),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE0E7FF)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x142563EB),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFFFFFBEB),
                          child: Text(
                            'K',
                            style: TextStyle(
                              color: _navy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nguyễn Minh Khoa',
                              style: TextStyle(
                                color: _ink,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '0901.234.567',
                              style: TextStyle(color: _muted, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const _QrPattern(size: 208),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'MÃ QR CÁ NHÂN',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Cho người khác quét mã này để\nchuyển tiền cho bạn',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _ink, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _message('Chia sẻ mã QR của bạn.'),
                            icon: const Icon(CupertinoIcons.share, size: 18),
                            label: const Text('Chia sẻ'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _message('Đã lưu mã QR vào thiết bị.'),
                            icon: const Icon(
                              CupertinoIcons.arrow_down_to_line,
                              size: 18,
                            ),
                            label: const Text('Tải xuống'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _ActionRow(
                initials: 'AI',
                title: 'Quét hóa đơn tự động',
                subtitle: 'AI trích xuất thông tin từ ảnh hóa đơn',
                color: const Color(0xFF059669),
                background: const Color(0xFFECFDF5),
                onTap: () => setState(() => _scanningBill = true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _qrScanner() {
    return _page(
      children: [
        _simpleHeader(
          title: 'Quét mã QR',
          onBack: () => setState(() => _qrMode = 0),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 320,
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.viewfinder,
                      color: Color(0xFF64748B),
                      size: 100,
                    ),
                    const _ScannerFrame(size: 224),
                    Positioned(
                      top: 22,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x33000000),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Đặt mã QR vào khung',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 22,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.viewfinder,
                            color: Colors.white70,
                            size: 17,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Quét mã để thanh toán',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Quét mã QR',
                style: TextStyle(
                  color: _ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Căn chỉnh mã QR trong khung để tiếp tục.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () =>
                    _message('Tính năng quét QR bằng camera sẽ sớm khả dụng.'),
                icon: const Icon(CupertinoIcons.photo),
                label: const Text('Chọn mã QR từ thư viện'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _budgetScreen() {
    return _page(
      children: [
        _gradientHeader(
          title: 'Tài chính & Ngân sách',
          bottom: _segmentedControl(
            labels: const ['Ngân sách', 'AI', 'Nhóm'],
            selected: _budgetMode,
            onSelected: (value) => setState(() {
              _budgetMode = value;
              _selectedGroup = null;
            }),
            inverse: true,
          ),
        ),
        const SizedBox(height: 14),
        if (_budgetMode == 0) _budgetOverview(),
        if (_budgetMode == 1) _budgetInsights(),
        if (_budgetMode == 2) _groupSharing(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _budgetOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration,
            child: Row(
              children: [
                SizedBox(
                  width: 92,
                  height: 92,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: 0.72,
                          strokeWidth: 9,
                          backgroundColor: Color(0xFFE2E8F0),
                          color: _blue,
                        ),
                      ),
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '72%',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'đã dùng',
                            style: TextStyle(color: _muted, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TỔNG CHI THÁNG NÀY',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '6.680.000đ',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Giới hạn: 9.300.000đ',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thu chi 6 tháng',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    _LegendDot(color: _blue, label: 'Thu'),
                    SizedBox(width: 16),
                    _LegendDot(color: Color(0xFF38BDF8), label: 'Chi'),
                  ],
                ),
                const SizedBox(height: 12),
                const _MonthlyBarChart(),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration,
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Danh mục chi tiêu',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _showAddCategoryDialog,
                      child: const Text('+ Thêm'),
                    ),
                  ],
                ),
                for (final category in _budgetCategories)
                  _BudgetCategoryRow(category: category),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _budgetInsights() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_navy, _blue, _sky]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0x30FFFFFF),
                      child: Text(
                        'AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TRỢ LÝ AI TÀI CHÍNH',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Phân tích thông minh',
                          style: TextStyle(
                            color: Color(0xCCFFFFFF),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Tháng 9 bạn đang chi tiêu tốt hơn 8% so với tháng 8. Dự kiến tiết kiệm được 11.260.000đ cuối tháng.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _InsightMetric(
                        amount: '62%',
                        label: 'Tỷ lệ tiết kiệm',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _InsightMetric(
                        amount: '4.2tr',
                        label: 'Dự báo chi thêm',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _spendingAllocation(),
          const SizedBox(height: 14),
          const _AdviceCard(
            initials: 'AI',
            title: 'Cắt giảm ăn uống',
            badge: 'Gợi ý',
            message:
                'Bạn đang chi 71% ngân sách ăn uống — đặt trước bữa trưa có thể tiết kiệm ~500k/tháng.',
            color: Color(0xFF2563EB),
            background: Color(0xFFEFF6FF),
          ),
          const SizedBox(height: 10),
          const _AdviceCard(
            initials: 'DB',
            title: 'Dự báo cuối tháng',
            badge: 'Cảnh báo',
            message:
                'Với tốc độ hiện tại, bạn sẽ vượt ngân sách mua sắm vào ngày 18/09.',
            color: Color(0xFFD97706),
            background: Color(0xFFFFFBEB),
          ),
          const SizedBox(height: 10),
          const _AdviceCard(
            initials: 'MT',
            title: 'Mục tiêu tiết kiệm',
            badge: 'Mục tiêu',
            message:
                'Tiết kiệm thêm 2.5tr/tháng để đạt quỹ dự phòng 50tr trong 14 tháng.',
            color: Color(0xFF059669),
            background: Color(0xFFECFDF5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _questionController,
                  decoration: const InputDecoration(
                    hintText: 'Hỏi AI về tài chính của bạn...',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendQuestion(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _sendQuestion,
                tooltip: 'Gửi câu hỏi',
                icon: const Icon(CupertinoIcons.paperplane_fill),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _spendingAllocation() {
    const entries = [
      ('Ăn uống', '43%', Color(0xFFDB2777)),
      ('Mua sắm', '29%', Color(0xFFD97706)),
      ('Di chuyển', '7%', Color(0xFF2563EB)),
      ('Giải trí', '6%', Color(0xFF7C3AED)),
      ('Hóa đơn', '13%', Color(0xFF0891B2)),
      ('Sức khỏe', '2%', Color(0xFF059669)),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phân bổ chi tiêu',
            style: TextStyle(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 112,
                height: 112,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: 0.74,
                        strokeWidth: 12,
                        backgroundColor: Color(0xFFE2E8F0),
                        color: _blue,
                      ),
                    ),
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '7.2tr',
                          style: TextStyle(
                            color: _ink,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'tổng chi',
                          style: TextStyle(color: _muted, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    for (final entry in entries)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: entry.$3,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                entry.$1,
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Text(
                              entry.$2,
                              style: const TextStyle(
                                color: _ink,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _groupSharing() {
    if (_selectedGroup != null) {
      return _groupDetail(_selectedGroup!);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhóm chia tiền (3 đang hoạt động)',
            style: TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (final group in _groups) ...[
            _GroupCard(
              group: group,
              onTap: () => setState(() => _selectedGroup = group.name),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          const Text(
            'ĐÃ HOÀN TẤT',
            style: TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 10),
          const _CompletedGroupCard(),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showCreateGroupDialog,
              icon: const Icon(CupertinoIcons.add),
              label: const Text('+ Tạo nhóm mới'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupDetail(String name) {
    final group = _groups.firstWhere((item) => item.name == name);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => setState(() => _selectedGroup = null),
            icon: const Icon(CupertinoIcons.back),
            label: const Text('Quay lại danh sách'),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  group.amount,
                  style: const TextStyle(
                    color: _blue,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${group.members} thành viên · ${group.unpaid} chưa trả',
                  style: const TextStyle(color: _muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Thành viên',
            style: TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          for (final name in ['Nguyễn Minh Khoa', 'Linh', 'Anh', 'Tuấn'])
            _ActionRow(
              initials: name == 'Nguyễn Minh Khoa' ? 'K' : name[0],
              title: name,
              subtitle: name == 'Nguyễn Minh Khoa'
                  ? 'Bạn · Đã thanh toán'
                  : 'Cần thanh toán phần của mình',
              color: name == 'Nguyễn Minh Khoa'
                  ? const Color(0xFF059669)
                  : _blue,
              background: name == 'Nguyễn Minh Khoa'
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFEFF6FF),
              trailing: name == 'Nguyễn Minh Khoa'
                  ? const Icon(
                      CupertinoIcons.check_mark_circled_solid,
                      color: Color(0xFF059669),
                    )
                  : const Text(
                      'Nhắc',
                      style: TextStyle(
                        color: _blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
              onTap: () => _message('Đã gửi lời nhắc thanh toán.'),
            ),
        ],
      ),
    );
  }

  Widget _accountScreen() {
    if (_accountDetail != null) {
      return _accountDetailScreen(_accountDetail!);
    }

    return _page(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.viewPaddingOf(context).top + 22,
            16,
            0,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_navy, _blue, _sky]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFFF59E0B),
                      child: Text(
                        'K',
                        style: TextStyle(
                          color: _navy,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nguyễn Minh Khoa',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            '0901.234.567',
                            style: TextStyle(
                              color: Color(0xCCFFFFFF),
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 8),
                          _Tag(
                            label: 'KYC Lv.2',
                            color: Color(0xFFFFFBEB),
                            textColor: Color(0xFFD97706),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Row(
                  children: [
                    Expanded(
                      child: _ProfileStat(value: '247', label: 'Giao dịch'),
                    ),
                    Expanded(
                      child: _ProfileStat(value: '4.820', label: 'Điểm thưởng'),
                    ),
                    Expanded(
                      child: _ProfileStat(value: 'Gold', label: 'Thành viên'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            decoration: _cardDecoration,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < _accountActions.length; i++) ...[
                  _ActionRow(
                    initials: _accountActions[i].initials,
                    icon: _accountActions[i].icon,
                    title: _accountActions[i].title,
                    subtitle: _accountActions[i].subtitle,
                    color: _accountActions[i].color,
                    background: _accountActions[i].background,
                    onTap: () => _openAccountDetail(_accountActions[i].title),
                  ),
                  if (i < _accountActions.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _confirmLogout,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: BorderSide.none,
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _accountDetailScreen(String title) {
    final items = switch (title) {
      'Bảo mật & Xác thực' => const [
        ('PIN', 'Mã PIN giao dịch', 'Đặt mã 6 số'),
        ('SH', 'Vân tay / Face ID', 'Xác thực sinh trắc học'),
        ('TB', 'Xác thực 2 lớp (2FA)', 'OTP qua SMS/Email'),
        ('VT', 'Phát hiện đăng nhập lạ', 'Cảnh báo địa điểm mới'),
      ],
      'Thông báo' => const [
        ('GD', 'Giao dịch', 'Thông báo biến động số dư'),
        ('NH', 'Cảnh báo ngân sách', 'Nhắc khi gần hết ngân sách'),
        ('KM', 'Ưu đãi', 'Tin tức và chương trình'),
      ],
      'Xác minh danh tính (KYC)' => const [
        ('KYC', 'Trạng thái xác minh', 'Đã xác minh Level 2'),
        ('CC', 'Thông tin cá nhân', 'Nguyễn Minh Khoa'),
      ],
      'Liên kết ngân hàng' => const [
        ('VCB', 'Vietcombank', '•••• 4567 · Tài khoản thanh toán'),
        ('MB', 'MB Bank', '•••• 0981 · Tài khoản thanh toán'),
      ],
      'Điều khoản & Chính sách' => const [
        ('DK', 'Điều khoản sử dụng', 'Cập nhật 01/09/2024'),
        ('CS', 'Chính sách quyền riêng tư', 'Cập nhật 01/09/2024'),
      ],
      _ => const [
        ('HT', 'Trung tâm trợ giúp', 'Câu hỏi thường gặp'),
        ('☎', 'Liên hệ tư vấn viên', 'Hỗ trợ khách hàng'),
      ],
    };

    return _page(
      children: [
        _simpleHeader(
          title: title,
          onBack: () => setState(() => _accountDetail = null),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: _cardDecoration,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _ActionRow(
                    initials: items[i].$1,
                    title: items[i].$2,
                    subtitle: items[i].$3,
                    color: _blue,
                    background: const Color(0xFFEFF6FF),
                    onTap: () => _message('${items[i].$2}: ${items[i].$3}'),
                  ),
                  if (i < items.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _page({required List<Widget> children}) {
    return ColoredBox(
      color: _pale,
      child: ListView(padding: EdgeInsets.zero, children: children),
    );
  }

  Widget _gradientHeader({
    required String title,
    String? subtitle,
    Widget? bottom,
  }) {
    final topInset = MediaQuery.viewPaddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topInset + 24, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navy, _blue, _sky],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xBFFFFFFF), fontSize: 13),
            ),
          ],
          if (bottom != null) ...[const SizedBox(height: 14), bottom],
        ],
      ),
    );
  }

  Widget _simpleHeader({required String title, required VoidCallback onBack}) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        MediaQuery.viewPaddingOf(context).top + 12,
        16,
        12,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [_navy, _blue, _sky]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: 'Quay lại',
            icon: const Icon(CupertinoIcons.back, color: Colors.white),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segmentedControl({
    required List<String> labels,
    required int selected,
    required ValueChanged<int> onSelected,
    bool inverse = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: inverse ? const Color(0x30FFFFFF) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Material(
                color: selected == i
                    ? inverse
                          ? Colors.white
                          : _blue
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => onSelected(i),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 10,
                    ),
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected == i
                            ? inverse
                                  ? _blue
                                  : Colors.white
                            : inverse
                            ? const Color(0xDDFFFFFF)
                            : _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openAccountDetail(String title) {
    setState(() => _accountDetail = title);
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _sendQuestion() {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      _message('Hãy nhập câu hỏi của bạn.');
      return;
    }
    _questionController.clear();
    _message('Trợ lý AI đang phân tích câu hỏi của bạn.');
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm danh mục'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tên danh mục'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _message(
                controller.text.trim().isEmpty
                    ? 'Tên danh mục không được để trống.'
                    : 'Đã thêm danh mục ${controller.text.trim()}.',
              );
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  void _showCreateGroupDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo nhóm chia tiền'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tên nhóm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _message(
                controller.text.trim().isEmpty
                    ? 'Tên nhóm không được để trống.'
                    : 'Đã tạo nhóm ${controller.text.trim()}.',
              );
            },
            child: const Text('Tạo nhóm'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi eWallet?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ở lại'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: const Color(0xFFE8EDF5)),
    boxShadow: const [
      BoxShadow(color: Color(0x0C101828), blurRadius: 16, offset: Offset(0, 4)),
    ],
  );
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.large = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool large;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _blue : Colors.white,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? _blue : const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: large ? 14 : 12,
              vertical: large ? 8 : 7,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : _muted,
                fontSize: large ? 13 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final _Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: transaction.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              transaction.initials,
              style: TextStyle(
                color: transaction.color,
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
                  transaction.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Tag(
                      label: transaction.category,
                      color: transaction.background,
                      textColor: transaction.color,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        transaction.time,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _muted, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            transaction.amount,
            style: TextStyle(
              color: transaction.isIncome ? transaction.color : _ink,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Transaction {
  const _Transaction({
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

const _categories = [
  'Tất cả',
  'Ăn uống',
  'Mua sắm',
  'Hóa đơn',
  'Giải trí',
  'Di chuyển',
  'Chuyển tiền',
  'Thu nhập',
];
const _transactions = [
  _Transaction(
    initials: 'AU',
    name: 'Grab Food',
    category: 'Ăn uống',
    time: 'Hôm nay, 10:30',
    amount: '-85.000đ',
    color: Color(0xFFDB2777),
    background: Color(0xFFFDF2F8),
  ),
  _Transaction(
    initials: 'TN',
    name: 'Lương tháng 9',
    category: 'Thu nhập',
    time: 'Hôm nay, 09:00',
    amount: '+18.500.000đ',
    color: Color(0xFF059669),
    background: Color(0xFFECFDF5),
    isIncome: true,
  ),
  _Transaction(
    initials: 'MS',
    name: 'Shopee',
    category: 'Mua sắm',
    time: 'Hôm qua, 15:20',
    amount: '-320.000đ',
    color: Color(0xFFD97706),
    background: Color(0xFFFFFBEB),
  ),
  _Transaction(
    initials: 'CK',
    name: 'Chuyển cho Bảo Linh',
    category: 'Chuyển tiền',
    time: 'Hôm qua, 12:00',
    amount: '-500.000đ',
    color: Color(0xFF2563EB),
    background: Color(0xFFEFF6FF),
  ),
  _Transaction(
    initials: 'HD',
    name: 'Điện nước tháng 9',
    category: 'Hóa đơn',
    time: '06/09, 08:15',
    amount: '-450.000đ',
    color: Color(0xFF7C3AED),
    background: Color(0xFFF5F3FF),
  ),
  _Transaction(
    initials: 'CK',
    name: 'Nhận từ Tuấn Anh',
    category: 'Chuyển tiền',
    time: '05/09, 20:30',
    amount: '+200.000đ',
    color: Color(0xFF059669),
    background: Color(0xFFECFDF5),
    isIncome: true,
  ),
  _Transaction(
    initials: 'AU',
    name: 'Circle K',
    category: 'Ăn uống',
    time: '05/09, 14:10',
    amount: '-45.000đ',
    color: Color(0xFFDB2777),
    background: Color(0xFFFDF2F8),
  ),
  _Transaction(
    initials: 'GT',
    name: 'Netflix',
    category: 'Giải trí',
    time: '04/09, 00:00',
    amount: '-99.000đ',
    color: Color(0xFF7C3AED),
    background: Color(0xFFF5F3FF),
  ),
  _Transaction(
    initials: 'DC',
    name: 'Grab Bike',
    category: 'Di chuyển',
    time: '03/09, 18:45',
    amount: '-25.000đ',
    color: Color(0xFF2563EB),
    background: Color(0xFFEFF6FF),
  ),
  _Transaction(
    initials: 'GT',
    name: 'Tiền thưởng Q3',
    category: 'Thu nhập',
    time: '01/09, 10:00',
    amount: '+5.000.000đ',
    color: Color(0xFF059669),
    background: Color(0xFFECFDF5),
    isIncome: true,
  ),
];

class _QrPattern extends StatelessWidget {
  const _QrPattern({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _QrPatternPainter()),
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ScannerFramePainter()),
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cornerLength = 30.0;
    const radius = 16.0;
    final paint = Paint()
      ..color = const Color(0xFFBAE6FD)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final corners = [
      (Offset.zero, 1.0, 1.0),
      (Offset(size.width, 0), -1.0, 1.0),
      (Offset(0, size.height), 1.0, -1.0),
      (Offset(size.width, size.height), -1.0, -1.0),
    ];

    for (final (origin, xDirection, yDirection) in corners) {
      final path = Path()
        ..moveTo(origin.dx, origin.dy + yDirection * (cornerLength - radius))
        ..quadraticBezierTo(
          origin.dx,
          origin.dy,
          origin.dx + xDirection * radius,
          origin.dy,
        )
        ..lineTo(origin.dx + xDirection * cornerLength, origin.dy);
      canvas.drawPath(path, paint);
      final vertical = Path()
        ..moveTo(origin.dx + xDirection * (cornerLength - radius), origin.dy)
        ..quadraticBezierTo(
          origin.dx,
          origin.dy,
          origin.dx,
          origin.dy + yDirection * radius,
        )
        ..lineTo(origin.dx, origin.dy + yDirection * cornerLength);
      canvas.drawPath(vertical, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScannerFramePainter oldDelegate) => false;
}

class _QrPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const count = 29;
    final cell = size.width / count;
    final paint = Paint()..color = _ink;

    bool finderCell(int x, int y) {
      for (final point in const [(0, 0), (0, 22), (22, 0)]) {
        final dx = x - point.$1;
        final dy = y - point.$2;
        if (dx >= 0 && dx < 7 && dy >= 0 && dy < 7) {
          return dx == 0 ||
              dx == 6 ||
              dy == 0 ||
              dy == 6 ||
              (dx >= 2 && dx <= 4 && dy >= 2 && dy <= 4);
        }
      }
      return false;
    }

    for (var y = 0; y < count; y++) {
      for (var x = 0; x < count; x++) {
        final finderArea =
            (x < 8 && y < 8) || (x < 8 && y >= 21) || (x >= 21 && y < 8);
        final filled = finderArea
            ? finderCell(x, y)
            : ((x * 17 + y * 13 + x * y) % 7 < 3);
        if (filled) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell * 0.88, cell * 0.88),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const _simpleCard = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(18)),
);

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
      ],
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  const _MonthlyBarChart();

  @override
  Widget build(BuildContext context) {
    const income = [0.65, 0.8, 0.58, 0.72, 0.52, 0.9];
    const expense = [0.37, 0.48, 0.3, 0.55, 0.4, 0.58];
    const months = ['T4', 'T5', 'T6', 'T7', 'T8', 'T9'];

    return SizedBox(
      height: 136,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < months.length; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ChartBar(value: income[i], color: _blue),
                        const SizedBox(width: 4),
                        _ChartBar(
                          value: expense[i],
                          color: const Color(0xFF38BDF8),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    months[i],
                    style: const TextStyle(color: _muted, fontSize: 10),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: value,
      child: Container(
        width: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ),
    );
  }
}

class _BudgetCategory {
  const _BudgetCategory({
    required this.initials,
    required this.title,
    required this.amount,
    required this.limit,
    required this.ratio,
    required this.color,
    required this.background,
  });

  final String initials;
  final String title;
  final String amount;
  final String limit;
  final double ratio;
  final Color color;
  final Color background;
}

const _budgetCategories = [
  _BudgetCategory(
    initials: 'AU',
    title: 'Ăn uống',
    amount: '2.850.000đ',
    limit: '/ 4.0tr',
    ratio: 0.71,
    color: Color(0xFFDB2777),
    background: Color(0xFFFDF2F8),
  ),
  _BudgetCategory(
    initials: 'MS',
    title: 'Mua sắm',
    amount: '1.920.000đ',
    limit: '/ 2.0tr',
    ratio: 0.96,
    color: Color(0xFFD97706),
    background: Color(0xFFFFFBEB),
  ),
  _BudgetCategory(
    initials: 'DC',
    title: 'Di chuyển',
    amount: '480.000đ',
    limit: '/ 1.0tr',
    ratio: 0.48,
    color: Color(0xFF2563EB),
    background: Color(0xFFEFF6FF),
  ),
  _BudgetCategory(
    initials: 'GT',
    title: 'Giải trí',
    amount: '380.000đ',
    limit: '/ 0.5tr',
    ratio: 0.76,
    color: Color(0xFF7C3AED),
    background: Color(0xFFF5F3FF),
  ),
  _BudgetCategory(
    initials: 'HD',
    title: 'Hóa đơn',
    amount: '900.000đ',
    limit: '/ 1.0tr',
    ratio: 0.9,
    color: Color(0xFF0891B2),
    background: Color(0xFFECFEFF),
  ),
  _BudgetCategory(
    initials: 'SK',
    title: 'Sức khỏe',
    amount: '150.000đ',
    limit: '/ 0.8tr',
    ratio: 0.19,
    color: Color(0xFF059669),
    background: Color(0xFFECFDF5),
  ),
];

class _BudgetCategoryRow extends StatelessWidget {
  const _BudgetCategoryRow({required this.category});

  final _BudgetCategory category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: category.background,
            child: Text(
              category.initials,
              style: TextStyle(
                color: category.color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.title,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      category.amount,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      ' ${category.limit}',
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: category.ratio,
                    minHeight: 6,
                    color: category.color,
                    backgroundColor: category.background,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              '${(category.ratio * 100).round()}%',
              textAlign: TextAlign.end,
              style: const TextStyle(color: _muted, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightMetric extends StatelessWidget {
  const _InsightMetric({required this.amount, required this.label});

  final String amount;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x24FFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard({
    required this.initials,
    required this.title,
    required this.badge,
    required this.message,
    required this.color,
    required this.background,
  });

  final String initials;
  final String title;
  final String badge;
  final String message;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: _simpleCard.copyWith(
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: background,
            child: Text(
              initials,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _Tag(label: badge, color: background, textColor: color),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Group {
  const _Group({
    required this.initials,
    required this.name,
    required this.members,
    required this.amount,
    required this.unpaid,
    required this.avatars,
  });

  final String initials;
  final String name;
  final int members;
  final String amount;
  final int unpaid;
  final List<String> avatars;
}

const _groups = [
  _Group(
    initials: 'DL',
    name: 'Du lịch Đà Lạt',
    members: 4,
    amount: '5.000.000đ',
    unpaid: 3,
    avatars: ['K', 'L', 'A', 'G'],
  ),
  _Group(
    initials: 'SN',
    name: 'Tiệc sinh nhật Linh',
    members: 6,
    amount: '2.800.000đ',
    unpaid: 4,
    avatars: ['K', 'N', 'P', 'T', '+2'],
  ),
  _Group(
    initials: 'OG',
    name: 'Ở ghép tháng 9',
    members: 3,
    amount: '12.000.000đ',
    unpaid: 1,
    avatars: ['K', 'L', 'T'],
  ),
];

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group, required this.onTap});

  final _Group group;
  final VoidCallback onTap;

  static const _avatarColors = [
    Color(0xFF3C8CDD),
    Color(0xFF8C3CDD),
    Color(0xFFDD3C8C),
    Color(0xFFDD8C3C),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  group.initials,
                  style: const TextStyle(
                    color: _blue,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        for (var i = 0; i < group.avatars.length; i++)
                          Align(
                            widthFactor: 0.8,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor:
                                  _avatarColors[i % _avatarColors.length],
                              child: Text(
                                group.avatars[i],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 6),
                        Text(
                          '${group.members} thành viên',
                          style: const TextStyle(color: _muted, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${group.amount} · ${group.unpaid} chưa trả',
                      style: const TextStyle(
                        color: Color(0xFFD97706),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(CupertinoIcons.chevron_right, color: _muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletedGroupCard extends StatelessWidget {
  const _CompletedGroupCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _simpleCard,
      child: const Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFECFDF5),
            child: Text(
              'TL',
              style: TextStyle(
                color: Color(0xFF059669),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Team lunch công ty',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '1.450.000đ · 5 người',
                  style: TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            'Đã xong',
            style: TextStyle(
              color: Color(0xFF059669),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 10),
        ),
      ],
    );
  }
}

class _AccountAction {
  const _AccountAction({
    required this.initials,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.background,
  });

  final String initials;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color background;
}

const _accountActions = [
  _AccountAction(
    initials: 'BM',
    icon: CupertinoIcons.lock_fill,
    title: 'Bảo mật & Xác thực',
    subtitle: 'PIN, sinh trắc học, 2FA',
    color: Color(0xFF2563EB),
    background: Color(0xFFEFF6FF),
  ),
  _AccountAction(
    initials: 'TB',
    icon: CupertinoIcons.bell_fill,
    title: 'Thông báo',
    subtitle: 'Giao dịch, cảnh báo',
    color: Color(0xFFD97706),
    background: Color(0xFFFFF4D6),
  ),
  _AccountAction(
    initials: 'KYC',
    icon: CupertinoIcons.person_fill,
    title: 'Xác minh danh tính (KYC)',
    subtitle: 'Đã xác minh Level 2',
    color: Color(0xFF059669),
    background: Color(0xFFECFDF5),
  ),
  _AccountAction(
    initials: 'NH',
    icon: CupertinoIcons.creditcard_fill,
    title: 'Liên kết ngân hàng',
    subtitle: '2 tài khoản đã liên kết',
    color: Color(0xFF7C3AED),
    background: Color(0xFFF5F3FF),
  ),
  _AccountAction(
    initials: 'DK',
    icon: CupertinoIcons.doc_text_fill,
    title: 'Điều khoản & Chính sách',
    subtitle: 'Cập nhật 01/09/2024',
    color: Color(0xFF0891B2),
    background: Color(0xFFECFEFF),
  ),
  _AccountAction(
    initials: 'HT',
    icon: CupertinoIcons.chat_bubble_fill,
    title: 'Hỗ trợ',
    subtitle: 'Chat với tư vấn viên',
    color: Color(0xFFDB2777),
    background: Color(0xFFFDF2F8),
  ),
];

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.initials,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.background,
    required this.onTap,
    this.icon,
    this.trailing,
  });

  final String initials;
  final IconData? icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color background;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: icon == null
                    ? Text(
                        initials,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    CupertinoIcons.chevron_right,
                    color: _muted,
                    size: 18,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
