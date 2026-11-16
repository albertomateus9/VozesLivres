import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta de cores do Vozes Livres em tom rosa suave e neutros suaves,
/// mantendo os princípios psicofisiológicos de acolhimento, baixa saturação
/// e redução de alerta visual.
///
/// Referências científicas:
/// - Valdez & Mehrabian (1994), *J. Exp. Psychol. Gen.* (PMID 7996122):
///   alta luminosidade combinada a baixa saturação eleva o conforto/prazer
///   mantendo baixa a ativação fisiológica.
/// - Wilms & Oberfeld (2018), *Psychol. Res.* (PMID 28612080):
///   reduzir saturação/croma atenua a resposta eletrodérmica simpática
///   em comparação a vermelhos intensos e saturados.
/// - LeGates et al. (2014), *Nat. Rev. Neurosci.* (PMID 24917305):
///   superfícies suaves e quentes evitam desconforto luminoso de fundos frios.
abstract class AppColors {
  AppColors._();

  // Neutros suaves e fundos rosados delicados (calor humano sem fadiga visual)
  static const Color canvasWarm = Color(0xFFFBF8F7);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceWarmTint = Color(0xFFF4ECEB);
  static const Color surfaceCalmTint = Color(0xFFF8EAEF);
  static const Color surfaceHugTint = Color(0xFFFBF0EE);
  static const Color borderSoft = Color(0xFFE6DCDA);
  static const Color borderCalm = Color(0xFFE4C8D0);

  // Rosa suave principal (rosa antigo dessaturado: acolhedor, seguro e legível)
  static const Color primarySafety = Color(0xFF944D60);
  static const Color primaryDeep = Color(0xFF7D3E4F);
  static const Color primaryPetal = Color(0xFFB47384);
  static const Color onPrimaryMuted = Color(0xFFF5E4E8);

  // Malva neutro suave (equilíbrio e apoio emocional)
  static const Color secondaryCalm = Color(0xFF7A5966);
  static const Color secondaryDeep = Color(0xFF634652);
  static const Color onSecondaryMuted = Color(0xFFF1E5E9);

  // Acolhimento cálido (rosa-terroso suave)
  static const Color warmthTerracotta = Color(0xFFA76063);
  static const Color warmthText = Color(0xFF874145);
  static const Color warmthTintText = Color(0xFF874145);

  // Neutro quente acinzentado (ancoragem para mapa e leitura)
  static const Color mapSlateTeal = Color(0xFF615356);
  static const Color mapSlateDeep = Color(0xFF4D4144);
  static const Color onMapSlateMuted = Color(0xFFEAE2E3);

  // Proteção e Emergência (rosa-carmim contido: destaque sem pânico visual)
  static const Color protectiveAlert = Color(0xFFAE4E52);
  static const Color protectiveAlertDeep = Color(0xFF933D41);
  static const Color protectiveAlertTint = Color(0xFFFBF0F0);
  static const Color onAlertMuted = Color(0xFFFDEAEA);

  // Tipografia em neutros escuros suaves (contraste WCAG AA/AAA >= 5.9:1)
  static const Color textPrimary = Color(0xFF2D2326);
  static const Color textSecondary = Color(0xFF5E5154);
  static const Color textMuted = Color(0xFF6B5D60);

  static ThemeData buildTheme(BuildContext context) {
    final baseTheme = Theme.of(context);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySafety,
        primary: primarySafety,
        onPrimary: Colors.white,
        secondary: secondaryCalm,
        onSecondary: Colors.white,
        tertiary: warmthTerracotta,
        onTertiary: Colors.white,
        error: protectiveAlert,
        onError: Colors.white,
        surface: surfaceElevated,
        onSurface: textPrimary,
        outline: borderSoft,
      ),
      scaffoldBackgroundColor: canvasWarm,
      textTheme: GoogleFonts.jostTextTheme(baseTheme.textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primarySafety,
        foregroundColor: Colors.white,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSoft),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderSoft,
        thickness: 1,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: primaryDeep,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
