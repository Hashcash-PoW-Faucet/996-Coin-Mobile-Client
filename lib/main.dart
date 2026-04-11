// =========================
// lib/main.dart
// =========================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NnsWalletApp());
}

class NnsWalletApp extends StatelessWidget {
  const NnsWalletApp({super.key});

  Widget build(BuildContext context) {
    const slmBgTop = Color(0xFF2A5479);
    const slmBgBottom = Color(0xFF2A5479);
    const slmCardBg = Color(0xDB081928);
    const slmCardShadow = Color(0xA6000000);
    const slmOverlayGlow = Color(0xFF2F557D);
    const slmBorder = Color(0x14FFFFFF);
    const slmTextMain = Color(0xFFF5F7FA);
    const slmTextMuted = Color(0xFFCFD8DC);
    const slmAccent = Color(0xFFF4D247);
    const slmAccentSoft = Color(0xFFFFE58A);
    const slmDanger = Color(0xFFFF8A80);
    const slmInputBg = Color(0xE60A2134);

    final colorScheme = ColorScheme.dark(
      primary: slmAccent,
      secondary: slmAccentSoft,
      surface: slmCardBg,
      error: slmDanger,
      onPrimary: const Color(0x255479),
      onSecondary: const Color(0xb9dbcb),
      onSurface: slmTextMain,
      onError: Colors.black,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: MaterialApp(
        title: '996-Coin Wallet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: Colors.transparent,
          fontFamily: 'system-ui',
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: slmTextMain),
            bodyMedium: TextStyle(color: slmTextMain),
            bodySmall: TextStyle(color: slmTextMuted),
            titleLarge: TextStyle(
              color: slmTextMain,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
            titleMedium: TextStyle(
              color: slmTextMain,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            titleSmall: TextStyle(
              color: slmTextMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: slmTextMain,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: slmTextMain,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          cardTheme: CardThemeData(
            color: slmCardBg,
            elevation: 0,
            shadowColor: slmCardShadow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: slmBorder),
            ),
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: slmCardBg,
            contentTextStyle: const TextStyle(color: slmTextMain),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: slmBorder),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: slmInputBg,
            labelStyle: const TextStyle(color: slmTextMuted),
            hintStyle: const TextStyle(color: slmTextMuted),
            prefixIconColor: slmTextMuted,
            suffixIconColor: slmTextMuted,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0x29FFFFFF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0x29FFFFFF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: slmAccent),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: slmDanger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: slmDanger),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: slmAccent,
              foregroundColor: const Color(0xFF2B2B2B),
              disabledBackgroundColor: const Color(0x66F4D247),
              disabledForegroundColor: const Color(0xAA2B2B2B),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: slmAccentSoft,
              side: const BorderSide(color: Color(0x29FFFFFF)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: slmAccentSoft,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          dividerColor: slmBorder,
          dialogTheme: DialogThemeData(
            backgroundColor: slmCardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: slmBorder),
            ),
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: slmCardBg,
            modalBackgroundColor: slmCardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
        ),
        builder: (context, child) {
          return DecoratedBox(
            decoration: const BoxDecoration(
              color: slmBgTop,
            ),
            child: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 32),
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          );
        },
        home: const HomeScreen(),
      ),
    );
  }
}