import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _listaTarefas = [];
  Map<String, dynamic> _ultimaTarefaRemovida = {};
  final TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarArquivo() async {
    var file = await _getFile();

    String dados = json.encode(_listaTarefas);
    file.writeAsString(dados);
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();

      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  _salvarTarefa() {
    String textoDigitado = _controllerTarefa.text;

    Map<String, dynamic> tarefa = {};
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;

    setState(() {
      _listaTarefas.add(tarefa);
    });

    _salvarArquivo();

    _controllerTarefa.text = "";
  }

  @override
  void initState() {
    super.initState();

    _lerArquivo().then((dados) {
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    });
  }

  Widget criarItemLista(context, index) {
    final item = _listaTarefas[index]["titulo"];
    return Dismissible(
      key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        //snackbar
        //final snackBar = const SnackBar(content: Text("Tarefa Removida"));

        _ultimaTarefaRemovida = _listaTarefas[index];

        _listaTarefas.removeAt(index);
        _salvarArquivo();
        // descontinuado
        //Scaffold.of(context).showSnackBar(snackBar);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Tarefa Removida com sucesso"),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: "Desfazer ação",
            onPressed: () {
              // salva na mesma posição que foi removida.
              setState(() {
                _listaTarefas.insert(index, _ultimaTarefaRemovida);
              });

              _salvarArquivo();
            },
          ),
        ));

        //_salvarArquivo();
      },
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Icon(
              Icons.delete,
              color: Colors.white,
            )
          ],
        ),
      ),
      child: CheckboxListTile(
          title: Text(_listaTarefas[index]["titulo"],
              style: const TextStyle(fontSize: 20)),
          value: _listaTarefas[index]["realizada"],
          onChanged: (valorAlterado) {
            setState(() {
              _listaTarefas[index]["realizada"] = valorAlterado;
            });

            _salvarArquivo();
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Tarefas"),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.purple,
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Adicionar Tarefa"),
                  content: TextField(
                    controller: _controllerTarefa,
                    decoration: InputDecoration(labelText: "Digite sua tarefa"),
                    onChanged: (text) {},
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Cancelar"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text("Salvar"),
                      onPressed: () {
                        _salvarTarefa();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              });
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _listaTarefas.length,
              itemBuilder: criarItemLista,
              //(context, int index) {
              // return Dismissible(
              //   background: Container(
              //     color: Colors.green,
              //     padding: const EdgeInsets.all(16),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       children: const [
              //         Icon(Icons.edit, color: Colors.white),
              //       ],
              //     ),
              //   ),
              //   secondaryBackground: Container(
              //     color: Colors.red,
              //     padding: const EdgeInsets.all(16),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.end,
              //       children: const [
              //         Icon(Icons.delete, color: Colors.white),
              //       ],
              //     ),
              //   ),
              //   onDismissed: (direction) {
              //     if (direction == DismissDirection.endToStart) {
              //       setState(() {
              //         _listaTarefas.removeAt(index);
              //       });
              //       _salvarArquivo();
              //       print("direção end to start");
              //     } else if (direction == DismissDirection.startToEnd) {
              //       print("direção  start to end to");
              //     }
              //   },
              //   direction: DismissDirection.horizontal,
              //   key: Key(_listaTarefas[index].toString() + index.toString()),
              //   child: CheckboxListTile(
              //       title: Text(_listaTarefas[index]["titulo"],
              //           style: const TextStyle(fontSize: 20)),
              //       value: _listaTarefas[index]["realizada"],
              //       onChanged: (valorAlterado) {
              //         setState(() {
              //           _listaTarefas[index]["realizada"] = valorAlterado;
              //         });

              //         _salvarArquivo();
              //       }),
              // );

              // return ListTile(
              //   title: Text(_listaTarefas[index]["titulo"]),
              // );
              //},
            ),
          ),
        ],
      ),
    );
  }
}
