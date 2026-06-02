import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Glass settings aligned with [liquid_glass_widgets] showcase — tuned for Vicanza teal UI.
abstract final class RecommendedGlassSettings {
  RecommendedGlassSettings._();

  static const bottomBar = LiquidGlassSettings(
    blur: 20,
    thickness: 20,
    glassColor: Color.fromRGBO(255, 255, 255, 0.18),
    lightAngle: 0.75 * math.pi,
    lightIntensity: 0.7,
    ambientStrength: 0.5,
    saturation: 1.2,
    refractiveIndex: 1.2,
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
