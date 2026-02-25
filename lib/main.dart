import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TodoApp(),
    );
  }
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> lista = [];
  String ora = "";

  @override
  void initState() {
    super.initState();
    _aggiornaOra();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _aggiornaOra();
    });
  }

  void _aggiornaOra() {
    final now = DateTime.now();
    setState(() {
      ora =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    });
  }

  void _aggiungi() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        lista.add({"testo": _controller.text, "fatto": false});
        _controller.clear();
      });
    }
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
          Text(
            ora,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
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
                return CheckboxListTile(
                  title: Text(
                    lista[index]["testo"],
                    style: TextStyle(
                      decoration: lista[index]["fatto"]
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  value: lista[index]["fatto"],
                  onChanged: (value) {
                    setState(() {
                      lista[index]["fatto"] = value!;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}