import 'package:flutter/material.dart';
import '../../widgets/new_expense_modal.dart';
import '../models/expense_model.dart';
import '../database/app_database.dart';
import '../widgets/finance_summary_chart.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  String filtroSelecionado = 'Mês';

  final List<Expense> despesas = [];

  DateTime dataSelecionada = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  String formaPagamentoSelecionada = 'Todos';

  // ===================== HELPERS =====================

  DateTime get hoje {
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month, agora.day);
  }

  double get totalDespesas =>
      despesas.fold(0, (total, e) => total + e.value);

  String get tituloPeriodo {
    if (filtroSelecionado == 'Mês') {
      const meses = [
        'JAN','FEV','MAR','ABR','MAI','JUN',
        'JUL','AGO','SET','OUT','NOV','DEZ'
      ];
      return '${meses[dataSelecionada.month - 1]} ${dataSelecionada.year}';
    }
    return dataSelecionada.year.toString();
  }

  // ===================== DATABASE =====================

  Future<void> _loadExpenses() async {
    List<Expense> result;
    double totalGanhos;

     if (filtroSelecionado == 'Mês') {
      result = await AppDatabase.instance.getExpensesByMonth(dataSelecionada);
      totalGanhos =
          await AppDatabase.instance.getTotalSalesByMonth(dataSelecionada);
    } else {
      result = await AppDatabase.instance.getExpensesByYear(dataSelecionada);
      totalGanhos =
          await AppDatabase.instance.getTotalSalesByYear(dataSelecionada);
    }

    setState(() {
      despesas
        ..clear()
        ..addAll(result);
      ganhos = totalGanhos;
    });
  }


  Future<void> _deleteExpense(int id) async {
    await AppDatabase.instance.deleteExpense(id);
    _loadExpenses();
  }

  double ganhos = 0;
  // ===================== LIFE CYCLE =====================

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _dateHeader(),
            const SizedBox(height: 16),
            FinanceSummaryChart(
              ganhos: ganhos,
              gastos: totalDespesas,
            ),
            const SizedBox(height: 16),
            _totalCard(),
            const SizedBox(height: 16),
            _tableHeader(),
            const SizedBox(height: 8),
            Expanded(child: _expensesList()),
            const SizedBox(height: 12),
            _bottomFilter(),
            const SizedBox(height: 12),
            _newExpenseButton(),
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _avancarPeriodo,
        ),
      ],
    );
  }

  void _voltarPeriodo() {
    setState(() {
      if (filtroSelecionado == 'Mês') {
        dataSelecionada =
            DateTime(dataSelecionada.year, dataSelecionada.month - 1, 1);
      } else {
        dataSelecionada =
            DateTime(dataSelecionada.year - 1, 1, 1);
      }
    });
    _loadExpenses();
  }

  void _avancarPeriodo() {
    setState(() {
      if (filtroSelecionado == 'Mês') {
        dataSelecionada =
            DateTime(dataSelecionada.year, dataSelecionada.month + 1, 1);
      } else {
        dataSelecionada =
            DateTime(dataSelecionada.year + 1, 1, 1);
      }
    });
    _loadExpenses();
  }

  Widget _totalCard() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7E8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text('Total de despesas',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(
              'R\$ ${totalDespesas.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('Nome', style: TextStyle(color: Colors.white))),
          Expanded(flex: 2, child: Text('Pagamento', textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
          Expanded(flex: 2, child: Text('Valor', textAlign: TextAlign.end, style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _expensesList() {
    if (despesas.isEmpty) {
      return const Center(child: Text('Nenhuma despesa registrada'));
    }

    return ListView.builder(
      itemCount: despesas.length,
      itemBuilder: (context, index) {
        final expense = despesas[index];
        return ExpenseTile(
          id: expense.id!,
          description: expense.description,
          value: expense.value.toStringAsFixed(2),
          onDelete: _deleteExpense,
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
            label: 'Mês',
            selected: filtroSelecionado == 'Mês',
            onTap: () {
              setState(() => filtroSelecionado = 'Mês');
              _loadExpenses();
            },
          ),
          _filterItem(
            label: 'Ano',
            selected: filtroSelecionado == 'Ano',
            onTap: () {
              setState(() => filtroSelecionado = 'Ano');
              _loadExpenses();
            },
          ),

        ],
      ),
    );
  }

  Widget _newExpenseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () async {
          final expense = await showModalBottomSheet<Expense>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => NewExpenseModal(data: dataSelecionada),
          );

          if (expense != null) {
            await AppDatabase.instance.insertExpense(expense);
            _loadExpenses();
          }
        },
        icon: const Icon(Icons.remove),
        label: const Text(
          'Nova despesa',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class ExpenseTile extends StatelessWidget {
  final int id;
  final String description;
  final String value;
  final Function(int) onDelete;

  const ExpenseTile({
    super.key,
    required this.id,
    required this.description,
    required this.value,
    required this.onDelete,
  });

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
              flex: 3,
              child: Text(
                description,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'R\$ $value',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Excluir despesa'),
                          content: const Text(
                              'Deseja realmente excluir esta despesa?'),
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
                      color: Colors.red,
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
            color: selected ? Colors.white : const Color(0xFF6B3E16),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}
