import 'package:flutter/material.dart';
import '../widgets/background_preview_screen.dart';
import '../models/background_config.dart';

class BeachBackgroundScreen extends StatelessWidget {
  const BeachBackgroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundPreviewScreen(config: BackgroundConfig.beach);
  }
}
