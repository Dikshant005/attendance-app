import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:attendance_app/providers/qr.dart';

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
        await Future.delayed(Duration(seconds: 2));
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
    final qrData =
        scanState.errorMessage != null ? null : scanState.lastScannedData;

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner'),
        actions: [
          IconButton(
            icon: Icon(Icons.flash_on),
            onPressed: () {
              cameraController.toggleTorch();
            },
          ),
          IconButton(
            icon: Icon(Icons.cameraswitch),
            onPressed: () {
              cameraController.switchCamera();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (scanState.isProcessing) LinearProgressIndicator(),
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
            duration: Duration(milliseconds: 300),
            height: qrData != null ? 150 : 0,
            curve: Curves.easeInOut,
            child: qrData != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Student Details:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        ListTile(
                          title: Text('Name: ${qrData['Name']}'),
                          subtitle: Text(
                            'Student Number: ${qrData['Student No']}\n'
                            'Email: ${qrData['Email']}',
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
                  style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}
