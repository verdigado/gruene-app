import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gruene_app/app/auth/bloc/auth_bloc.dart';
import 'package:gruene_app/app/constants/config.dart';
import 'package:gruene_app/app/constants/routes.dart';
import 'package:gruene_app/app/theme/theme.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_bloc.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_event.dart';
import 'package:gruene_app/features/mfa/bloc/mfa_state.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TokenScanScreen extends StatelessWidget {
  const TokenScanScreen({super.key});

  void onDetect(BarcodeCapture barcode, BuildContext context) async {
    String value = barcode.barcodes.firstOrNull?.displayValue ?? '';

    // prevent authenticator registration with arbitrary keycloak instances
    if (!value.startsWith(Config.oidcIssuer)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.mfa.tokenScan.oidcIssuerMissmatch),
        ),
      );
      return;
    }

    var bloc = context.read<MfaBloc>();
    if (bloc.state.isLoading) {
      return;
    }
    bloc.add(SetupMfa(value));

    if (!context.mounted) return;

    if (bloc.state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bloc.state.error.toString()),
        ),
      );
      return;
    }

    Future<void> waitForReadyStatus() async {
      while (bloc.state.status != MfaStatus.ready) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      if (context.mounted) {
        while (context.canPop()) {
          context.pop();
        }
        final bloc = context.read<AuthBloc>();
        if (bloc.state is Unauthenticated) {
          context.pushNamed(Routes.mfa.name!);
        }
      }
    }

    waitForReadyStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 119, 24, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.mfa.tokenScan.intro,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
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
            onPressed: () => context.push('${Routes.mfa.path}/${Routes.mfaTokenInput.path}'),
            child: Text(
              t.mfa.tokenScan.doManual,
              style: theme.textTheme.bodyMedium!.apply(color: ThemeColors.text, decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}
