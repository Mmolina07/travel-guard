import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../widgets/ink_button.dart';
import '../menu_model.dart';

/// Nombre visible de cada [ProductCategory]; [plural] para los títulos
/// de sección del menú.
String productCategoryLabel(BuildContext context, ProductCategory c, {bool plural = false}) {
  final l10n = context.l10n;
  return switch (c) {
    ProductCategory.plato => plural ? l10n.productCategoryPlatos : l10n.productCategoryPlato,
    ProductCategory.bebida => plural ? l10n.productCategoryBebidas : l10n.productCategoryBebida,
    ProductCategory.postre => plural ? l10n.productCategoryPostres : l10n.productCategoryPostre,
    ProductCategory.otro => plural ? l10n.productCategoryOtros : l10n.productCategoryOtro,
  };
}

IconData productCategoryIcon(ProductCategory c) => switch (c) {
      ProductCategory.plato => Icons.restaurant_outlined,
      ProductCategory.bebida => Icons.local_drink_outlined,
      ProductCategory.postre => Icons.icecream_outlined,
      ProductCategory.otro => Icons.fastfood_outlined,
    };

/// Interpreta lo que el comercio escribe en "Precio": acepta "18000",
/// "18.000" (miles con punto) y "18,50" / "18.50" (decimales). Devuelve
/// `null` si no es un número.
double? parseProductPrice(String raw) {
  final text = raw.trim().replaceAll(' ', '');
  if (text.isEmpty) return null;
  if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(text)) {
    return double.tryParse(text.replaceAll('.', ''));
  }
  return double.tryParse(text.replaceAll(',', '.'));
}

/// Formulario para crear o editar un producto del menú (HU-20 CA1–CA5).
///
/// Obligatorios: nombre y precio (> 0). La descripción es opcional. Si
/// se pasa [onSave], se llama antes de cerrar: si falla, el diálogo
/// sigue abierto con lo escrito y se muestra [saveErrorMessage].
class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({
    super.key,
    this.existing,
    this.onSave,
    this.saveErrorMessage,
    this.takenNames = const [],
  });

  final MenuItem? existing;

  /// Nombres de los demás productos del mismo menú: no se permite repetir
  /// uno (sin distinguir mayúsculas).
  final List<String> takenNames;
  final Future<void> Function(MenuItem product)? onSave;
  final String? saveErrorMessage;

  /// Devuelve el producto guardado, o `null` si se canceló.
  static Future<MenuItem?> show(
    BuildContext context, {
    MenuItem? existing,
    Future<void> Function(MenuItem product)? onSave,
    String? saveErrorMessage,
    List<String> takenNames = const [],
  }) {
    return showDialog<MenuItem>(
      context: context,
      builder: (_) => ProductFormDialog(
        existing: existing,
        onSave: onSave,
        saveErrorMessage: saveErrorMessage,
        takenNames: takenNames,
      ),
    );
  }

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late ProductCategory _category;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _description = TextEditingController(text: existing?.description ?? '');
    _price = TextEditingController(
      text: existing == null ? '' : existing.price.toStringAsFixed(existing.price % 1 == 0 ? 0 : 2),
    );
    _category = existing?.category ?? ProductCategory.plato;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    // CA4: sin nombre o sin precio no se guarda, con el mensaje de la HU.
    if (_name.text.trim().isEmpty || _price.text.trim().isEmpty) {
      _formKey.currentState!.validate();
      setState(() => _error = l10n.productFormRequiredFields);
      return;
    }
    if (!_formKey.currentState!.validate()) {
      setState(() => _error = null);
      return;
    }

    final product = MenuItem(
      id: widget.existing?.id,
      name: _name.text.trim(),
      description: _description.text.trim(),
      price: parseProductPrice(_price.text)!,
      category: _category,
    );

    final onSave = widget.onSave;
    if (onSave != null) {
      setState(() {
        _saving = true;
        _error = null;
      });
      try {
        await onSave(product);
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _saving = false;
          _error = widget.saveErrorMessage ?? l10n.menuDetailSaveErrorSnackbar;
        });
        return;
      }
    }
    if (!mounted) return;
    Navigator.pop(context, product);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(
        isEdit ? l10n.productFormEditTitle : l10n.createMenuAddProductDialogTitle,
        style: AppText.display(26),
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  style: AppText.ui(15),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: '${l10n.createMenuProductNameLabel} *',
                    hintText: l10n.createMenuProductNameHint,
                  ),
                  inputFormatters: [
                    AppInputFormatters.safeText,
                    AppInputFormatters.maxLength(150),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.productFormRequiredField;
                    final error = Validators.title(context, v, max: 150);
                    if (error != null) return error;
                    final name = v.trim().toLowerCase();
                    final original = widget.existing?.name.trim().toLowerCase();
                    final duplicated = widget.takenNames
                        .any((n) => n.trim().toLowerCase() == name && name != original);
                    return duplicated ? context.l10n.valDuplicateProduct : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _price,
                  style: AppText.ui(15),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  // Dígitos y separadores (`18.000`, `18,50`); nada de letras.
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                    LengthLimitingTextInputFormatter(14),
                  ],
                  decoration: InputDecoration(
                    labelText: '${l10n.createMenuProductPriceLabel} *',
                    hintText: l10n.createMenuProductPriceHint,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.productFormRequiredField;
                    final price = parseProductPrice(v);
                    // CA3: precio inválido o <= 0.
                    if (price == null || price <= 0) return l10n.productFormInvalidPrice;
                    if (price >= 10000000000) {
                      return l10n.valAmountMax(context.formatMoney(9999999999));
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ProductCategory>(
                  initialValue: _category,
                  decoration: InputDecoration(labelText: l10n.productFormCategoryLabel),
                  items: [
                    for (final c in ProductCategory.values)
                      DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(productCategoryIcon(c), size: 18, color: AppColors.inkSoft),
                            const SizedBox(width: 8),
                            Text(productCategoryLabel(context, c), style: AppText.ui(15)),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (c) => setState(() => _category = c ?? _category),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  maxLines: 3,
                  maxLength: 300,
                  inputFormatters: [AppInputFormatters.safeText],
                  validator: (v) => Validators.freeText(context, v, max: 300),
                  style: AppText.ui(15),
                  decoration: InputDecoration(
                    labelText: l10n.productFormDescriptionOptionalLabel,
                    hintText: l10n.createMenuProductDescriptionHint,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorWash,
                      borderRadius: BorderRadius.circular(AppRadius.control),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_error!, style: AppText.ui(12, color: AppColors.error)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
      actions: [
        InkButton(
          label: l10n.createMenuCancelButton,
          variant: InkButtonVariant.secondary,
          onPressed: _saving ? null : () => Navigator.pop(context),
        ),
        InkButton(
          label: isEdit ? l10n.productFormSaveButton : l10n.createMenuAddProductButton,
          loading: _saving,
          onPressed: _submit,
        ),
      ],
    );
  }
}
