import 'package:flutter/material.dart';
import 'package:safeherven_app/theme/app_colors.dart';

/// Emblema acolhedor do Vozes Livres usando a silhueta branca da marca
/// sobre fundo azul-petróleo sereno com halo em verde sálvia suave.
class VozesEmblem extends StatelessWidget {
  const VozesEmblem({
    super.key,
    this.size = 96,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final double outerSize = size + 18;
    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceCalmTint,
        border: Border.all(color: AppColors.borderCalm, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.primarySafety, AppColors.primaryPetal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(size * 0.16),
        child: Image.asset(
          'assets/images/logos/white.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
