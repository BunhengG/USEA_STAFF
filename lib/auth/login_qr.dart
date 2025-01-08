import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:usea_staff_test/constant/constant.dart';
import '../api/fetch_user.dart';
import '../helper/shared_pref_helper.dart';
import '../screens/home_screen.dart';

class LoginQRScreen extends StatefulWidget {
  const LoginQRScreen({super.key});

  @override
  State<LoginQRScreen> createState() => _LoginQRScreenState();
}

class _LoginQRScreenState extends State<LoginQRScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  bool _isFlashOn = false;
  bool _isProcessing = false;
  bool _isLoading = false;

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final double cutOutSize = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SCAN QR',
          style: getWhiteSubTitle(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: IconButton(
            icon: Image.asset(
              'assets/icon/custom_icon.png',
              scale: 12,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildQRScanner(),
          _buildCustomBorders(cutOutSize),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: secondaryColor),
            ),
        ],
      ),
    );
  }

  // ===========================
  // NOTE: UI COMPONENTS
  // ===========================

  // Widget _buildQRScanner() {
  //   return Column(
  //     children: [
  //       Expanded(
  //         child: QRView(
  //           key: qrKey,
  //           onQRViewCreated: _onQRViewCreated,
  //           overlay: QrScannerOverlayShape(
  //             overlayColor: Colors.black54,
  //             borderColor: Colors.transparent,
  //             borderRadius: roundedCornerSM,
  //             borderLength: 32,
  //             borderWidth: 6,
  //             cutOutSize: MediaQuery.of(context).size.width * 0.7,
  //           ),
  //           onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
  //         ),
  //       ),
  //       _buildFlashButton(),
  //     ],
  //   );
  // }

  Widget _buildQRScanner() {
    return Stack(
      children: [
        Positioned.fill(
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              overlayColor: Colors.black54,
              borderColor: Colors.transparent,
              borderRadius: roundedCornerLG,
              borderLength: 32,
              borderWidth: 8,
              cutOutBottomOffset: 75,
              cutOutSize: MediaQuery.of(context).size.width * 0.7,
            ),
            onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.2,
          left: 0,
          right: 0,
          child: _buildFlashButton(),
        ),
      ],
    );
  }

  Widget _buildFlashButton() {
    return Center(
      child: InkWell(
        onTap: _toggleFlash,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _isFlashOn ? secondaryColor : Colors.white38,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            _isFlashOn
                ? Icons.flashlight_on_rounded
                : Icons.flashlight_off_rounded,
            color: _isFlashOn ? primaryColor : secondaryColor,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBorders(double cutOutSize) {
    return Positioned(
      top: (MediaQuery.of(context).size.height - cutOutSize) / 3,
      left: (MediaQuery.of(context).size.width - cutOutSize) / 2,
      child: SizedBox(
        width: cutOutSize,
        height: cutOutSize,
        child: Stack(
          children: List.generate(4, (index) => _buildCornerBorder(index)),
        ),
      ),
    );
  }

  Widget _buildCornerBorder(int index) {
    const borderSide = BorderSide(width: 4, color: secondaryColor);
    BorderRadius borderRadius;
    Alignment alignment;

    switch (index) {
      case 0:
        borderRadius =
            const BorderRadius.only(topLeft: Radius.circular(roundedCornerMD));
        alignment = Alignment.topLeft;
        break;
      case 1:
        borderRadius =
            const BorderRadius.only(topRight: Radius.circular(roundedCornerMD));
        alignment = Alignment.topRight;
        break;
      case 2:
        borderRadius = const BorderRadius.only(
            bottomLeft: Radius.circular(roundedCornerMD));
        alignment = Alignment.bottomLeft;
        break;
      case 3:
      default:
        borderRadius = const BorderRadius.only(
            bottomRight: Radius.circular(roundedCornerLG));
        alignment = Alignment.bottomRight;
        break;
    }

    return Positioned(
      top: alignment.y < 0 ? 0 : null,
      bottom: alignment.y > 0 ? 0 : null,
      left: alignment.x < 0 ? 0 : null,
      right: alignment.x > 0 ? 0 : null,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          border: Border(
            top: alignment.y < 0 ? borderSide : BorderSide.none,
            bottom: alignment.y > 0 ? borderSide : BorderSide.none,
            left: alignment.x < 0 ? borderSide : BorderSide.none,
            right: alignment.x > 0 ? borderSide : BorderSide.none,
          ),
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  // ===========================
  // NOTE: QR LOGIC
  // ===========================

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      // if (_isProcessing) return;
      if (_isProcessing || _isLoading) return;

      if (scanData.code != null) {
        if (mounted) {
          setState(() {
            result = scanData;
            _isProcessing = true;
            _isLoading = true;
          });
          await _loginWithQRCode();
        }
      }
    });
  }

  Future<void> _loginWithQRCode() async {
    if (result?.code == null) return;

    final data = result!.code!.split(':');
    if (data.length != 2) {
      _showSnackbar('Invalid QR code format');
      if (mounted) {
        setState(() => _isProcessing = false);
      }
      return;
    }

    final userId = data[0];
    final password = data[1];

    try {
      setState(() => _isLoading = true);

      final userDataResponse = await loginUser(userId, password);
      if (userDataResponse != null) {
        await SharedPrefHelper.saveUserIdAndPassword(userId, password);
        await Future.delayed(const Duration(seconds: 2));
        _navigateToHomePage();
      } else {
        _showSnackbar('Invalid userId or password.');
      }
    } catch (e) {
      _showSnackbar('An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        setState(() => _isProcessing = false);
      }
    }
  }

  void _navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  // ===========================
  // NOTE: UTILITIES
  // ===========================

  Future<void> _toggleFlash() async {
    if (controller != null) {
      final isFlashOn = await controller!.getFlashStatus();
      setState(() => _isFlashOn = !(isFlashOn ?? false));
      await controller!.toggleFlash();
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      _showSnackbar('Camera permission is required for scanning.');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
