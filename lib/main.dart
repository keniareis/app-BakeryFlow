import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/sales.dart';
// import 'pages/expenses_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle de Vendas',
      // A home agora é a MainPage que contém a BottomNavigationBar
      home: const MainPage(),
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFFF5EEDC),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // Lista de páginas que serão exibidas
  final List<Widget> _pages = [
    const Sales(),    // Certifique-se que esta classe existe abaixo ou em outro arquivo
    const Expenses(), // Certifique-se que esta classe existe abaixo ou em outro arquivo
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack evita que a tela reinicie do zero ao trocar de aba
      body: IndexedStack(
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


// --- CLASSE EXPENSES (Resumo para teste) ---
class Expenses extends StatelessWidget {
  const Expenses({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Conteúdo de Despesas aqui"));
  }
}