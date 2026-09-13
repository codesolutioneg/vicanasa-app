import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'waiting_clock_overlay.dart';

class SendingEmailOverlay extends StatelessWidget {
  const SendingEmailOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return WaitingClockOverlay(
      title: l10n.sendingEmailTitle,
      subtitle: l10n.sendingEmailSubtitle,
    );
  }
}
