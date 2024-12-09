import 'package:attendance_app/providers/qr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanner extends ConsumerWidget {
  final MobileScannerController cameraController = MobileScannerController();

  QRScanner({Key? key}) : super(key: key);

  void _onDetect(BarcodeCapture barcodeCapture, BuildContext context,
      WidgetRef ref) async {
    for (final barcode in barcodeCapture.barcodes) {
      final code = barcode.rawValue;
      print('Scanned code: $code');

      if (code != null && !ref.read(qrScanProvider).isProcessing) {
        final qrData = _parseQRCodeData(code);

        if (qrData != null && qrData['Student No'] != null) {
          ref.read(qrScanProvider.notifier).scanQRCode(qrData['Student No']!);
        }

        await cameraController.stop();
        await Future.delayed(const Duration(seconds: 2));
        cameraController.start();
        break;
      }
    }
  }

  Map<String, String>? _parseQRCodeData(String code) {
    try {
      final dataLines = code.split('\n');
      final data = <String, String>{};
      for (var line in dataLines) {
        final keyValue = line.split(':');
        if (keyValue.length == 2) {
          data[keyValue[0].trim()] = keyValue[1].trim();
        }
      }
      return data.isNotEmpty ? data : null;
    } catch (e) {
      print('Error parsing QR code: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(qrScanProvider);
    final studentDetails = scanState.lastScannedData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              cameraController.toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () {
              cameraController.switchCamera();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (scanState.isProcessing) const LinearProgressIndicator(),
          Container(
            height: 300,
            width: double.infinity,
            child: MobileScanner(
              controller: cameraController,
              onDetect: (barcodeCapture) =>
                  _onDetect(barcodeCapture, context, ref),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: studentDetails != null ? 150 : 0,
            curve: Curves.easeInOut,
            child: studentDetails != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          studentDetails['message'] ?? 'No message available',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ),
          if (scanState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${scanState.errorMessage}',
                  style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}
