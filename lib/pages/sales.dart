import 'package:flutter/material.dart';
import '../../widgets/new_sale_modal.dart';
import '../models/sale_model.dart';
import '../database/app_database.dart';

class Sales extends StatefulWidget {
  const Sales({super.key});

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  String filtroSelecionado = 'Dia';

  final List<Sale> vendas = [];

  double get saldoTotal => vendas.fold(0, (total, sale) => total + sale.valor);

  DateTime dataSelecionada = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  
  String _formatarData(DateTime data) {
    const meses = [
      'JAN',
      'FEV',
      'MAR',
      'ABR',
      'MAI',
      'JUN',
      'JUL',
      'AGO',
      'SET',
      'OUT',
      'NOV',
      'DEZ',
    ];

    return '${data.day.toString().padLeft(2, '0')} ${meses[data.month - 1]}';
  }

  DateTime get hoje {
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month, agora.day);
  }

  Future<void> _loadSales() async {
    final result = await AppDatabase.instance.getSalesByDay(dataSelecionada);

    setState(() {
      vendas
        ..clear()
        ..addAll(result);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  @override
  Widget build(BuildContext context) {
    // REMOVIDO o Scaffold daqui para não dar conflito com a MainPage
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _dateHeader(),
            const SizedBox(height: 16),
            _balanceCard(),
            const SizedBox(height: 16),
            _tableHeader(),
            const SizedBox(height: 8),
            Expanded(child: _salesList()),
            const SizedBox(height: 12),
            _bottomFilter(),
            const SizedBox(height: 12),
            _newSaleButton(),
          ],
        ),
      ),
    );
  }

  // Seus Widgets auxiliares (_dateHeader, _balanceCard, etc) continuam aqui...
  // (Mantive a lógica que você já tinha, apenas organizei a estrutura)

  Widget _dateHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              dataSelecionada =
                  dataSelecionada.subtract(const Duration(days: 1));
            });
            _loadSales();
          },
        ),
        Text(
          _formatarData(dataSelecionada),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: dataSelecionada.isBefore(hoje)
              ? () {
                  setState(() {
                    dataSelecionada =
                        dataSelecionada.add(const Duration(days: 1)); 
                  });
                  _loadSales();
                }
              : null,
        ),
      ],
    );
  }

  Widget _balanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('Saldo atual',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            'R\$ ${saldoTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B3E16),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: 'Todos',
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'Todos', child: Text('Todos')),
              DropdownMenuItem(value: 'Pix', child: Text('Pix')),
              DropdownMenuItem(value: 'Dinheiro', child: Text('Dinheiro')),
            ],
            onChanged: (value) {},
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE8D9B5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
          color: const Color(0xFF6B3E16),
          borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Expanded(
              flex: 2,
              child: Text('Nome', style: TextStyle(color: Colors.white))),
          Expanded(
              flex: 2,
              child: Text('Pagamento',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white))),
          Expanded(
              flex: 2,
              child: Text('Valor',
                  textAlign: TextAlign.end,
                  style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _salesList() {
    if (vendas.isEmpty) {
      return Center(
        child: Text(
          dataSelecionada == hoje
              ? 'Nenhuma venda registrada hoje'
              : 'Nenhuma venda registrada neste dia',
        ),
      );
    }

    return ListView.builder(
      itemCount: vendas.length,
      itemBuilder: (context, index) {
        final sale = vendas[index];
        return SaleTile(
          nome: sale.nome,
          pagamento: sale.pagamento,
          valor: sale.valor.toStringAsFixed(2),
        );
      },
    );
  }

  Widget _bottomFilter() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3DC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _filterItem(
            label: 'Dia',
            selected: filtroSelecionado == 'Dia',
            onTap: () {
              setState(() => filtroSelecionado = 'Dia');
            },
          ),
          _filterItem(
            label: 'Mês',
            selected: filtroSelecionado == 'Mês',
            onTap: () {
              setState(() => filtroSelecionado = 'Mês');
            },
          ),
          _filterItem(
            label: 'Ano',
            selected: filtroSelecionado == 'Ano',
            onTap: () {
              setState(() => filtroSelecionado = 'Ano');
            },
          ),
        ],
      ),
    );
  }

  Widget _newSaleButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B3E16),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () async {
          final sale = await showModalBottomSheet<Sale>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => NewSaleModal(
              data: dataSelecionada,
            ),
          );

          if (sale != null) {
            await AppDatabase.instance.insertSale(sale);
            _loadSales();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova venda',
            style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}

class SaleTile extends StatelessWidget {
  final String nome;
  final String pagamento;
  final String valor;

  const SaleTile(
      {super.key,
      required this.nome,
      required this.pagamento,
      required this.valor});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF7E8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Text(nome,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFE8D9B5),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(pagamento,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12)),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('R\$ $valor',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Icon(Icons.delete_outline,
                      size: 28, color: Color(0xFF6B3E16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _filterItem({
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6B3E16) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF6B3E16),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}
