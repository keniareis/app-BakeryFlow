import 'package:flutter/material.dart';

class NewSaleModal extends StatelessWidget {
  const NewSaleModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            _handle(),
            const SizedBox(height: 16),
            _input('Nome'),
            const SizedBox(height: 12),
            _input('R\$ Valor', isNumber: true),
            const SizedBox(height: 16),
            _payment(),
            const SizedBox(height: 20),
            _save(context),
          ],
        ),
      ),
    );
  }

  Widget _handle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.brown.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _input(String hint, {bool isNumber = false}) {
    return TextField(
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFFFFBF2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.brown.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.brown.shade300),
        ),
      ),
    );
  }

  Widget _payment() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Forma de pagamento'),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF6B3E16),
            borderRadius: BorderRadius.circular(20),
          ),
          child: DropdownButton<String>(
            value: 'Pix',
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF6B3E16),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            style: const TextStyle(color: Colors.white),
            items: const [
              DropdownMenuItem(value: 'Pix', child: Text('Pix')),
              DropdownMenuItem(value: 'Dinheiro', child: Text('Dinheiro')),
              DropdownMenuItem(value: 'Débito', child: Text('Débito')),
            ],
            onChanged: (_) {},
          ),
        ),
      ],
    );
  }

  Widget _save(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B3E16),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () => Navigator.pop(context),
        child: const Text(
          'Salvar',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
