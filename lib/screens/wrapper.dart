import 'package:flutter/material.dart';
import 'package:safeherven_app/models/app_user.dart';
import 'package:safeherven_app/screens/home.dart';
import 'package:safeherven_app/services/local_auth_service.dart';
import 'package:safeherven_app/shared/emblem.dart';
import 'package:safeherven_app/theme/app_colors.dart';

/// Porta de entrada direta e acolhedora do Vozes Livres.
/// Elimina telas de login e senhas para permitir acesso imediato e anônimo.
class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool _isEntering = false;

  Future<void> _enterApp({String? targetRoute}) async {
    if (_isEntering) return;
    setState(() => _isEntering = true);
    try {
      await LocalAuthService.instance.enterDirectly();
      if (mounted && targetRoute != null) {
        await Navigator.of(context).pushNamed(targetRoute);
      }
    } finally {
      if (mounted) {
        setState(() => _isEntering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      initialData: LocalAuthService.instance.currentUser,
      stream: LocalAuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen(user: snapshot.data!);
        }

        return Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surfaceCalmTint,
                  AppColors.canvasWarm,
                  AppColors.surfaceWarmTint,
                ],
                stops: [0.0, 0.42, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const VozesEmblem(size: 88),
                        const SizedBox(height: 22),
                        const Text(
                          'Vozes Livres',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                            color: AppColors.primarySafety,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Você está em um espaço seguro, calmo e acolhedor',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCalmTint,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.borderCalm),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                size: 18,
                                color: AppColors.primarySafety,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Sem login ou senha • 100% anônimo e offline',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primarySafety,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: Semantics(
                            button: true,
                            label: 'Entrar diretamente no Vozes Livres sem login',
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primarySafety,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: _isEntering ? null : () => _enterApp(),
                              icon: _isEntering
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.2,
                                      ),
                                    )
                                  : const Icon(Icons.arrow_forward_rounded),
                              label: const Text('Entrar Agora'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ou acesse diretamente:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _DirectShortcutButton(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Conversar com a Angel',
                          subtitle: 'Escuta sigilosa e orientação imediata',
                          backgroundColor: AppColors.surfaceElevated,
                          borderColor: AppColors.borderCalm,
                          iconBackground: AppColors.surfaceCalmTint,
                          iconColor: AppColors.secondaryCalm,
                          titleColor: AppColors.textPrimary,
                          subtitleColor: AppColors.textSecondary,
                          onTap: _isEntering
                              ? null
                              : () => _enterApp(targetRoute: '/chat'),
                        ),
                        const SizedBox(height: 10),
                        _DirectShortcutButton(
                          icon: Icons.shield_outlined,
                          title: 'Ajuda e Emergência (Ligue 100)',
                          subtitle: 'Canais de proteção e discagem direta',
                          backgroundColor: AppColors.surfaceHugTint,
                          borderColor: AppColors.warmthTerracotta.withValues(alpha: 0.35),
                          iconBackground: AppColors.warmthTerracotta.withValues(alpha: 0.14),
                          iconColor: AppColors.warmthTintText,
                          titleColor: AppColors.warmthTintText,
                          subtitleColor: AppColors.textSecondary,
                          onTap: _isEntering
                              ? null
                              : () => _enterApp(targetRoute: '/alert'),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Seus relatos permanecem somente no seu aparelho.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DirectShortcutButton extends StatelessWidget {
  const _DirectShortcutButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackground,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackground;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: iconBackground,
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}
