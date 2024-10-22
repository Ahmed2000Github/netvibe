import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:netvibe/services/network_speed.dart';

class ShowSpeed with ChangeNotifier {
  bool _isOpen = false;
  final networkSevices = GetIt.I<NetworkSevices>();
  bool get isOpen => _isOpen;

  Future<void> switchWidget() async {
    _isOpen = !_isOpen;
    notifyListeners();
  }
}
