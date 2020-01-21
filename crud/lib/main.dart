import 'package:flutter/material.dart';

import 'control/databaseHelper.dart';
import 'models/contato.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Contatos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        
        primarySwatch: Colors.red,
      ),
      home: ListaDeContatos(title: 'Lista de Contatos'),
    );
  }
}

class ListaDeContatos extends StatefulWidget {
  ListaDeContatos({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ListaDeContatosState createState() => _ListaDeContatosState();
}

class _ListaDeContatosState extends State<ListaDeContatos> {
  final _telefone = TextEditingController();
  final _operadora = TextEditingController();
  final _nome = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  var maskFormatter = new MaskTextInputFormatter(mask: '(##) #####-####', filter: { "#": RegExp(r'[0-9]') });

  static DatabaseHelper banco;

  int tamanhoDaLista = 0;
  List<Contato> listaDeContatos;

  @override
  void initState(){
    banco = new DatabaseHelper();
    banco.inicializaBanco();
    Future<List<Contato>> listaDeContatos = banco.getListaDeContato();
    listaDeContatos.then((novaListaDeContatos){
      setState((){
        this.listaDeContatos = novaListaDeContatos;
        this.tamanhoDaLista = novaListaDeContatos.length;
      });
    });
  }
  _carregarLista(){
    banco = new DatabaseHelper();
    banco.inicializaBanco();
    Future<List<Contato>> noteListFuture = banco.getListaDeContato();
    noteListFuture.then((novaListaDeContatos) {
        setState(() {
          this.listaDeContatos = novaListaDeContatos;
          this.tamanhoDaLista = novaListaDeContatos.length; 
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.red,
      ),
      body: _listaDeContatos(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _adicionarContato();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.redAccent,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _removerItem(Contato contato, int index) {
    setState(() {
      listaDeContatos = List.from(listaDeContatos)..removeAt(index);
      banco.apagarContato(contato.id);    
      tamanhoDaLista = tamanhoDaLista - 1;
    });
  }

  void _adicionarContato() {
    _telefone.text = '';
    _operadora.text = '';
    _nome.text = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: AlertDialog(  
            title: new Text("Novo Contato"),
            content: new Container(
              child: new Form(
                key: _formKey,
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    campoDeNome(),
                    Divider(
                      color: Colors.transparent,
                      height: 20.0,
                    ),
                    campoDeTelefone(),
                    Divider(
                      color: Colors.transparent,
                      height: 20.0,
                    ),
                    campoDeOperadora()
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              new FlatButton(  
                child: new Text("Salvar"),
                onPressed: () {
                  Contato _contato;
                  if (_formKey.currentState.validate()) {
                    _contato = new Contato(_nome.text, _telefone.text, _operadora.text);
                    banco.inserirContato(_contato);
      
                    _carregarLista();
                    _formKey.currentState.reset();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          )
        );
      },
    );
  }

  void _atualizarContato(Contato contato) {
    _telefone.text = contato.telefone;
    _operadora.text = contato.operadora;
    _nome.text = contato.nome;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          physics: BouncingScrollPhysics(), 
          child: AlertDialog(
            title: new Text("Atualizar Contato"),
            content: new Container(
              child: new Form(
                key: _formKey,
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    campoDeNome(),
                    Divider(
                      color: Colors.transparent,
                      height: 20.0,
                    ),
                    campoDeTelefone(),
                    Divider(
                      color: Colors.transparent,
                      height: 20.0,
                    ),
                    campoDeOperadora(),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Atualizar"),
                onPressed: () {
                  Contato _contato;
                
                  if (_formKey.currentState.validate()) {             // crio um novo objeto  passando seus atributos
                    _contato = new Contato(_nome.text, _telefone.text, _operadora.text);
    
                    banco.atualizarContato(_contato, contato.id);
        
                    _carregarLista();
          
                    _formKey.currentState.reset();
            
                    // retiro o alerta da tela
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          )
        );
      },
    );
  }
  
  Widget campoDeNome() {
    return new TextFormField(
      controller: _nome,
      keyboardType: TextInputType.text,
      validator: (valor) {
          if (valor.isEmpty && valor.length == 0) {
            return "Campo Obrigatório";
          }
      },
      decoration: new InputDecoration(
        hintText: 'Nome',
        labelText: 'Nome completo',
        border: OutlineInputBorder(),
      ),
    );
  }
  
  Widget campoDeTelefone() {
    return new TextFormField(  
      controller: _telefone,
      validator: (valor) {
          if (valor.isEmpty && valor.length == 0) {
              return "Campo Obrigatório";
          }
      },
      keyboardType: TextInputType.number,
      inputFormatters: [maskFormatter],
      decoration: new InputDecoration(
            hintText: 'Telefone',
            labelText: 'Telefone',
            border: OutlineInputBorder(),
      ),
    );
  }

  Widget campoDeOperadora() {
    return new TextFormField(  
      controller: _operadora,
      validator: (valor) {
        if (valor.isEmpty && valor.length == 0 || (valor.toLowerCase() != 'claro' &&
        valor.toLowerCase() != 'oi' && valor.toLowerCase() != 'vivo' && valor.toLowerCase() != 'tim') ) {
            return "Operadora inválida";
        }
      },
      decoration: new InputDecoration(
            hintText: 'Operadora',
            labelText: 'Operadora',
            border: OutlineInputBorder(),
      ),
    );
  }

  Widget _listaDeContatos() {
    String subtitle;
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: tamanhoDaLista,
      itemBuilder: (context, index) {  
        if(listaDeContatos[index].telefone == null){
          subtitle = "Número não cadastrado";
        }else{
          subtitle = listaDeContatos[index].telefone;
        }
        return Dismissible(
          child: ListTile(
            title: Text(listaDeContatos[index].nome),

            subtitle: Text(subtitle),
          
            leading: CircleAvatar(
              child: Text(listaDeContatos[index].nome[0]),
            ),
            onTap: ()=> _atualizarContato(listaDeContatos[index]),
          ),
          // onLongPress: () => _atualizarContato(listaDeContatos[index]),
          // onTap: () => _removerItem(listaDeContatos[0], index),
          key: Key(UniqueKey().toString()),
            onDismissed: (direction){
              _removerItem(listaDeContatos[0], index);
            },
        );
      },
    );
  }
}
