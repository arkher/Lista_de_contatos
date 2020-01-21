class Contato {
  String nome;
  String telefone;
  String operadora;
  int id;

  Contato(this.nome, this.telefone, this.operadora);

  Map<String, dynamic> toMap(){
    var map = Map<String, dynamic>();
    if(id!=null){
      map['id'] = id;

    }
    map['nome'] = nome;
    map['telefone'] = telefone;
    map['operadora'] = operadora;

    return map;
  }

  Contato.fromMapObject(Map<String, dynamic> map){
    this.id = map['id'];
    this.nome = map['nome'];
    this.telefone = map['telefone'];
    this.operadora = map['operadora'];

  }

}