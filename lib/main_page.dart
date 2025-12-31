import 'package:flutter/material.dart';
import 'package:sabor_de_casa/sales.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // Removido o 'const' daqui para evitar erros com widgets dinâmicos
  final List<Widget> _pages = [
    const Sales(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O Scaffold principal fica aqui
      body: IndexedStack( // DICA: IndexedStack mantém o estado das telas ao trocar de aba
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: const Color(0xFF6B3E16),
        selectedItemColor: const Color(0xFFE8D9B5),
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'Vendas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Despesas',
          ),
        ],
      ),
    );
  }
}