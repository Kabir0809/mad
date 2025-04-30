import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/loyalty_card.dart';
import '../services/firebase_service.dart';

class CardProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<LoyaltyCard> _cards = [];
  bool _isLoading = true;

  List<LoyaltyCard> get cards => _cards;
  bool get isLoading => _isLoading;

  CardProvider() {
    debugPrint('CardProvider initialized');
    _initialize();
  }

  Future<void> _initialize() async {
    debugPrint('Initializing CardProvider');
    try {
      await _firebaseService.initialize();
      debugPrint('Firebase initialized in CardProvider');
      await loadCards();
    } catch (e) {
      debugPrint('Error initializing CardProvider: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      debugPrint('Loading cards from Firebase');
      _firebaseService.getCards().listen(
        (cards) {
          debugPrint('Received ${cards.length} cards from Firebase');
          _cards = cards;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Error loading cards: $error');
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error in loadCards: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCard(LoyaltyCard card) async {
    try {
      await _firebaseService.addCard(card);
      debugPrint('Card added successfully');
    } catch (e) {
      debugPrint('Error adding card: $e');
      rethrow;
    }
  }

  Future<void> updateCard(LoyaltyCard card) async {
    try {
      await _firebaseService.updateCard(card);
      debugPrint('Card updated successfully');
    } catch (e) {
      debugPrint('Error updating card: $e');
      rethrow;
    }
  }

  Future<void> deleteCard(String cardId) async {
    try {
      await _firebaseService.deleteCard(cardId);
      debugPrint('Card deleted successfully');
    } catch (e) {
      debugPrint('Error deleting card: $e');
      rethrow;
    }
  }
} 