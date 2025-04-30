import 'package:flutter/material.dart';

class LoyaltyCard {
  final String id;
  final String name;
  final String cardNumber;
  final String? barcode;
  final String? qrCode;
  final DateTime? expiryDate;
  final String? notes;
  final String? imagePath;
  final Color? cardColor;
  final DateTime createdAt;
  final DateTime updatedAt;

  LoyaltyCard({
    required this.id,
    required this.name,
    required this.cardNumber,
    this.barcode,
    this.qrCode,
    this.expiryDate,
    this.notes,
    this.imagePath,
    this.cardColor,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cardNumber': cardNumber,
      'barcode': barcode,
      'qrCode': qrCode,
      'expiryDate': expiryDate?.toIso8601String(),
      'notes': notes,
      'imagePath': imagePath,
      'cardColor': cardColor?.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'],
      name: json['name'],
      cardNumber: json['cardNumber'],
      barcode: json['barcode'],
      qrCode: json['qrCode'],
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      notes: json['notes'],
      imagePath: json['imagePath'],
      cardColor: json['cardColor'] != null ? Color(json['cardColor']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  LoyaltyCard copyWith({
    String? id,
    String? name,
    String? cardNumber,
    String? barcode,
    String? qrCode,
    DateTime? expiryDate,
    String? notes,
    String? imagePath,
    Color? cardColor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LoyaltyCard(
      id: id ?? this.id,
      name: name ?? this.name,
      cardNumber: cardNumber ?? this.cardNumber,
      barcode: barcode ?? this.barcode,
      qrCode: qrCode ?? this.qrCode,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      cardColor: cardColor ?? this.cardColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 