import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:usea_staff_test/constant/constant.dart';
import '../../provider/check_in_out_provider.dart';

class CheckInOutQRScreen extends StatefulWidget {
  const CheckInOutQRScreen({super.key});

  @override
  State<CheckInOutQRScreen> createState() => _CheckInOutQRScreenState();
}

class _CheckInOutQRScreenState extends State<CheckInOutQRScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isFlashOn = false;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestLocationPermission();
  }

  Future<void> _checkAndRequestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Location permission is permanently denied. Enable it in settings.'),
          action: SnackBarAction(
            label: 'Open Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
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
      body: Consumer<CheckInOutProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              _buildQRScanner(),
              _buildCustomBorders(cutOutSize),
              if (provider.isLoading)
                const Center(
                    child: CircularProgressIndicator(
                  color: secondaryColor,
                )),
            ],
          );
        },
      ),
    );
  }

  // ===========================
  // NOTE: UI COMPONENTS
  // ===========================

  Widget _buildQRScanner() {
    return Column(
      children: [
        Expanded(
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              overlayColor: Colors.transparent,
              borderColor: Colors.transparent,
              borderRadius: roundedCornerSM,
              borderLength: 32,
              borderWidth: 6,
              cutOutSize: MediaQuery.of(context).size.width * 0.7,
            ),
            onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
          ),
        ),
        _buildFlashButton(),
      ],
    );
  }

  Widget _buildFlashButton() {
    return Container(
      color: Colors.transparent,
      margin: const EdgeInsets.only(bottom: mdMargin),
      padding: const EdgeInsets.only(
        bottom: defaultPadding * 1.6,
        top: mdPadding,
      ),
      child: InkWell(
        onTap: _toggleFlash,
        child: Container(
          width: 120,
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: defaultPadding - 2,
          ),
          decoration: BoxDecoration(
            color: _isFlashOn ? primaryColor : Colors.blue[300],
            borderRadius: BorderRadius.circular(roundedCornerSM),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isFlashOn
                    ? Icons.flashlight_on_rounded
                    : Icons.flashlight_off_rounded,
                color: secondaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                'Flash',
                style: getWhiteSubTitle(),
              ),
            ],
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
            const BorderRadius.only(topLeft: Radius.circular(roundedCornerLG));
        alignment = Alignment.topLeft;
        break;
      case 1:
        borderRadius =
            const BorderRadius.only(topRight: Radius.circular(roundedCornerLG));
        alignment = Alignment.topRight;
        break;
      case 2:
        borderRadius = const BorderRadius.only(
            bottomLeft: Radius.circular(roundedCornerLG));
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
      if (scanData.code != null && !isProcessing) {
        isProcessing = true;

        final provider =
            Provider.of<CheckInOutProvider>(context, listen: false);

        await provider.checkInOut(scanData.code!);

        if (provider.errorMessage != null) {
          _showSnackbar(provider.errorMessage!);
        } else {
          _showSnackbar('Check-In/Out successful!');

          // Ensure navigation happens after the current frame
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted && Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            });
          }
        }
        isProcessing = false;
      }
    });
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
