import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../models/loyalty_card.dart';

class CardStorageService {
  static const String _cardsKey = 'loyalty_cards';
  static const String _encryptionKey = 'your-32-char-encryption-key-here';
  
  late SharedPreferences _prefs;
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;

  CardStorageService() {
    final key = encrypt.Key.fromUtf8(_encryptionKey);
    _iv = encrypt.IV.fromLength(16);
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<LoyaltyCard>> getCards() async {
    final encryptedCards = _prefs.getString(_cardsKey);
    if (encryptedCards == null) return [];

    try {
      final decrypted = _encrypter.decrypt64(encryptedCards, iv: _iv);
      final List<dynamic> jsonList = json.decode(decrypted);
      return jsonList.map((json) => LoyaltyCard.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveCard(LoyaltyCard card) async {
    final cards = await getCards();
    final index = cards.indexWhere((c) => c.id == card.id);
    
    if (index >= 0) {
      cards[index] = card;
    } else {
      cards.add(card);
    }

    await _saveCards(cards);
  }

  Future<void> deleteCard(String cardId) async {
    final cards = await getCards();
    cards.removeWhere((card) => card.id == cardId);
    await _saveCards(cards);
  }

  Future<void> _saveCards(List<LoyaltyCard> cards) async {
    final jsonList = cards.map((card) => card.toJson()).toList();
    final jsonString = json.encode(jsonList);
    final encrypted = _encrypter.encrypt(jsonString, iv: _iv);
    await _prefs.setString(_cardsKey, encrypted.base64);
  }
} 