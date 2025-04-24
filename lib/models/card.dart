import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum CardRarity { common, uncommon, rare, epic, legendary }

class SynergyCard {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final CardRarity rarity;
  final Map<String, dynamic> effects;
  final String source; // Dungeon, Raid, etc.

  SynergyCard({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rarity,
    required this.effects,
    required this.source,
  });

  factory SynergyCard.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SynergyCard(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rarity: _parseRarity(data['rarity'] ?? 'common'),
      effects: data['effects'] ?? {},
      source: data['source'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rarity': _rarityToString(rarity),
      'effects': effects,
      'source': source,
    };
  }

  static CardRarity _parseRarity(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return CardRarity.common;
      case 'uncommon':
        return CardRarity.uncommon;
      case 'rare':
        return CardRarity.rare;
      case 'epic':
        return CardRarity.epic;
      case 'legendary':
        return CardRarity.legendary;
      default:
        return CardRarity.common;
    }
  }

  static String _rarityToString(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.common:
        return 'common';
      case CardRarity.uncommon:
        return 'uncommon';
      case CardRarity.rare:
        return 'rare';
      case CardRarity.epic:
        return 'epic';
      case CardRarity.legendary:
        return 'legendary';
    }
  }

  // Helper to get color based on rarity
  static getRarityColor(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.common:
        return const Color(0xFF9E9E9E); // Grey
      case CardRarity.uncommon:
        return const Color(0xFF4CAF50); // Green
      case CardRarity.rare:
        return const Color(0xFF2196F3); // Blue
      case CardRarity.epic:
        return const Color(0xFF9C27B0); // Purple
      case CardRarity.legendary:
        return const Color(0xFFFF9800); // Orange
    }
  }
}
