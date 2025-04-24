// Flutter App Unificado para Gestão de Clientes e Serviços
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Clientes e Serviços',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Principal')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClienteForm()),
              ),
              child: const Text('Cadastrar Cliente'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServicoForm()),
              ),
              child: const Text('Cadastrar Serviço'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListaClientes()),
              ),
              child: const Text('Listar Clientes'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListaServicos()),
              ),
              child: const Text('Listar Serviços'),
            ),
          ],
        ),
      ),
    );
  }
}

class ClienteForm extends StatelessWidget {
  const ClienteForm({super.key});

  @override
  Widget build(BuildContext context) {
    final nomeController = TextEditingController();
    final telefoneController = TextEditingController();
    final enderecoController = TextEditingController();

    Future<void> salvarCliente() async {
      final db = await DBHelper.database;
      await db.insert('clientes', {
        'nome': nomeController.text,
        'telefone': telefoneController.text,
        'endereco': enderecoController.text,
      });
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome')),
            const SizedBox(height: 12),
            TextField(controller: telefoneController, decoration: const InputDecoration(labelText: 'Telefone')),
            const SizedBox(height: 12),
            TextField(controller: enderecoController, decoration: const InputDecoration(labelText: 'Endereço')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: salvarCliente, child: const Text('Salvar')),
          ],
        ),
      ),
    );
  }
}

class ServicoForm extends StatefulWidget {
  const ServicoForm({super.key});

  @override
  State<ServicoForm> createState() => _ServicoFormState();
}

class _ServicoFormState extends State<ServicoForm> {
  final descricaoController = TextEditingController();
  final dataController = TextEditingController();
  final horasController = TextEditingController();
  final valorUnitarioController = TextEditingController();
  List<Map<String, dynamic>> clientes = [];
  int? clienteSelecionado;

  @override
  void initState() {
    super.initState();
    carregarClientes();
  }

  Future<void> carregarClientes() async {
    final db = await DBHelper.database;
    final result = await db.query('clientes');
    setState(() {
      clientes = result;
    });
  }

  Future<void> salvarServico() async {
    final db = await DBHelper.database;
    await db.insert('servicos', {
      'clienteId': clienteSelecionado,
      'descricao': descricaoController.text,
      'data': dataController.text,
      'horas': int.parse(horasController.text),
      'valorUnitario': double.parse(valorUnitarioController.text),
      'valorTotal': int.parse(horasController.text) * double.parse(valorUnitarioController.text),
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Serviço')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Cliente'),
                value: clienteSelecionado,
                items: clientes.map((cliente) {
                  return DropdownMenuItem(
                    value: cliente['id'] as int,
                    child: Text(cliente['nome'] as String),
                  );
                }).toList(),
                onChanged: (value) => setState(() => clienteSelecionado = value),
              ),
              const SizedBox(height: 12),
              TextField(controller: descricaoController, decoration: const InputDecoration(labelText: 'Descrição')),
              const SizedBox(height: 12),
              TextField(controller: dataController, decoration: const InputDecoration(labelText: 'Data')),
              const SizedBox(height: 12),
              TextField(controller: horasController, decoration: const InputDecoration(labelText: 'Horas'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: valorUnitarioController, decoration: const InputDecoration(labelText: 'Valor Unitário'), keyboardType: TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: salvarServico, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}

class ListaClientes extends StatelessWidget {
  const ListaClientes({super.key});

  Future<List<Map<String, dynamic>>> buscarClientes() async {
    final db = await DBHelper.database;
    return await db.query('clientes');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: FutureBuilder(
        future: buscarClientes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final dados = snapshot.data!;
          return ListView.builder(
            itemCount: dados.length,
            itemBuilder: (_, i) {
              final c = dados[i];
              return ListTile(
                title: Text(c['nome']),
                subtitle: Text(c['telefone']),
              );
            },
          );
        },
      ),
    );
  }
}

class ListaServicos extends StatelessWidget {
  const ListaServicos({super.key});

  Future<List<Map<String, dynamic>>> buscarServicos() async {
    final db = await DBHelper.database;
    return await db.query('servicos');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Serviços')),
      body: FutureBuilder(
        future: buscarServicos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final dados = snapshot.data!;
          return ListView.builder(
            itemCount: dados.length,
            itemBuilder: (_, i) {
              final s = dados[i];
              return ListTile(
                title: Text(s['descricao']),
                subtitle: Text('Data: ${s['data']} - Total: R\$ ${s['valorTotal']}'),
              );
            },
          );
        },
      ),
    );
  }
}

class DBHelper {
  static Future<Database> get database async {
    final path = await getDatabasesPath();
    return openDatabase(
      p.join(path, 'gestao_clientes_servicos.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE clientes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT,
            telefone TEXT,
            endereco TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE servicos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            clienteId INTEGER,
            descricao TEXT,
            data TEXT,
            horas INTEGER,
            valorUnitario REAL,
            valorTotal REAL
          );
        ''');
      },
    );
  }
}