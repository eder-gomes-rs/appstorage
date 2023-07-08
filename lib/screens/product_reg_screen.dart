import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senacstorageapp/services/product_provider.dart';

import '../services/loading_service.dart';
import '../widget/drawer.dart';

class ProductRegistrationScreen extends StatefulWidget {
  const ProductRegistrationScreen({super.key});

  @override
  State<ProductRegistrationScreen> createState() =>
      _ProductRegistrationScreenState();
}

class _ProductRegistrationScreenState extends State<ProductRegistrationScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController dsProdutoController = TextEditingController();
  TextEditingController idEstoqueController = TextEditingController();
  TextEditingController dsEstoqueController = TextEditingController();

  bool carregandoPagina = true;
  dynamic opcaoProduto;

  @override
  Widget build(BuildContext context) {
    // BUSCA O ID DO PRODUTO NO PROVIDER ProductProvider
    final idProduto =
        Provider.of<ProductProvider>(context, listen: false).idProduto;

    // BUSCA OS DADOS DO PRODUTO QUANDO ESTIVER CARREGANDO A PÁGINA
    if (carregandoPagina && idProduto != '') {
      _buscar(idProduto);
      carregandoPagina = false;
    }

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        title: const Text(
          'Cadastro de Produtos',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------
              // DESCRIÇÃO DO PRODUTO
              // ------------------------
              TextFormField(
                controller: dsProdutoController,
                decoration: const InputDecoration(
                  labelText: 'Produto',
                  labelStyle: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                autocorrect: false,
                validator: (String? conteudo) {
                  conteudo = dsProdutoController.text.trim();

                  if (conteudo.isEmpty) {
                    return 'Descrição do Produto é obrigatório.';
                    // Verifica se foram digitadas duas palavras (nome completo)
                    //} else if (name.trim().split(' ').length <= 1) {
                    //  return 'Preencha seu nome completo.';
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: 20),

              // -----------------------------------
              // LIST COM OS ENDEREÇOS DO ESTOQUE
              // -----------------------------------
              const Text(
                'Estoque',
                style: TextStyle(color: Colors.blue, fontSize: 14.0),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('mapa_estoque')
                    .where('rua', isNotEqualTo: '')
                    .orderBy('rua')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Carregando();
                  }
                  // MONTA A LISTA DE OPÇÕES
                  List<DropdownMenuItem> itensLista = [];

                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    DocumentSnapshot snap = snapshot.data!.docs[i];

                    itensLista.add(
                      DropdownMenuItem(
                        value: snap.id,
                        child: Text(
                            'Rua: ${snap['rua']}, Número: ${snap['numero']}'),
                      ),
                    );
                  }
                  // DROPDOWN COM A RELAÇÃO DE ENDEREÇOS DO ESTOQUE
                  return DropdownButton<dynamic>(
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    items: itensLista,
                    hint: const Text('Escolha um endereço'),
                    value: opcaoProduto,
                    onChanged: (escolha) {
                      setState(() {
                        opcaoProduto = escolha;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              Row(
                //mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.task_alt, color: Colors.white),
                    label: const Text("Salvar"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(12.0),
                      backgroundColor: Colors.green,
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        _gravar(idProduto);
                      } else {
                        null;
                      }
                    },
                  ),
                  const SizedBox(width: 20.0),
                  TextButton.icon(
                    icon:
                        const Icon(Icons.circle_outlined, color: Colors.white),
                    label: const Text("Voltar"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(12.0),
                      backgroundColor: Colors.amber,
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      // NAVEGA PARA A TELA ANTERIOR
                      Navigator.of(context).pushReplacementNamed('/products');
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _buscar(String idProduto) async {
    try {
      FirebaseFirestore.instance
          .collection('produtos')
          .doc(idProduto)
          .get()
          .then((doc) {
        dsProdutoController.text = doc.get('ds_produto');

        setState(() {
          opcaoProduto = doc.get('id_estoque');
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  _gravar(String idProduto) async {
    if (idProduto != '') {
      // ALTERAÇÃO DO CADASTRO DE PRODUTOS
      FirebaseFirestore.instance.collection('produtos').doc(idProduto).update(
        {
          'ds_produto': dsProdutoController.text,
          'id_estoque': opcaoProduto,
          // 'ds_estoque': dsEstoqueController,
        },
      );
    } else {
      // INCLUSÃO NO CADASTRO DE PRODUTOS
      CollectionReference produto =
          FirebaseFirestore.instance.collection('produtos');

      produto.add({
        'ds_produto': dsProdutoController.text,
        'id_estoque': opcaoProduto,
        // 'ds_estoque': dsEstoqueController,
      });
    }

    // NAVEGA PARA A TELA ANTERIOR
    Navigator.of(context).pushReplacementNamed('/products');

    // AVISO DE GRAVAÇÃO
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Produto salvo com sucesso.'),
        backgroundColor: Color.fromARGB(255, 54, 136, 56),
      ),
    );
  }
}
