# eWallet Mobile

Flutter app dang nhap bang Firebase Phone OTP, to chuc theo Feature-First va Riverpod toi gian.

## Cau truc

```text
lib/
├── core/theme/app_theme.dart
├── features/auth/
│   ├── auth_screen.dart
│   ├── auth_provider.dart
│   └── auth_service.dart
├── features/nfc/
│   ├── nfc_cccd_screen.dart
│   ├── nfc_cccd_reader.dart
│   ├── nfc_decoder_api.dart
│   └── nfc_decoder_request.dart
└── main.dart
```

## Quet NFC CCCD (Android)

Man hinh dang nhap co nut **Quet CCCD bang NFC**. Nguoi dung nhap so dinh danh
12 so, ngay sinh va ngay het han (khong chup anh); ung dung dung 9 so cuoi cua
so dinh danh lam document number de mo chip, doc DG1/DG2/SOD, ma hoa cac file
thanh HEX va gui `POST /api/v1/ekyc/nfc`. `sessionId` la UUID moi cho moi lan
gui; `livenessData` duoc gui la `null`.

Endpoint mac dinh cho Android Emulator:

```text
http://10.0.2.2:8012/api/v1/ekyc/nfc
```

De doi endpoint, truyen URL day du khi chay app. Android that can dung IP LAN
cua may chay backend; khong dung `localhost` tren dien thoai:

```bash
flutter run --dart-define=NFC_API_URL=http://192.168.1.10:8012/api/v1/ekyc/nfc
```

Backend HTTP khong ma hoa chi nen dung trong moi truong phat trien tin cay;
cleartext chi duoc bat trong Android debug/profile, release can dung HTTPS.
Thiet bi can NFC va chip CCCD phai duoc ho tro; doc chip that can duoc kiem
thu tren thiet bi Android co NFC.

Phu thuoc `flutter_cccd_vn` duoc cap phep LGPL-3.0 hoac commercial license.
Kiem tra dieu khoan va nghia vu phan phoi cua thu vien truoc khi phat hanh app:
[giay phep thu vien](https://github.com/datit309/nfc_cccd_vn).

## Ket noi backend

App goi thang tung service theo port rieng (API gateway chua ap route cho moi
service). Dia chi duoc quan ly o `lib/core/config/api_config.dart`.

| Service | Port | Ghi chu |
| --- | --- | --- |
| api-gateway | 8000 | chua dung |
| auth-service | 8001 | dang nhap qua `POST /api/v1/auth/phone` |
| user-service | 8002 | |
| payment-gateway | 8004 | |
| ocr-service | 8006 | |
| notification-service | 8007 | |
| chatbot-service | 8008 | |
| file-service | 8009 | |
| ekyc-service | 8012 | quet NFC CCCD |

Host mac dinh: Android Emulator `http://10.0.2.2`, iOS Simulator/desktop/web
`http://localhost`. May that cung mang LAN voi may chay Docker:

```bash
flutter run --dart-define=API_HOST=http://192.168.1.10
```

Doi rieng mot service bang URL day du: `AUTH_BASE_URL`, `USER_BASE_URL`,
`PAYMENT_BASE_URL`, `OCR_BASE_URL`, `NOTIFICATION_BASE_URL`,
`CHATBOT_BASE_URL`, `FILE_BASE_URL`, `EKYC_BASE_URL`, `GATEWAY_BASE_URL`, vi du:

```bash
flutter run --dart-define=AUTH_BASE_URL=http://192.168.1.10:8001
```

Sau khi Firebase xac thuc OTP, app goi auth-service de lay access/refresh token
(luu trong bo nho, chua luu ben vung). Neu auth-service chua chay, man hinh
dang nhap bao loi va co nut **Thu ket noi lai** (khong can nhap lai OTP).

## Cau hinh Firebase

1. Tao Firebase project va bat **Authentication > Sign-in method > Phone**.
2. Cai FlutterFire CLI neu may chua co:

   ```bash
   dart pub global activate flutterfire_cli
   ```

3. Tu thu muc project, chay:

   ```bash
   flutterfire configure
   ```

   Chon Android/iOS (va Web neu can). Lenh nay tao `lib/firebase_options.dart` cung file cau hinh native.
4. Trong Firebase Console, them SHA-1/SHA-256 cho Android khi chay ban debug hoac release.
5. Chay app:

   ```bash
   flutter run
   ```

Firebase Phone Auth can thiet bi/emulator co kha nang nhan SMS. Co the dung **Authentication > Sign-in method > Phone numbers for testing** de phat trien ma khong gui SMS that.

## Kiem tra

```bash
flutter analyze
flutter test
```
