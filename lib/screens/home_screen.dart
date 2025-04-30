import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/card_provider.dart';
import '../models/loyalty_card.dart';
import 'add_card_screen.dart';
import 'card_detail_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CardProvider>(context, listen: false).loadCards();
    });
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Loyalty Cards',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Consumer<CardProvider>(
        builder: (context, cardProvider, child) {
          if (cardProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (cardProvider.cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.credit_card,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Loyalty Cards',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('Add your first loyalty card to get started'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Card'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => cardProvider.loadCards(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cardProvider.cards.length,
              itemBuilder: (context, index) {
                final card = cardProvider.cards[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: card.cardColor ?? Theme.of(context).colorScheme.primary,
                      child: Text(
                        card.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      card.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(card.cardNumber),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/detail',
                      arguments: card,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
    );
  }
} 