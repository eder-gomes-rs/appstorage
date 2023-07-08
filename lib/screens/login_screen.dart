import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../models/navigator_provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    emailController.text = 'admin@storage.com';
    senhaController.text = '123123';

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: formKey,
            // autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --------------------------------------
                // LOGO E DESCRIÇÃO
                // --------------------------------------

                const SizedBox(height: 100.0),

                SizedBox(
                  height: 150,
                  child: Image.asset('img/logo.png'),
                ),

                const Text(
                  'Storage App',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 60.0),

                // --------------------------------------
                // LOGIN (E-MAIL)
                // --------------------------------------
                TextFormField(
                  controller: emailController,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Campo E-mail é obrigatório.';
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                const SizedBox(height: 20.0),

                // --------------------------------------
                // SENHA
                // --------------------------------------
                TextFormField(
                  controller: senhaController,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Campo Senha é obrigatório.';
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.left,
                  obscureText: true,
                  obscuringCharacter: '*',
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                const SizedBox(height: 20.0),

                // --------------------------------------
                // BOTÃO ACESSAR
                // --------------------------------------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        logar();
                        // Define que a BottomBar iniciará na segunda opção (calculadora), índice 1
                        // Provider.of<NavegacaoProvider>(context, listen: false)
                        //     .atualizaIdBotao(1);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      fixedSize: const Size.fromHeight(60.0),
                    ),
                    child: const Text('Entrar'),
                  ),
                ),

                const SizedBox(height: 20.0),

                // --------------------------------------
                // BOTÃO CADASTRAR
                // --------------------------------------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                      fixedSize: const Size.fromHeight(60.0),
                      backgroundColor: const Color.fromARGB(255, 205, 232, 255),
                    ),
                    child: const Text('Cadastrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  logar() async {
    setState(() => loading = true);

    try {
      await context
          .read<AuthService>()
          .logar(emailController.text, senhaController.text);

      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed('/home');
    } on AuthException catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.mensagem),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
