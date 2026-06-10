import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zonix/features/utils/app_colors.dart';

class NetworkImageWithFallback extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? title;
  final IconData? fallbackIcon;
  final Color? fallbackColor;

  const NetworkImageWithFallback({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.title,
    this.fallbackIcon,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheW = width.isFinite ? (width * dpr).toInt() : null;

    final Widget imageWidget = imageUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: imageUrl,
            width: width,
            height: height,
            fit: fit,
            memCacheWidth: cacheW,
            placeholder: (_, __) => _buildLoadingPlaceholder(),
            errorWidget: (_, __, ___) => _buildErrorPlaceholder(),
          )
        : _buildErrorPlaceholder();

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brandSurfaceLight,
            AppColors.brandMutedGray,
          ],
        ),
      ),
      child: Center(
        child: height <= 80
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.statusInfo),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cargando...',
                    style: TextStyle(
                      color: AppColors.stitchSlate,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    final color = fallbackColor ?? AppColors.brandCtaAccent;
    final isCompact = height <= 80;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.35),
          ],
        ),
      ),
      child: Center(
        child: isCompact
            ? Icon(
                fallbackIcon ?? Icons.local_pharmacy,
                size: height * 0.4,
                color: color.withValues(alpha: 0.85),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      fallbackIcon ?? Icons.local_pharmacy,
                      size: height * 0.2,
                      color: color.withValues(alpha: 0.85),
                    ),
                  ),
                  if (title != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        title!,
                        style: TextStyle(
                          fontSize: height * 0.06,
                          fontWeight: FontWeight.bold,
                          color: color.withValues(alpha: 0.95),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Imagen no disponible',
                    style: TextStyle(
                      fontSize: height * 0.04,
                      color: color.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Widget específico para productos
class ProductImage extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ProductImage({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return NetworkImageWithFallback(
      imageUrl: imageUrl,
      width: width,
      height: height,
      title: productName,
      fallbackIcon: Icons.local_pharmacy,
      fallbackColor: AppColors.brandCtaAccent,
      borderRadius: borderRadius,
    );
  }
}

// Widget específico para farmacias/comercios
class RestaurantImage extends StatelessWidget {
  final String imageUrl;
  final String restaurantName;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const RestaurantImage({
    super.key,
    required this.imageUrl,
    required this.restaurantName,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return NetworkImageWithFallback(
      imageUrl: imageUrl,
      width: width,
      height: height,
      title: restaurantName,
      fallbackIcon: Icons.store,
      fallbackColor: AppColors.statusInfo,
      borderRadius: borderRadius,
    );
  }
}
