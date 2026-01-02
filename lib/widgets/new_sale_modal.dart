import 'package:flutter/material.dart';
import 'package:sabor_de_casa/theme/app_theme.dart';
import '../models/sale_model.dart';

class NewSaleModal extends StatefulWidget {
  final DateTime data;

  const NewSaleModal({
    super.key,
    required this.data,
  });

  @override
  State<NewSaleModal> createState() => _NewSaleModalState();
}

class _NewSaleModalState extends State<NewSaleModal> {
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();

  String pagamentoSelecionado = 'Pix';

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _salvar() {
    final nome = _nomeController.text.trim();
    final valorTexto = _valorController.text.replaceAll(',', '.');

    if (nome.isEmpty || valorTexto.isEmpty) return;

    final valor = double.tryParse(valorTexto);
    if (valor == null) return;

    Navigator.pop(
      context,
      Sale(
        nome: nome,
        pagamento: pagamentoSelecionado,
        valor: valor,
        data: DateTime(
          widget.data.year,
          widget.data.month,
          widget.data.day,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nova venda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),

              _input(_nomeController, 'Nome'),
              const SizedBox(height: 12),

              _input(
                _valorController,
                'Valor (R\$)',
                isNumber: true,
              ),
              const SizedBox(height: 12),

              _pagamento(),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _salvar,
                  child: const Text(
                    'Salvar',
                    style: TextStyle(fontSize: 18, color: AppColors.background),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType:
          isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.accent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _pagamento() {
    return DropdownButtonFormField<String>(
      value: pagamentoSelecionado,
      items: const [
        DropdownMenuItem(value: 'Pix', child: Text('Pix')),
        DropdownMenuItem(value: 'Dinheiro', child: Text('Dinheiro')),
        DropdownMenuItem(value: 'Cartao', child: Text('Cartão')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => pagamentoSelecionado = value);
        }
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.accent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
