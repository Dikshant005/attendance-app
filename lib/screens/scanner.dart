import 'package:attendance_app/providers/qr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanner extends ConsumerStatefulWidget {
  QRScanner({Key? key}) : super(key: key);

  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends ConsumerState<QRScanner> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isScanning = false;
  bool isDialogShown = false;

  void _onDetect(BarcodeCapture barcodeCapture, BuildContext context,
      WidgetRef ref) async {
    if (isScanning && !isDialogShown) {
      for (final barcode in barcodeCapture.barcodes) {
        final code = barcode.rawValue;
        print('Scanned code: $code');

        if (code != null && !ref.read(qrScanProvider).isProcessing) {
          final qrData = _parseQRCodeData(code);

          if (qrData != null && qrData['Student No'] != null) {
            setState(() {
              isDialogShown = true;
            });

            await _showQRDialog(context, qrData['Student No']!);

            ref.read(qrScanProvider.notifier).scanQRCode(qrData['Student No']!);

            setState(() {
              isScanning = false;
              isDialogShown = false;
            });

            await cameraController.stop();
            break;
          }
        }
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

  Future<void> _showQRDialog(BuildContext context, String studentNumber) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('QR Code Scanned'),
        content: Text('Student No: $studentNumber'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isScanning = false;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            height: 400,
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 159, 155, 155),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 3,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: MobileScanner(
                controller: cameraController,
                onDetect: (barcodeCapture) =>
                    _onDetect(barcodeCapture, context, ref),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: studentDetails != null ? 100 : 0,
            width: studentDetails != null ? 300 : 0,
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 189, 232, 115),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
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
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Container(),
          ),
          SizedBox(
            height: 40,
          ),
          if (scanState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${scanState.errorMessage}',
                  style: const TextStyle(color: Colors.red)),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                if (!isScanning) {
                  setState(() {
                    isScanning = true;
                  });

                  await cameraController.start();
                }
              },
              child: const Text('Start Scan'),
            ),
          ),
        ],
      ),
    );
  }
}
