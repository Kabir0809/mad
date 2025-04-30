import 'package:flutter/material.dart';
import '../models/loyalty_card.dart';
import '../services/card_storage_service.dart';

class CardProvider with ChangeNotifier {
  final CardStorageService _storageService = CardStorageService();
  List<LoyaltyCard> _cards = [];
  bool _isLoading = false;

  List<LoyaltyCard> get cards => _cards;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    await _storageService.init();
    await loadCards();
  }

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cards = await _storageService.getCards();
    } catch (e) {
      debugPrint('Error loading cards: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCard(LoyaltyCard card) async {
    try {
      await _storageService.saveCard(card);
      await loadCards();
    } catch (e) {
      debugPrint('Error adding card: $e');
    }
  }

  Future<void> updateCard(LoyaltyCard card) async {
    try {
      await _storageService.saveCard(card);
      await loadCards();
    } catch (e) {
      debugPrint('Error updating card: $e');
    }
  }

  Future<void> deleteCard(String cardId) async {
    try {
      await _storageService.deleteCard(cardId);
      await loadCards();
    } catch (e) {
      debugPrint('Error deleting card: $e');
    }
  }
} 