import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  String _idProduto = '';

  String get idProduto => _idProduto;

  void atualizaIdProduto(String novoIdProduto) {
    _idProduto = novoIdProduto;
    notifyListeners();
  }
}
