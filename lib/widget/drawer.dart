import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  //final tempo = const Duration(hours: 0, minutes: 0, seconds: 1);

  @override
  Widget build(BuildContext context) {
    // int indiceBottomBar = Provider.of<NavegacaoProvider>(context).idBotao;
    return Drawer(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 50.0, 24.0, 24.0),
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  child: Image.asset('img/logo.png'),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Text(
                  'Storage App',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          itemDrawer(context, const Icon(Icons.home), 'Inicio', '/home'),
          itemDrawer(context, const Icon(Icons.dataset_outlined),
              'Layout do Estoque', '/address'),
          itemDrawer(
              context, const Icon(Icons.location_on), 'Produtos', '/products'),
          itemDrawer(context, const Icon(Icons.logout), 'Sair', '/'),
        ],
      ),
    );
  }

  itemDrawer(context, Icon icone, String label, String pagina) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black, width: 0.2))),
      child: ListTile(
        leading: icone,
        iconColor: Colors.blue,
        title: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
        textColor: Colors.black87,
        onTap: () {
          Navigator.of(context).pushReplacementNamed(pagina);
        },
      ),
    );
  }
}
