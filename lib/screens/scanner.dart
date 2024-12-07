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
      final String? code = barcode.rawValue;
      print('Scanned code: $code');

      if (code != null && !ref.read(qrScanProvider).isProcessing) {
        ref.read(qrScanProvider.notifier).scanQRCode(code);

        await cameraController.stop();
        await Future.delayed(Duration(seconds: 2));
        cameraController.start();
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(qrScanProvider);

    final fetchedPerson =
        scanState.persons.isNotEmpty ? scanState.persons.last : null;

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
          if (fetchedPerson != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Student Details:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              title: Text('Name: ${fetchedPerson.name}'),
              subtitle: Text(
                  'Student Number: ${fetchedPerson.studentNumber}\nEmail: ${fetchedPerson.email}\nBranch: ${fetchedPerson.branch}'),
            ),
          ],
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
