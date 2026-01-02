import 'package:flutter/material.dart';
import '../models/expense_model.dart';

class NewExpenseModal extends StatefulWidget {
  final DateTime data;

  const NewExpenseModal({
    super.key,
    required this.data,
  });

  @override
  State<NewExpenseModal> createState() => _NewExpenseModalState();
}

class _NewExpenseModalState extends State<NewExpenseModal> {
  final _descriptionController = TextEditingController();
  final _valorController = TextEditingController();

  String pagamentoSelecionado = 'Pix';

  @override
  void dispose() {
    _descriptionController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _salvar() {
    final description = _descriptionController.text.trim();
    final valorTexto = _valorController.text.replaceAll(',', '.');

    if (description.isEmpty || valorTexto.isEmpty) return;

    final valor = double.tryParse(valorTexto);
    if (valor == null) return;

    Navigator.pop(
      context,
      Expense(
        description: description,
        value: valor,
        date: DateTime(
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
            color: Color(0xFFFFF3DC),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nova despesa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B3E16),
                ),
              ),
              const SizedBox(height: 20),

              _input(_descriptionController, 'Descrição'),
              const SizedBox(height: 12),

              _input(
                _valorController,
                'Valor (R\$)',
                isNumber: true,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B3E16),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _salvar,
                  child: const Text(
                    'Salvar',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFE8D9B5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
