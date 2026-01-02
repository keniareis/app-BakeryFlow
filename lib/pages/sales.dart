import 'package:flutter/material.dart';
import 'package:sabor_de_casa/theme/app_theme.dart';
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

  String formaPagamentoSelecionada = 'Todos';

  double get saldoTotal =>
    vendas.fold(0, (total, sale) => total + sale.valor);

  Future<void> _loadSales() async {
    List<Sale> result;

    if (filtroSelecionado == 'Dia') {
      result = await AppDatabase.instance.getSalesByDay(
        dataSelecionada,
        pagamento: formaPagamentoSelecionada,
      );
    } else if (filtroSelecionado == 'Mês') {
      result = await AppDatabase.instance.getSalesByMonth(
        dataSelecionada,
        pagamento: formaPagamentoSelecionada,
      );
    } else {
      result = await AppDatabase.instance.getSalesByYear(
        dataSelecionada,
        pagamento: formaPagamentoSelecionada,
      );
    }

    setState(() {
      vendas
        ..clear()
        ..addAll(result);
    });
  }

  String get tituloPeriodo {
    if (filtroSelecionado == 'Dia') {
      return _formatarData(dataSelecionada);
    }
    if (filtroSelecionado == 'Mês') {
      const meses = [
        'JAN','FEV','MAR','ABR','MAI','JUN',
        'JUL','AGO','SET','OUT','NOV','DEZ'
      ];
      return '${meses[dataSelecionada.month - 1]} ${dataSelecionada.year}';
    }
    return dataSelecionada.year.toString();
  }

  void _voltarPeriodo() {
    setState(() {
      if (filtroSelecionado == 'Dia') {
        dataSelecionada =
            dataSelecionada.subtract(const Duration(days: 1));
      } else if (filtroSelecionado == 'Mês') {
        dataSelecionada = DateTime(
          dataSelecionada.year,
          dataSelecionada.month - 1,
          1,
        );
      } else {
        dataSelecionada = DateTime(
          dataSelecionada.year - 1,
          1,
          1,
        );
      }
    });
    _loadSales();
  }

  void _avancarPeriodo() {
    setState(() {
      if (filtroSelecionado == 'Dia') {
        dataSelecionada =
            dataSelecionada.add(const Duration(days: 1));
      } else if (filtroSelecionado == 'Mês') {
        dataSelecionada = DateTime(
          dataSelecionada.year,
          dataSelecionada.month + 1,
          1,
        );
      } else {
        dataSelecionada = DateTime(
          dataSelecionada.year + 1,
          1,
          1,
        );
      }
    });
    _loadSales();
  }


  Future<void> _deleteSale(int id) async {
    await AppDatabase.instance.deleteSale(id);
    _loadSales();
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

  Widget _dateHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _voltarPeriodo,
        ),
        Text(
          tituloPeriodo,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: podeAvancar ? _avancarPeriodo : null,
        ),
      ],
    );
  }

  bool get podeAvancar {
    if (filtroSelecionado == 'Dia') {
      return dataSelecionada.isBefore(hoje);
    }

    if (filtroSelecionado == 'Mês') {
      final atual = DateTime(hoje.year, hoje.month);
      final selecionado =
          DateTime(dataSelecionada.year, dataSelecionada.month);
      return selecionado.isBefore(atual);
    }

    // Ano
    return dataSelecionada.year < hoje.year;
  }

  Widget _balanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
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
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: formaPagamentoSelecionada,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'Todos', child: Text('Todos')),
              DropdownMenuItem(value: 'Pix', child: Text('Pix')),
              DropdownMenuItem(value: 'Dinheiro', child: Text('Dinheiro')),
              DropdownMenuItem(value: 'Cartao', child: Text('Cartão')),
            ],
            onChanged: (value) {
              setState(() {
                formaPagamentoSelecionada = value!;
              });
              _loadSales();
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
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Expanded(
              flex: 2,
              child: Text('Nome', style: TextStyle(color: AppColors.background))),
          Expanded(
              flex: 2,
              child: Text('Pagamento',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.background))),
          Expanded(
              flex: 2,
              child: Text('Valor',
                  textAlign: TextAlign.end,
                  style: TextStyle(color: AppColors.background))),
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
          id: sale.id!,
          nome: sale.nome,
          pagamento: sale.pagamento,
          valor: sale.valor.toStringAsFixed(2),
          onDelete: _deleteSale,
        );
      },
    );
  }

  Widget _bottomFilter() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _filterItem(
            label: 'Dia',
            selected: filtroSelecionado == 'Dia',
            onTap: () {
              setState(() => filtroSelecionado = 'Dia');
              _loadSales();
            },
          ),
          _filterItem(
            label: 'Mês',
            selected: filtroSelecionado == 'Mês',
            onTap: () {
              setState(() => filtroSelecionado = 'Mês');
              _loadSales();
            },
          ),
          _filterItem(
            label: 'Ano',
            selected: filtroSelecionado == 'Ano',
            onTap: () {
              setState(() => filtroSelecionado = 'Ano');
              _loadSales();
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
          backgroundColor: AppColors.primary,
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
            style: TextStyle(fontSize: 18, color: AppColors.background)),
      ),
    );
  }
}

class SaleTile extends StatelessWidget {
  final int id;
  final String nome;
  final String pagamento;
  final String valor;
  final Function(int) onDelete;

  const SaleTile({
    super.key,
    required this.id,
    required this.nome,
    required this.pagamento,
    required this.valor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.background,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                nome,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pagamento,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'R\$ $valor',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Excluir venda'),
                          content:
                              const Text('Deseja realmente excluir esta venda?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text('Excluir'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        onDelete(id);
                      }
                    },
                    child: const Icon(
                      Icons.delete_outline,
                      size: 26,
                      color: AppColors.primary,
                    ),
                  ),
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
            color: selected ? AppColors.background : AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}


