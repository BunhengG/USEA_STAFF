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
  bool _hasScanned = false;

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
            'Location permission is permanently denied. Enable it in settings.',
          ),
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

    return SafeArea(
      child: Scaffold(
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
      ),
    );
  }

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

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null && !_hasScanned && !isProcessing) {
        _hasScanned = true;
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
            Future.delayed(const Duration(milliseconds: 100), () {
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
