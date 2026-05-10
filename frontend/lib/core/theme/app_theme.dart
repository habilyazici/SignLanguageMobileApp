import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Marka Ana Renkleri ─────────────────────────────────────────────────────
  static const Color primaryBlue      = Color(0xFF0046AF);
  static const Color primaryBlueEnd   = Color(0xFF005CE1);
  static const Color secondaryBlue    = Color(0xFF2563EB);
  static const Color primaryBlueDark = Color(0xFF1D4ED8);
  static const Color primaryBlueTint = Color(0xFFDBEAFE);

  // ── Arka Plan & Yüzey ─────────────────────────────────────────────────────
  static const Color softGrey    = Color(0xFFF7FAFC); // Ana uygulama arkaplanı
  static const Color bgSecondary = Color(0xFFF3F4F6); // İkincil yüzey / input
  static const Color borderColor = Color(0xFFE5E7EB); // Kenarlık / bölücü

  // ── Metin Renkleri ─────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);
  static const Color midGrey     = Color(0xFF4B5563);
  static const Color textMuted   = Color(0xFF9CA3AF);
  static const Color textSubtle  = Color(0xFF64748B);

  // ── Durum Renkleri (recognition pipeline'da kullanılır) ───────────────────
  static const Color primaryStatusGreen  = Color(0xFF14B8A6); // Yüksek güven
  static const Color primaryStatusYellow = Color(0xFFF59E0B); // Orta güven
  static const Color primaryStatusRed    = Color(0xFFDC2626); // Düşük güven / hata
  static const Color statusPurple        = Color(0xFF8B5CF6);

  // ── Koyu Tema ─────────────────────────────────────────────────────────────
  static const Color darkBg      = Color(0xFF181C1E);
  static const Color darkSurface = Color(0xFF424654);
  static const Color gradientDeep = Color(0xFF0046AF);

  // ── Gradyanlar ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryBlueEnd],
  );

  static const LinearGradient cameraOverlay = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0x99000000), Color(0x00000000)],
  );

  // ── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: softGrey,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: secondaryBlue,
        surface: Colors.white,
        error: primaryStatusRed,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge:  GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary),
        displayMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary),
        titleLarge:    GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
        bodyLarge:     GoogleFonts.poppins(fontSize: 16, color: textPrimary),
        bodyMedium:    GoogleFonts.poppins(fontSize: 14, color: midGrey),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      dividerTheme: const DividerThemeData(color: borderColor, thickness: 1),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor),
        ),
      ),
    );
  }

  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: secondaryBlue,
        secondary: secondaryBlue,
        surface: darkSurface,
        error: primaryStatusRed,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ).copyWith(
        displayLarge:  GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
        displayMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
        titleLarge:    GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
        bodyLarge:     GoogleFonts.poppins(fontSize: 16, color: Colors.white),
        bodyMedium:    GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF2D3748), thickness: 1),
    );
  }
}
