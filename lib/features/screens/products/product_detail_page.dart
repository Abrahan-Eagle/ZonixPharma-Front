import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zonix/features/services/cart_service.dart';
import 'package:zonix/features/services/restaurant_service.dart';
import 'package:zonix/models/product.dart';
import 'package:zonix/models/cart_item.dart';
import 'package:zonix/models/restaurant.dart';
import 'package:zonix/features/screens/restaurants/restaurant_details_page.dart';
import 'package:zonix/features/utils/network_image_with_fallback.dart';
import 'package:zonix/features/utils/app_colors.dart';
import 'package:zonix/config/app_config.dart';
import 'package:logger/logger.dart';

const Color _kPrimary = AppColors.brandTeal;
const Color _kAccent = AppColors.brandCtaAccent;

/// Detalle de un producto / medicamento (Zonix Pharma).
///
/// Muestra información farmacéutica (principio activo, presentación,
/// registro INHRR), badges Rx / cadena de frío / controlado y permite
/// añadir el producto al carrito propagando los flags farmacéuticos.
class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final Logger logger = Logger();
  final TextEditingController _instructionsController = TextEditingController();
  int _quantity = 1;
  bool _isLoading = false;
  late Future<Restaurant?> _restaurantFuture;
  Restaurant? _restaurant;
  bool _isFavProduct = false;
  static const _favProdKey = 'favorite_products';

  Product get _product => widget.product;

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _bgPrimary(BuildContext context) =>
      _isDark(context) ? AppColors.brandSurfaceDark : AppColors.white;

  Color _bgSecondary(BuildContext context) => _isDark(context)
      ? AppColors.brandSurfaceContainerDark
      : AppColors.brandSurfaceLight;

  Color _borderColor(BuildContext context) => _isDark(context)
      ? AppColors.brandSurfaceDarkLighter
      : AppColors.brandStrokeLight;

  Color _textPrimary(BuildContext context) => AppColors.primaryText(context);

  Color _textSecondary(BuildContext context) =>
      AppColors.secondaryText(context);

  @override
  void initState() {
    super.initState();
    _restaurantFuture = _loadRestaurant();
    _loadFav();
  }

  Future<void> _loadFav() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_favProdKey) ?? [];
    if (mounted) {
      setState(() => _isFavProduct = ids.contains(_product.id.toString()));
    }
  }

  Future<void> _toggleFav() async {
    await HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_favProdKey) ?? [];
    final idStr = _product.id.toString();
    if (ids.contains(idStr)) {
      ids.remove(idStr);
      _isFavProduct = false;
    } else {
      ids.add(idStr);
      _isFavProduct = true;
    }
    await prefs.setStringList(_favProdKey, ids);
    if (mounted) {
      setState(() {});
    }
  }

  void _shareProduct() {
    final link = AppConfig.buildCommerceShareUrl(_product.commerceId);
    final pharmacyName = _restaurant?.nombreLocal ?? '';
    final text =
        '💊 *${_product.name}* - \$${_product.price.toStringAsFixed(2)}\n'
        '${_product.description.isNotEmpty ? '${_product.description}\n' : ''}'
        '${pharmacyName.isNotEmpty ? '🏥 En *$pharmacyName* - Zonix Pharma\n' : ''}'
        '\n👉 $link';
    SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  double get _unitTotal => _product.price;
  double get _total => _unitTotal * _quantity;

  String _buildNotes() {
    final instructions = _instructionsController.text.trim();
    return instructions;
  }

  Future<Restaurant?> _loadRestaurant() async {
    if (_product.commerceId <= 0) {
      logger.w(
          'Skipping pharmacy load: invalid commerceId ${_product.commerceId}');
      return null;
    }

    try {
      final restaurantService = RestaurantService();
      return await restaurantService
          .fetchRestaurantDetails2(_product.commerceId);
    } catch (e, stack) {
      logger.e('Error loading pharmacy', error: e, stackTrace: stack);
      return null;
    }
  }

  void _navigateToRestaurant() async {
    if (_restaurant == null) return;
    setState(() => _isLoading = true);
    try {
      final r = _restaurant!;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RestaurantDetailsPage(
            commerceId: r.id,
            nombreLocal: r.nombreLocal,
            direccion: r.direccion,
            telefono: r.telefono,
            abierto: r.abierto,
            horario: r.horario,
            logoUrl: r.logoUrl,
            businessType: r.businessType,
            latitude: r.latitude,
            longitude: r.longitude,
          ),
        ),
      );
      if (!context.mounted) return;
    } catch (e) {
      logger.e('Navigation error', error: e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context, listen: false);
    final mediaQuery = MediaQuery.of(context);
    final heroHeight = mediaQuery.size.height * 0.45;

    final isDark = _isDark(context);
    return Scaffold(
      backgroundColor: _bgPrimary(context),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildHeroImage(context, heroHeight),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -40),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _bgPrimary(context),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildDragHandle(context),
                            const SizedBox(height: 20),
                            _buildProductHeader(context, _total),
                            const SizedBox(height: 16),
                            _buildBadges(context),
                            const SizedBox(height: 16),
                            _buildDescription(context),
                            const SizedBox(height: 24),
                            _buildPharmaInfo(context),
                            const SizedBox(height: 16),
                            _buildPharmacyLink(context),
                            const SizedBox(height: 24),
                            Divider(color: _borderColor(context), height: 1),
                            const SizedBox(height: 24),
                            _buildSpecialInstructions(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _buildTopButtons(context),
            _buildBottomBar(context, cartService, _total),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context, double height) {
    final bgColor = _bgPrimary(context);
    return SliverToBoxAdapter(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ProductImage(
              imageUrl: _product.image,
              productName: _product.name,
              width: double.infinity,
              height: height,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.black.withValues(alpha: 0.4),
                    AppColors.transparent,
                    bgColor.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopButtons(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 24,
      right: 24,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _circleButton(
              context: context,
              icon: Icons.arrow_back,
              onTap: () => Navigator.of(context).pop(),
            ),
            Row(
              children: [
                _circleButton(
                  context: context,
                  icon: _isFavProduct ? Icons.favorite : Icons.favorite_border,
                  onTap: _toggleFav,
                  iconColor: _isFavProduct ? AppColors.statusError : null,
                ),
                const SizedBox(width: 8),
                _circleButton(
                  context: context,
                  icon: Icons.share,
                  onTap: _shareProduct,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Material(
      color: AppColors.black.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor ?? AppColors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Center(
      child: Container(
        width: 48,
        height: 6,
        decoration: BoxDecoration(
          color: _borderColor(context),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context, double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                _product.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary(context),
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _kAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 16, color: _kAccent),
                    const SizedBox(width: 4),
                    Text(
                      '${_product.rating > 0 ? _product.rating.toStringAsFixed(1) : '-'} (${_product.reviewCount > 0 ? _formatCount(_product.reviewCount) : '0'})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: _textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        if (_product.pharmaSummary.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _product.pharmaSummary,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: _textSecondary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (_product.category.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _kAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _product.category,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: _kAccent),
            ),
          ),
        ],
      ],
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      _product.description.isNotEmpty
          ? _product.description
          : 'Sin descripción',
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: _textSecondary(context),
        height: 1.5,
      ),
    );
  }

  Widget _buildBadges(BuildContext context) {
    final badges = <_PharmaBadge>[];
    if (_product.requiresPrescription) {
      badges.add(_PharmaBadge(
        icon: Icons.receipt_long,
        label: 'Requiere receta',
        color: AppColors.brandTealDeep,
      ));
    }
    if (_product.controlledSubstance) {
      badges.add(_PharmaBadge(
        icon: Icons.warning_amber_rounded,
        label: 'Sustancia controlada',
        color: AppColors.statusError,
      ));
    }
    if (_product.coldChain) {
      badges.add(_PharmaBadge(
        icon: Icons.ac_unit,
        label: 'Cadena de frío',
        color: AppColors.statusInfo,
      ));
    }
    if (badges.isEmpty) {
      badges.add(_PharmaBadge(
        icon: Icons.check_circle_outline,
        label: 'Venta libre (OTC)',
        color: AppColors.statusSuccess,
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: badges
          .map((b) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: b.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: b.color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(b.icon, size: 14, color: b.color),
                    const SizedBox(width: 6),
                    Text(
                      b.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: b.color,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildPharmaInfo(BuildContext context) {
    final entries = <MapEntry<String, String>>[];
    if ((_product.activeIngredient ?? '').isNotEmpty) {
      entries.add(MapEntry('Principio activo', _product.activeIngredient!));
    }
    if ((_product.dosageForm ?? '').isNotEmpty) {
      entries.add(MapEntry(
          'Forma farmacéutica', _humanDosageForm(_product.dosageForm!)));
    }
    if ((_product.concentration ?? '').isNotEmpty) {
      entries.add(MapEntry('Concentración', _product.concentration!));
    }
    if ((_product.presentation ?? '').isNotEmpty) {
      entries.add(MapEntry('Presentación', _product.presentation!));
    }
    if ((_product.manufacturer ?? '').isNotEmpty) {
      entries.add(MapEntry('Laboratorio', _product.manufacturer!));
    }
    if ((_product.healthRegistry ?? '').isNotEmpty) {
      entries.add(MapEntry('Registro INHRR', _product.healthRegistry!));
    }
    if ((_product.barcode ?? '').isNotEmpty) {
      entries.add(MapEntry('Código', _product.barcode!));
    }
    if ((_product.atcCode ?? '').isNotEmpty) {
      entries.add(MapEntry('Código ATC', _product.atcCode!));
    }
    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgSecondary(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información farmacéutica',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _textPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          ...entries.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      e.key,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: _textSecondary(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _humanDosageForm(String dosageForm) {
    switch (dosageForm) {
      case 'tablet':
        return 'Tabletas';
      case 'capsule':
        return 'Cápsulas';
      case 'syrup':
        return 'Jarabe';
      case 'suspension':
        return 'Suspensión';
      case 'injection':
        return 'Inyectable';
      case 'cream':
        return 'Crema';
      case 'ointment':
        return 'Ungüento';
      case 'gel':
        return 'Gel';
      case 'drops':
        return 'Gotas';
      case 'patch':
        return 'Parches';
      case 'suppository':
        return 'Supositorios';
      case 'inhaler':
        return 'Inhalador';
      case 'powder':
        return 'Polvo';
      case 'solution':
        return 'Solución';
      case 'spray':
        return 'Spray';
      case 'device':
        return 'Dispositivo';
      default:
        return dosageForm;
    }
  }

  Widget _buildPharmacyLink(BuildContext context) {
    return FutureBuilder<Restaurant?>(
      future: _restaurantFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 24,
              child: Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _kPrimary)));
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        _restaurant = snapshot.data;
        return GestureDetector(
          onTap: _isLoading ? null : _navigateToRestaurant,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kPrimary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _kPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_pharmacy,
                      color: _kPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _restaurant?.nombreLocal ?? '',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary(context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _restaurant?.abierto == true
                            ? 'Abierta · Ver catálogo completo'
                            : 'Cerrada · Ver catálogo completo',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: _textSecondary(context)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: _kPrimary, size: 22),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecialInstructions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instrucciones para el farmacéutico',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _bgSecondary(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor(context)),
          ),
          child: TextField(
            controller: _instructionsController,
            maxLines: 3,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14, color: _textPrimary(context)),
            decoration: InputDecoration(
              hintText: 'Ej: prefiero genérico, dosis por blíster aparte...',
              hintStyle: GoogleFonts.plusJakartaSans(
                  color: _textSecondary(context), fontSize: 14),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    CartService cartService,
    double total,
  ) {
    final isDark = _isDark(context);
    return Positioned(
      left: 16,
      right: 16,
      bottom: MediaQuery.of(context).padding.bottom + 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? _bgSecondary(context).withValues(alpha: 0.95)
              : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.white.withValues(alpha: 0.05)
                : AppColors.black12,
          ),
          boxShadow: [
            BoxShadow(
              color: _kPrimary.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color:
                    isDark ? _bgPrimary(context) : AppColors.brandSurfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove,
                        color: _textPrimary(context), size: 20),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(40, 40),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '$_quantity',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary(context),
                      ),
                    ),
                  ),
                  IconButton(
                    icon:
                        Icon(Icons.add, color: _textPrimary(context), size: 20),
                    onPressed: () {
                      if (_product.hasStockLimit &&
                          _product.stock > 0 &&
                          _quantity >= _product.stock) {
                        return;
                      }
                      setState(() => _quantity++);
                    },
                    style: IconButton.styleFrom(
                      minimumSize: const Size(40, 40),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Material(
                color: _kPrimary,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    if (!_product.isAvailable ||
                        (_product.hasStockLimit && _product.stock <= 0)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Producto no disponible o sin stock'),
                        ),
                      );
                      return;
                    }
                    final notes = _buildNotes();
                    final result = cartService.addToCart(CartItem(
                      id: _product.id,
                      nombre: _product.name,
                      precio: _unitTotal,
                      quantity: _quantity,
                      image: _product.image,
                      stock: _product.hasStockLimit ? _product.stock : null,
                      category: _product.category,
                      notes: notes.isEmpty ? null : notes,
                      commerceId: _product.commerceId,
                      requiresPrescription: _product.requiresPrescription,
                      prescriptionType: _product.prescriptionType,
                      controlledSubstance: _product.controlledSubstance,
                      coldChain: _product.coldChain,
                      activeIngredient: _product.activeIngredient,
                      concentration: _product.concentration,
                      presentation: _product.presentation,
                    ));
                    final message = switch (result.status) {
                      CartAddStatus.replacedCommerce =>
                        'Carrito actualizado. Solo puedes tener productos de una farmacia a la vez.',
                      CartAddStatus.blockedLimit =>
                        'No puedes agregar mas de 100 unidades',
                      CartAddStatus.blockedStock =>
                        'Cantidad no disponible por stock',
                      _ => _product.requiresPrescription
                          ? 'Añadido. Recuerda subir la receta médica al pagar.'
                          : 'Producto añadido al carrito',
                    };
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Agregar',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward,
                              color: AppColors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PharmaBadge {
  final IconData icon;
  final String label;
  final Color color;
  _PharmaBadge({required this.icon, required this.label, required this.color});
}
