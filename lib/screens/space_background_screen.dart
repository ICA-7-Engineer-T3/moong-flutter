import 'package:flutter/material.dart';
import '../widgets/background_preview_screen.dart';
import '../models/background_config.dart';

class SpaceBackgroundScreen extends StatelessWidget {
  const SpaceBackgroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundPreviewScreen(config: BackgroundConfig.space);
  }
}
