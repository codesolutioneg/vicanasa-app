import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Glass settings aligned with [liquid_glass_widgets] showcase — tuned for Vicanza teal UI.
abstract final class RecommendedGlassSettings {
  RecommendedGlassSettings._();

  static const bottomBar = LiquidGlassSettings(
    blur: 24,
    thickness: 24,
    glassColor: Color.fromRGBO(255, 255, 255, 0.55),
    lightAngle: 0.75 * math.pi,
    lightIntensity: 0.8,
    ambientStrength: 0.45,
    saturation: 1.15,
    refractiveIndex: 1.25,
    chromaticAberration: 0.0,
  );

  static const surface = LiquidGlassSettings(
    blur: 10,
    thickness: 10,
    glassColor: Color.fromRGBO(255, 255, 255, 0.2),
    lightAngle: 0.75 * math.pi,
    lightIntensity: 0.7,
    ambientStrength: 0.3,
    saturation: 1.2,
    refractiveIndex: 1.15,
    chromaticAberration: 0.0,
  );
}
