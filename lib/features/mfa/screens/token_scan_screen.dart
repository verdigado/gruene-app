import 'package:flutter/material.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/app/utils/utils.dart';
import 'package:gruene_app/app/widgets/app_bar.dart';
import 'package:gruene_app/features/mfa/util/setup_mfa.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TokenScanScreen extends StatelessWidget {
  const TokenScanScreen({super.key});

  void onDetect(BarcodeCapture barcode, BuildContext context) async {
    String actionTokenUrl = barcode.barcodes.firstOrNull?.displayValue ?? '';
    setupMfa(context, actionTokenUrl);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: MainAppBar(title: t.mfa.tokenScan.title),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 119, 24, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.mfa.tokenScan.intro, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
            const SizedBox(height: 73),
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colorScheme.primary, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: MobileScanner(
                    fit: BoxFit.cover,
                    controller: MobileScannerController(
                      detectionSpeed: DetectionSpeed.normal,
                      detectionTimeoutMs: 4000,
                      formats: const [BarcodeFormat.qrCode],
                      autoStart: true,
                      facing: CameraFacing.back,
                      torchEnabled: false,
                    ),
                    onDetect: (barcode) => onDetect(barcode, context),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Spacer(),
            TextButton(
              onPressed: () => context.pushNested(Routes.mfaTokenInput.path),
              child: Text(
                t.mfa.tokenScan.doManual,
                style: theme.textTheme.bodyMedium!.apply(color: ThemeColors.text, decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
