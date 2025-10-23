import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../core/database/database_helper.dart';
import '../../core/models/data_models.dart';
import '../../core/models/educational_tip.dart';
import '../../core/services/tax_calculation_service.dart';
import '../../core/services/profile_service.dart';
import '../educational/educational_tip_widgets.dart';
import 'receipt_review_screen.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  final TextRecognizer _textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _controller = CameraController(
          _cameras[0],
          ResolutionPreset.medium,
        );
        await _controller!.initialize();
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      // Handle camera initialization error silently
      // The UI will show loading indicator if camera fails to initialize
    }
  }

  Future<void> _captureAndProcessReceipt() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Take picture
      final XFile image = await _controller!.takePicture();
      
      // Process image with ML Kit
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Extract amount and vendor from text
      final double amount = _extractAmountFromText(recognizedText.text);
      final String? vendorName = _extractVendorFromText(recognizedText.text);
      
      // Save image to app directory
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = '${const Uuid().v4()}.jpg';
      final String savedPath = '${directory.path}/$fileName';
      await File(image.path).copy(savedPath);

      // Close the initial loading dialog before entering the review flow
      if (mounted) Navigator.pop(context);

      final reviewResult = await Navigator.push<ReceiptReviewResult?>(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptReviewScreen(
            initialAmount: amount,
            initialVendorName: vendorName,
            imagePath: savedPath,
          ),
        ),
      );

      if (reviewResult == null) {
        await File(savedPath).delete().catchError((_) {});
        return;
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Calculate tax saving based on user profile, if available
      final profileService = ProfileService();
      final userProfile = await profileService.getProfile();

      final double taxSaving;
      if (userProfile != null) {
        taxSaving = TaxCalculationService.calculateSavingWithProfile(
          reviewResult.amount,
          userProfile.incomeBracket,
          userProfile.filingStatus,
        );
      } else {
        taxSaving = TaxCalculationService.calculatePotentialSaving(reviewResult.amount);
      }

      // Create receipt object
      final receipt = Receipt(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        imagePath: savedPath,
        vendorName: reviewResult.vendorName,
        totalAmount: reviewResult.amount,
        potentialTaxSaving: taxSaving,
        category: reviewResult.category,
      );

      // Save to database
      await DatabaseHelper.instance.insertReceipt(receipt);

      // Close persistence progress dialog
      if (mounted) Navigator.pop(context);

      // Show reward screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RewardScreen(
              amount: reviewResult.amount,
              taxSaving: taxSaving,
              vendorName: reviewResult.vendorName,
              category: reviewResult.category,
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing receipt: $e')),
        );
      }
    }
  }

  double _extractAmountFromText(String text) {
    // Simple regex to find dollar amounts
    final RegExp amountRegex = RegExp(r'\$?([0-9]+\.?[0-9]*)');
    final matches = amountRegex.allMatches(text);
    
    // For demo purposes, return the largest amount found
    double maxAmount = 0.0;
    for (final match in matches) {
      final amountStr = match.group(1);
      if (amountStr != null) {
        final amount = double.tryParse(amountStr) ?? 0.0;
        if (amount > maxAmount) {
          maxAmount = amount;
        }
      }
    }
    
    return maxAmount > 0 ? maxAmount : 25.99; // Default demo amount
  }

  String? _extractVendorFromText(String text) {
    final lines = text.split('\n');
    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      if (line.length < 3) continue;
      final hasLetters = RegExp(r'[A-Za-z]').hasMatch(line);
      if (!hasLetters) continue;
      final containsAmountKeyword =
          RegExp(r'(total|subtotal|amount|change)', caseSensitive: false).hasMatch(line);
      if (containsAmountKeyword) continue;
      // Skip lines that look like amounts
      if (RegExp(r'[0-9]').hasMatch(line) && RegExp(r'\$|[0-9]+\.[0-9]{2}').hasMatch(line)) {
        continue;
      }
      return line.length > 40 ? line.substring(0, 40) : line;
    }
    return null;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isInitialized
          ? Column(
              children: [
                Expanded(
                  child: CameraPreview(_controller!),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _captureAndProcessReceipt,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Capture Receipt'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class RewardScreen extends StatelessWidget {
  final double amount;
  final double taxSaving;
  final String? vendorName;
  final String? category;

  const RewardScreen({
    super.key,
    required this.amount,
    required this.taxSaving,
    this.vendorName,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final randomTip = EducationalTips.getRandomTip();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Saved!'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            
            // Success icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 32),
            
            // Success message
            const Text(
              'Nice!',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Tax savings highlight
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'You\'ve unlocked',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${taxSaving.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'in potential tax savings!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            if (vendorName != null && vendorName!.isNotEmpty) ...[
              Text(
                vendorName!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (category != null && category!.isNotEmpty) ...[
              Text(
                'Category: ${formatCategoryLabel(category!)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
            ],
            // Receipt amount
            Text(
              'Receipt amount: \$${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Estimate Only - Not Tax Advice',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            
            // Educational tip
            EducationalTipCard(tip: randomTip),
            const SizedBox(height: 32),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReceiptScannerScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scan Another'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Done'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
