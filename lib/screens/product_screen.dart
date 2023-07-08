import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senacstorageapp/services/loading_service.dart';

import '../services/product_provider.dart';
import '../widget/drawer.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  Widget build(BuildContext context) {
    // SELECIONA OS PRODUTOS
    Query<Map<String, dynamic>> produtos = FirebaseFirestore.instance
        .collection('produtos')
        // .where('ativo', isEqualTo: true);
        .orderBy('ds_produto');

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              // ATUALIZA O PRODUTO NO PROVIDER ProductProvider
              Provider.of<ProductProvider>(context, listen: false)
                  .atualizaIdProduto('');

              //NAVEGA PARA A TELA DE CADASTRO
              Navigator.of(context).pushReplacementNamed('/productsReg');
            },
            icon: const Icon(Icons.add),
          ),
        ],
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        title: const Text(
          'Produtos',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: produtos.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Carregando();
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Text('');
          }

          return SingleChildScrollView(
            child: SizedBox(
              height: double.maxFinite,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: snapshot.data!.docs.map(
                    (produtos) {
                      return Card(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                                onPressed: () {
                                  // ATUALIZA O PRODUTO NO PROVIDER ProductProvider
                                  Provider.of<ProductProvider>(context,
                                          listen: false)
                                      .atualizaIdProduto(produtos.id);

                                  //NAVEGA PARA A TELA DE CADASTRO
                                  Navigator.of(context)
                                      .pushReplacementNamed('/productsReg');
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                )),
                            Text(
                              produtos['ds_produto'],
                              style: const TextStyle(
                                fontSize: 20,
                                // fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Localizacao extends StatefulWidget {
  const Localizacao({super.key});

  @override
  State<Localizacao> createState() => _LocalizacaoState();
}

class _LocalizacaoState extends State<Localizacao> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: futureBusca('11'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Carregando();
            }

            // if (snapshot.data.docs.isEmpty) {
            //   return const Text('');
            // }

            return Text(snapshot.data.toString());
          },
        ),
      ],
    );
  }

  Future<String> futureBusca(String id) async {
    await FirebaseFirestore.instance
        .collection('mapa_estoque')
        .doc(id)
        .get()
        .then((doc) {
      return '${doc.get('rua')}, ${doc.get('numero')} (Mapa ${doc.get(id)})';
    });
    return '';
  }
}
