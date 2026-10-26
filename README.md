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
