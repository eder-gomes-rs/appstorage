import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:senacstorageapp/services/loading_service.dart';
import '../services/auth_service.dart';
import '../widget/drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String idMapa = '';
  String rua = '';
  String numero = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        title: const Text(
          'Localizar Produtos',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --------------------------------------
            // MONTA O LAYOUT DO ESTOQUE
            // --------------------------------------

            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('mapa_estoque')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Carregando();
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Text('');
                }

                return SizedBox(
                  height: 330,
                  child: GridView.builder(
                    itemCount: 20,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5),
                    itemBuilder: (context, index) {
                      DocumentSnapshot snap = snapshot.data!.docs[index];

                      return InkWell(
                        onTap: () {
                          setState(() {
                            idMapa = snap.id;
                            buscar();
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color:
                                snap['rua'] == '' ? Colors.green : Colors.amber,
                            border: Border.all(
                              width: idMapa == snap.id ? 5 : 0,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // --------------------------------------
            // EXIBE A DESCRIÇÃO DO LOCAL SELECIONADO
            // --------------------------------------
            const SizedBox(height: 20.0),

            Text(
              rua == '' ? '' : 'Rua: $rua',
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            Text(
              numero == '' ? '' : 'Número: $numero',
              style: const TextStyle(
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 12.0),

            // -------------------------------------------
            // GERA LISTA DE PRODUTOS DO LOCAL SELECIONADO
            // -------------------------------------------

            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('produtos')
                  .where('id_estoque', isEqualTo: idMapa)
                  //.orderBy('ds_produto')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Carregando();
                }

                if (snapshot.data!.docs.isEmpty || !snapshot.hasData) {
                  return const Text('');
                }

                return SizedBox(
                  height: double.maxFinite,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: snapshot.data!.docs.map(
                        (produtos) {
                          return Card(
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                produtos['ds_produto'],
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  buscar() async {
    try {
      FirebaseFirestore.instance
          .collection('mapa_estoque')
          .doc(idMapa)
          .get()
          .then((doc) {
        setState(() {
          rua = doc.get('rua');
          numero = doc.get('numero');
        });
      });
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.mensagem),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
