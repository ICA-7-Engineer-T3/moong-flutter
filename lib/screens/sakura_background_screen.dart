import 'package:flutter/material.dart';
import '../widgets/background_preview_screen.dart';
import '../models/background_config.dart';

class SakuraBackgroundScreen extends StatelessWidget {
  const SakuraBackgroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundPreviewScreen(config: BackgroundConfig.sakura);
  }
}
