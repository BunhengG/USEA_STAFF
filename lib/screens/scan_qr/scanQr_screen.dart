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

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QR Code Check-In/Out'),
          backgroundColor: Colors.white,
        ),
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
    return Column(
      children: [
        Expanded(
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              overlayColor: Colors.transparent,
              borderColor: secondaryColor,
              borderRadius: 20,
              borderLength: 32,
              borderWidth: 6,
              cutOutSize: MediaQuery.of(context).size.width * 0.6,
            ),
          ),
        ),
        _buildFlashButton(),
      ],
    );
  }

  Widget _buildFlashButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: InkWell(
        onTap: _toggleFlash,
        child: Container(
          width: 150,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: _isFlashOn ? Colors.grey : Colors.grey[800],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isFlashOn
                    ? Icons.flashlight_on_rounded
                    : Icons.flashlight_off_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              const Text(
                'Flash',
                style: TextStyle(color: Colors.white, fontSize: 14),
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
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: secondaryColor, width: 6),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

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

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
