import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/loyalty_card.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isInitialized = false;

  // Get current user ID
  String? get userId => _auth.currentUser?.uid;

  // Initialize Firebase
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    debugPrint('Initializing Firebase Service');
    try {
      // Check if user is signed in
      User? user = _auth.currentUser;
      debugPrint('Current user: ${user?.uid ?? 'null'}');
      
      if (user == null) {
        debugPrint('No user signed in, attempting anonymous sign in');
        final userCredential = await _auth.signInAnonymously();
        user = userCredential.user;
        debugPrint('Anonymous sign in successful: ${user?.uid}');
      }
      
      _isInitialized = true;
      debugPrint('Firebase Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase Service: $e');
      rethrow;
    }
  }

  // Add a new card
  Future<void> addCard(LoyaltyCard card) async {
    final String? currentUserId = userId;
    if (currentUserId == null) {
      debugPrint('No user signed in');
      throw Exception('No user signed in');
    }

    try {
      debugPrint('Adding card for user: $currentUserId');
      // Upload image if exists
      String? imageUrl;
      if (card.imagePath != null) {
        final file = File(card.imagePath!);
        final ref = _storage.ref().child('cards/$currentUserId/${card.id}.jpg');
        await ref.putFile(file);
        imageUrl = await ref.getDownloadURL();
        debugPrint('Image uploaded successfully: $imageUrl');
      }

      // Create card document
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('cards')
          .doc(card.id)
          .set({
        'id': card.id,
        'name': card.name,
        'cardNumber': card.cardNumber,
        'barcode': card.barcode,
        'expiryDate': card.expiryDate?.toIso8601String(),
        'notes': card.notes,
        'imageUrl': imageUrl,
        'cardColor': card.cardColor?.value,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Card added successfully');
    } catch (e) {
      debugPrint('Error adding card: $e');
      rethrow;
    }
  }

  // Get all cards
  Stream<List<LoyaltyCard>> getCards() {
    final String? currentUserId = userId;
    if (currentUserId == null) {
      debugPrint('No user signed in');
      return Stream.value([]);
    }

    debugPrint('Getting cards for user: $currentUserId');
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('cards')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final cards = snapshot.docs.map((doc) {
        final data = doc.data();
        final card = LoyaltyCard(
          id: data['id'] ?? doc.id,
          name: data['name'] ?? '',
          cardNumber: data['cardNumber'] ?? '',
          barcode: data['barcode'],
          expiryDate: data['expiryDate'] != null 
              ? DateTime.parse(data['expiryDate']) 
              : null,
          notes: data['notes'],
          imagePath: data['imageUrl'],
          cardColor: data['cardColor'] != null 
              ? Color(data['cardColor']) 
              : null,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
        return card;
      }).toList();
      
      debugPrint('Retrieved ${cards.length} cards');
      return cards;
    });
  }

  // Update a card
  Future<void> updateCard(LoyaltyCard card) async {
    final String? currentUserId = userId;
    if (currentUserId == null) {
      debugPrint('No user signed in');
      throw Exception('No user signed in');
    }

    try {
      debugPrint('Updating card: ${card.id} for user: $currentUserId');
      // Handle image update
      String? imageUrl = card.imagePath;
      if (card.imagePath != null && !card.imagePath!.startsWith('http')) {
        final file = File(card.imagePath!);
        final ref = _storage.ref().child('cards/$currentUserId/${card.id}.jpg');
        await ref.putFile(file);
        imageUrl = await ref.getDownloadURL();
        debugPrint('Image updated successfully: $imageUrl');
      }

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('cards')
          .doc(card.id)
          .update({
        'name': card.name,
        'cardNumber': card.cardNumber,
        'barcode': card.barcode,
        'expiryDate': card.expiryDate?.toIso8601String(),
        'notes': card.notes,
        'imageUrl': imageUrl,
        'cardColor': card.cardColor?.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Card updated successfully');
    } catch (e) {
      debugPrint('Error updating card: $e');
      rethrow;
    }
  }

  // Delete a card
  Future<void> deleteCard(String cardId) async {
    final String? currentUserId = userId;
    if (currentUserId == null) {
      debugPrint('No user signed in');
      throw Exception('No user signed in');
    }

    try {
      debugPrint('Deleting card: $cardId for user: $currentUserId');
      // Delete image from storage if exists
      final cardDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('cards')
          .doc(cardId)
          .get();
      
      if (cardDoc.exists && cardDoc.data()?['imageUrl'] != null) {
        final imageUrl = cardDoc.data()!['imageUrl'];
        if (imageUrl != null) {
          await _storage.refFromURL(imageUrl).delete();
          debugPrint('Card image deleted successfully');
        }
      }

      // Delete card document
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('cards')
          .doc(cardId)
          .delete();
      debugPrint('Card deleted successfully');
    } catch (e) {
      debugPrint('Error deleting card: $e');
      rethrow;
    }
  }
} 