import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TodoApp(),
      );
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});
  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> lista = [];
  String ora = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _caricaLista();

    _aggiornaOra();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _aggiornaOra());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // Salva quando l'app va in background/si chiude
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _salvaLista(); // best effort
    }
  }

  void _aggiornaOra() {
    final now = DateTime.now();
    setState(() {
      ora =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    });
  }

  Future<void> _caricaLista() async {
    final prefs = await SharedPreferences.getInstance();
    final dati = prefs.getString('lista_todo');
    if (dati == null) return;

    final decoded = jsonDecode(dati) as List<dynamic>;
    setState(() {
      lista = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    });
  }

  Future<void> _salvaLista() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lista_todo', jsonEncode(lista));
  }

  Future<void> _aggiungi() async {
    final testo = _controller.text.trim();
    if (testo.isEmpty) return;

    setState(() {
      lista.add({"testo": testo, "fatto": false});
      _controller.clear();
    });

    await _salvaLista(); // <<< IMPORTANTISSIMO
  }

  Future<void> _toggleFatto(int index, bool value) async {
    setState(() => lista[index]["fatto"] = value);
    await _salvaLista(); // <<< IMPORTANTISSIMO
  }

  Future<void> _elimina(int index) async {
    setState(() => lista.removeAt(index));
    await _salvaLista(); // <<< IMPORTANTISSIMO
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[300],
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: const Text("Le mie cose da fare"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(ora,
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _aggiungi(),
                    decoration: const InputDecoration(
                      hintText: "Scrivi cosa devi fare",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _aggiungi,
                  child: const Text("Aggiungi"),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: lista.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: ValueKey("${lista[index]["testo"]}-$index"),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _elimina(index),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Colors.redAccent,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      lista[index]["testo"],
                      style: TextStyle(
                        decoration: (lista[index]["fatto"] as bool)
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    value: lista[index]["fatto"] as bool,
                    onChanged: (v) => _toggleFatto(index, v ?? false),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}