// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:ewallet_mobile/features/dashboard/dashboard_screen.dart';
import 'package:ewallet_mobile/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows phone OTP login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EWalletApp());

    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(find.text('Gửi mã OTP'), findsOneWidget);

    final context = tester.element(find.text('Chào mừng trở lại'));
    expect(MediaQuery.textScalerOf(context).scale(10), closeTo(10, 0.01));
    expect(Theme.of(context).textTheme.bodySmall?.fontSize, 12);
    expect(Theme.of(context).textTheme.bodySmall?.fontFamily, 'MomoTrustSans');
    expect(Theme.of(context).scaffoldBackgroundColor, const Color(0xFFF5F7FC));
    expect(Theme.of(context).colorScheme.primary, const Color(0xFF2563EB));
  });

  testWidgets('shows the finance overview dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    expect(find.text('Nguyễn Minh Khoa'), findsOneWidget);
    final systemUiRegion = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
    );
    expect(systemUiRegion.value.statusBarIconBrightness, Brightness.dark);
    final notificationButton = find.byTooltip('Thông báo');
    expect(
      tester
          .widget<Icon>(
            find.descendant(
              of: notificationButton,
              matching: find.byType(Icon),
            ),
          )
          .icon,
      CupertinoIcons.bell_fill,
    );
    expect(find.text('Số dư ví'), findsOneWidget);
    expect(find.text('24.580.000đ'), findsOneWidget);
    final balanceText = tester.widget<Text>(find.text('24.580.000đ'));
    expect(balanceText.style?.fontSize, 24);
    expect(find.text('+18.500.000đ'), findsNWidgets(2));
    expect(
      tester.widget<Text>(find.text('+18.500.000đ').first).style?.color,
      const Color(0xFF86EFAC),
    );
    expect(
      tester.widget<Text>(find.text('-7.240.000đ')).style?.color,
      const Color(0xFFFCA5A5),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('home-balance-card'))).height,
      lessThanOrEqualTo(165),
    );
    expect(find.text('Giao dịch gần đây'), findsOneWidget);
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Nạp tiền'), findsOneWidget);
    expect(find.text('Rút tiền'), findsOneWidget);
    expect(find.text('Chuyển tiền'), findsNWidgets(2));
    expect(find.text('Thanh toán'), findsOneWidget);
    final chatButton = find.byKey(const ValueKey('assistant-chat-drag-handle'));
    final startPosition = tester.getTopLeft(chatButton);
    final gesture = await tester.startGesture(
      startPosition + const Offset(12, 48),
    );
    await gesture.moveBy(const Offset(40, 30));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(chatButton), startPosition + const Offset(40, 30));
    await gesture.moveBy(const Offset(80, 50));
    await tester.pumpAndSettle();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(chatButton),
      startPosition + const Offset(120, 80),
    );
    await tester.tap(find.byTooltip('Ẩn số dư ví'));
    await tester.pumpAndSettle();

    expect(find.text('••••••••'), findsOneWidget);
    expect(find.text('24.580.000đ'), findsNothing);
  });

  testWidgets('opens AI chat and sends a suggested finance question', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    await tester.tap(find.byKey(const ValueKey('assistant-chat-button')));
    await tester.pumpAndSettle();

    expect(find.text('Trợ lý AI Tài chính'), findsOneWidget);
    expect(find.textContaining('Xin chào Khoa!'), findsOneWidget);
    expect(find.text('Chi tiêu tháng này thế nào?'), findsOneWidget);

    await tester.tap(find.text('Chi tiêu tháng này thế nào?'));
    await tester.pumpAndSettle();

    expect(find.text('Chi tiêu tháng này thế nào?'), findsOneWidget);
    expect(find.textContaining('thấp hơn 8% so với tháng 8'), findsOneWidget);

    await tester.tap(find.byTooltip('Đóng trò chuyện'));
    await tester.pumpAndSettle();
    expect(find.text('Giao dịch gần đây'), findsOneWidget);
  });

  testWidgets('navigates all finance tabs and their key sub-screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    final overviewTransactionStyle =
        (tester.widget<Text>(find.text('Grab Food')).style!).fontSize;
    expect(overviewTransactionStyle, 14);

    await tester.tap(find.text('Giao dịch').last);
    await tester.pumpAndSettle();
    expect(find.text('Lịch sử giao dịch'), findsOneWidget);
    expect(find.text('Chi tiêu'), findsNothing);
    expect(find.text('TỔNG THU'), findsNothing);
    expect(find.text('TỔNG CHI'), findsNothing);
    expect(find.text('SỐ DƯ'), findsNothing);
    expect(tester.widget<Text>(find.text('Tất cả')).style?.fontSize, 13);
    final categoryButton = find.ancestor(
      of: find.text('Tất cả'),
      matching: find.byType(Material),
    );
    expect(
      tester.getSize(categoryButton.first).height,
      greaterThanOrEqualTo(36),
    );
    final categoryBottom = tester.getBottomLeft(find.text('Tất cả')).dy;
    final firstTransactionTop = tester.getTopLeft(find.text('Grab Food')).dy;
    expect(firstTransactionTop - categoryBottom, greaterThanOrEqualTo(12));
    final historyTransactionStyle =
        (tester.widget<Text>(find.text('Grab Food')).style!).fontSize;
    expect(overviewTransactionStyle, historyTransactionStyle);

    await tester.tap(find.text('Ăn uống').first);
    await tester.pumpAndSettle();
    expect(find.text('Grab Food'), findsOneWidget);
    expect(find.text('Lương tháng 9'), findsNothing);

    await tester.tap(find.text('QR Pay').last);
    await tester.pumpAndSettle();
    expect(find.text('QR Thanh toán'), findsOneWidget);
    expect(
      find.text('Cho người khác quét mã này để\nchuyển tiền cho bạn'),
      findsOneWidget,
    );

    await tester.tap(find.text('Quét QR'));
    await tester.pumpAndSettle();
    expect(find.text('Quét mã QR'), findsNWidgets(2));
    expect(
      find.text('Căn chỉnh mã QR trong khung để tiếp tục.'),
      findsOneWidget,
    );
    expect(find.text('Chọn mã QR từ thư viện'), findsOneWidget);
    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();

    final receiptShortcut = find.text('Quét hóa đơn tự động');
    await tester.scrollUntilVisible(receiptShortcut, 240);
    await tester.pumpAndSettle();
    await tester.tap(receiptShortcut);
    await tester.pumpAndSettle();
    expect(find.text('Quét hóa đơn OCR'), findsOneWidget);
    expect(find.text('Tải ảnh hóa đơn'), findsOneWidget);
    await tester.tap(find.text('Chọn ảnh hóa đơn'));
    await tester.pumpAndSettle();
    expect(
      find.text('Tính năng chọn ảnh hóa đơn sẽ sớm khả dụng.'),
      findsOneWidget,
    );
    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();
    expect(find.text('QR Thanh toán'), findsOneWidget);

    await tester.tap(find.text('Ngân sách').last);
    await tester.pumpAndSettle();
    expect(find.text('Tài chính & Ngân sách'), findsOneWidget);
    expect(find.text('Danh mục chi tiêu'), findsOneWidget);

    await tester.tap(find.text('AI').first);
    await tester.pumpAndSettle();
    expect(find.text('TRỢ LÝ AI TÀI CHÍNH'), findsOneWidget);
    expect(find.text('Phân bổ chi tiêu'), findsOneWidget);

    await tester.tap(find.text('Nhóm'));
    await tester.pumpAndSettle();
    expect(find.text('Nhóm chia tiền (3 đang hoạt động)'), findsOneWidget);

    await tester.tap(find.text('Tài khoản').last);
    await tester.pumpAndSettle();
    expect(find.text('Bảo mật & Xác thực'), findsOneWidget);
    expect(find.text('4.820'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.lock_fill), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.bell_fill), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.person_fill), findsNWidgets(2));
    expect(find.byIcon(CupertinoIcons.creditcard_fill), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.doc_text_fill), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.chat_bubble_fill), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('assistant-chat-button')),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Bảo mật & Xác thực'));
    await tester.pumpAndSettle();
    expect(find.text('Mã PIN giao dịch'), findsOneWidget);
  });
}
