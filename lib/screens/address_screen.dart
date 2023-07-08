import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/loading_service.dart';
import '../widget/drawer.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  TextEditingController mapaController = TextEditingController();
  TextEditingController ruaController = TextEditingController();
  TextEditingController numeroController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        title: const Text(
          'Layout do Estoque',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('mapa_estoque')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('O Mapa do Estoque está vazio.');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Carregando();
                  }

                  return SizedBox(
                    height: 320,
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
                              mapaController.text = snap.id;
                              buscar();
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(6.0),
                            color:
                                snap['rua'] == '' ? Colors.green : Colors.amber,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20.0),
              Column(
                children: [
                  // NOME DA RUA
                  TextFormField(
                    controller: ruaController,
                    maxLength: 40,
                    decoration: InputDecoration(
                      label: const Text('Nome da Rua'),
                      labelStyle: const TextStyle(fontSize: 16),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 20.0),

                  // NÚMERO DA RUA
                  TextFormField(
                    controller: numeroController,
                    maxLength: 10,
                    decoration: InputDecoration(
                      label: const Text('Número'),
                      labelStyle: const TextStyle(fontSize: 16),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 20.0),

                  // BOTÃO GRAVAR
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
                      if (mapaController.text != '') {
                        salvar();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Selecione um local no mapa.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  buscar() async {
    try {
      FirebaseFirestore.instance
          .collection('mapa_estoque')
          .doc(mapaController.text)
          .get()
          .then((doc) {
        ruaController.text = doc.get('rua');
        numeroController.text = doc.get('numero');
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

  Future salvar() async {
    try {
      FirebaseFirestore.instance
          .collection('mapa_estoque')
          .doc(mapaController.text)
          .set({
        'rua': ruaController.text,
        'numero': numeroController.text,
      });

      mapaController.text = '';
      ruaController.text = '';
      numeroController.text = '';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados armazenados com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
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
