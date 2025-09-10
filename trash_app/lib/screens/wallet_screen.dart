import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:trash_app/screens/request_withdrawal_screen.dart';
import 'package:flutter/services.dart';
import 'package:trash_app/services/auth_service.dart';
import '../constants/app_colors.dart';

// Model untuk Wallet dan Transaksi (Tetap sama)
class Wallet {
  final double balance;
  final List<Transaction> transactions;
  Wallet({required this.balance, required this.transactions});
  factory Wallet.fromJson(Map<String, dynamic> json) {
    var txList = json['transactions'] as List;
    List<Transaction> transactions = txList.map((i) => Transaction.fromJson(i)).toList();
    return Wallet(
      balance: (json['balance'] as num).toDouble(),
      transactions: transactions,
    );
  }
}

class Transaction {
  final String description;
  final double amount;
  final DateTime createdAt;
  final String type;
  Transaction({required this.description, required this.amount, required this.createdAt, required this.type});
  factory Transaction.fromJson(Map<String, dynamic> json) {
    final utcTime = DateTime.parse(json['created_at']);
    return Transaction(
      description: json['description'] ?? 'No description',
      amount: (json['amount'] as num).toDouble(),
      createdAt: utcTime.toLocal(),
      type: json['type'] ?? 'credit',
    );
  }
}

// <<< MODEL BARU UNTUK PENGAJUAN PENDING >>>
class PendingSubmission {
  final String categoryName;
  final double weight;
  final DateTime createdAt;
  final String status;

  PendingSubmission({
    required this.categoryName,
    required this.weight,
    required this.createdAt,
    required this.status,
  });

  factory PendingSubmission.fromJson(Map<String, dynamic> json) {
    DateTime createdAtDate;
    final createdAtData = json['created_at'];

    if (createdAtData is Map<String, dynamic> && createdAtData.containsKey('_seconds')) {
      final seconds = createdAtData['_seconds'] as int;
      createdAtDate = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    } else if (createdAtData is String) {
      createdAtDate = DateTime.parse(createdAtData);
    } else {
      createdAtDate = DateTime.now();
    }

    return PendingSubmission(
      categoryName: json['category_name'] ?? 'No Category',
      weight: (json['weight_in_grams'] as num).toDouble(),
      createdAt: createdAtDate.toLocal(),
      status: json['status'] ?? 'pending',
    );
  }
}


class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final AuthService _authService = AuthService();
  Future<Wallet>? _walletFuture;
  Future<List<PendingSubmission>>? _pendingSubmissionsFuture; // Future baru

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      setState(() {
        _walletFuture = _fetchWallet(userId);
        _pendingSubmissionsFuture = _fetchPendingSubmissions(userId); // Panggil fungsi baru
      });
    }
  }

  Future<Wallet> _fetchWallet(String userId) async {
    final url = Uri.parse('https://trash-api-azure.vercel.app/api/wallet?userId=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Wallet.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 404) {
      return Wallet(balance: 0, transactions: []);
    }
    throw Exception('Failed to load wallet data: ${response.body}');
  }

  // <<< FUNGSI BARU UNTUK MENGAMBIL DATA PENDING >>>
  Future<List<PendingSubmission>> _fetchPendingSubmissions(String userId) async {
    final url = Uri.parse('https://trash-api-azure.vercel.app/api/pending-submissions?userId=$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => PendingSubmission.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load pending submissions');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header (tetap sama)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Dompetku', style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadData)
                ],
              ),
            ),
            
            // Tampilan utama
            Expanded(
              child: FutureBuilder<Wallet>(
                future: _walletFuture,
                builder: (context, walletSnapshot) {
                  if (walletSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (walletSnapshot.hasError) {
                    return Center(child: Text('Error: ${walletSnapshot.error}', style: const TextStyle(color: Colors.white)));
                  }
                  final wallet = walletSnapshot.data ?? Wallet(balance: 0, transactions: []);

                  return Column(
                    children: [
                      // Tampilan Saldo (tetap sama)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF8FD14F), Color(0xFF7BC142)]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Saldo', style: TextStyle(color: Colors.white, fontSize: 16)),
                            const SizedBox(height: 12),
                            Text(currencyFormatter.format(wallet.balance), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.send_to_mobile),
                                label: const Text('Tarik Dana'),
                                onPressed: wallet.balance > 0 ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => RequestWithdrawalScreen(currentBalance: wallet.balance)),
                                  ).then((_) => _loadData());
                                } : null,
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryGreen),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Judul Riwayat
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Icon(Icons.history, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Riwayat', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      
                      // <<< KONTEN RIWAYAT YANG DIMODIFIKASI >>>
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: FutureBuilder<List<PendingSubmission>>(
                            future: _pendingSubmissionsFuture,
                            builder: (context, pendingSnapshot) {
                              if (pendingSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              
                              final pendingList = pendingSnapshot.data ?? [];
                              final transactionList = wallet.transactions;

                              if (pendingList.isEmpty && transactionList.isEmpty) {
                                return const Center(child: Text("Belum ada riwayat.", style: TextStyle(color: Colors.white70)));
                              }
                              
                              // Gabungkan data pending dan transaksi, lalu urutkan berdasarkan tanggal
                              final combinedList = [
                                ...pendingList,
                                ...transactionList,
                              ];
                              combinedList.sort((a, b) {
                                DateTime dateA = a is PendingSubmission ? a.createdAt : (a as Transaction).createdAt;
                                DateTime dateB = b is PendingSubmission ? b.createdAt : (b as Transaction).createdAt;
                                return dateB.compareTo(dateA); // Terbaru di atas
                              });

                              return ListView.builder(
                                itemCount: combinedList.length,
                                itemBuilder: (context, index) {
                                  final item = combinedList[index];

                                  if (item is PendingSubmission) {
                                    // Tampilan untuk item PENDING
                                    return Card(
                                      color: Colors.yellow[100],
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        leading: const Icon(Icons.hourglass_top, color: Colors.orange),
                                        title: Text(item.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text('${item.weight} gram'),
                                        trailing: const Text(
                                          'Pending',
                                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    );
                                  } else if (item is Transaction) {
                                    // Tampilan untuk TRANSAKSI (yang sudah ada)
                                    final tx = item;
                                    final isCredit = tx.type == 'credit';
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        leading: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: isCredit ? Colors.green : Colors.red),
                                        title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(tx.createdAt)),
                                        trailing: Text(
                                          '${isCredit ? '+' : '-'} ${currencyFormatter.format(tx.amount)}',
                                          style: TextStyle(color: isCredit ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink(); // Fallback
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}