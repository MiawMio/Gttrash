import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

// Model untuk data riwayat penyetujuan setoran
class SubmissionHistory {
  final String userName;
  final String categoryName;
  final double weight;
  final String status;
  final DateTime processedAt;

  SubmissionHistory({
    required this.userName,
    required this.categoryName,
    required this.weight,
    required this.status,
    required this.processedAt,
  });

  factory SubmissionHistory.fromJson(Map<String, dynamic> json) {
    // Logika ini sudah ada sebelumnya dan seharusnya sudah benar
    DateTime processedAtDate;
    final processedAtData = json['processed_at'];

    if (processedAtData is Map<String, dynamic>) {
      final seconds = processedAtData['_seconds'] as int;
      processedAtDate = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    } else if (processedAtData is String) {
      processedAtDate = DateTime.parse(processedAtData);
    } else {
      processedAtDate = DateTime.now();
    }

    return SubmissionHistory(
      userName: json['user_name'] ?? 'Unknown User',
      categoryName: json['category_name'] ?? 'No Category',
      weight: (json['weight_in_grams'] as num).toDouble(),
      status: json['status'] ?? 'unknown',
      processedAt: processedAtDate.toLocal(),
    );
  }
}

// Model untuk data riwayat penarikan dana
class WithdrawalHistory {
  final String userName;
  final double amount;
  final String status;
  final DateTime processedAt;

  WithdrawalHistory({
    required this.userName,
    required this.amount,
    required this.status,
    required this.processedAt,
  });

  // <<< KODE YANG DIPERBAIKI ADA DI SINI >>>
  factory WithdrawalHistory.fromJson(Map<String, dynamic> json) {
    DateTime processedAtDate;
    final processedAtData = json['processed_at'];

    if (processedAtData is Map<String, dynamic> && processedAtData.containsKey('_seconds')) {
      // Jika data adalah Map dari Firestore Timestamp, konversi dari seconds
      final seconds = processedAtData['_seconds'] as int;
      processedAtDate = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    } else if (processedAtData is String) {
      // Jika data adalah String (untuk jaga-jaga)
      processedAtDate = DateTime.parse(processedAtData);
    } else {
      // Fallback jika data tidak ada atau formatnya tidak dikenal
      processedAtDate = DateTime.now();
    }

    return WithdrawalHistory(
      userName: json['user_name'] ?? 'Unknown User',
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] ?? 'unknown',
      processedAt: processedAtDate.toLocal(), // Konversi ke waktu lokal perangkat
    );
  }
}


class AdminHistoryScreen extends StatefulWidget {
  const AdminHistoryScreen({super.key});

  @override
  State<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends State<AdminHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<SubmissionHistory>> _submissionHistoryFuture;
  late Future<List<WithdrawalHistory>> _withdrawalHistoryFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _submissionHistoryFuture = _fetchSubmissionHistory();
    _withdrawalHistoryFuture = _fetchWithdrawalHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil riwayat setoran
  Future<List<SubmissionHistory>> _fetchSubmissionHistory() async {
    final response = await http.get(Uri.parse('https://trash-api-azure.vercel.app/api/history'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => SubmissionHistory.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load submission history');
    }
  }

  // Fungsi untuk mengambil riwayat penarikan
  Future<List<WithdrawalHistory>> _fetchWithdrawalHistory() async {
    final response = await http.get(Uri.parse('https://trash-api-azure.vercel.app/api/withdrawal-history'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => WithdrawalHistory.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load withdrawal history');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
        ),
        title: const Text('History', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.primaryGreen,
          tabs: const [
            Tab(text: 'Penyetujuan'),
            Tab(text: 'Penarikan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSubmissionHistoryList(),
          _buildWithdrawalHistoryList(),
        ],
      ),
    );
  }

  // Widget untuk menampilkan daftar riwayat penyetujuan
  Widget _buildSubmissionHistoryList() {
    return FutureBuilder<List<SubmissionHistory>>(
      future: _submissionHistoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Belum ada riwayat penyetujuan.'));
        }

        final historyList = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            final item = historyList[index];
            final isApproved = item.status == 'approved';
            final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(item.processedAt);
            
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(
                  isApproved ? Icons.check_circle : Icons.cancel,
                  color: isApproved ? Colors.green : Colors.red,
                ),
                title: Text('${item.userName} - ${item.categoryName}'),
                subtitle: Text('${item.weight} gram - ${formattedDate}'),
                trailing: Text(
                  isApproved ? 'Disetujui' : 'Ditolak',
                  style: TextStyle(
                    color: isApproved ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget untuk menampilkan daftar riwayat penarikan
  Widget _buildWithdrawalHistoryList() {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return FutureBuilder<List<WithdrawalHistory>>(
      future: _withdrawalHistoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Belum ada riwayat penarikan.'));
        }

        final historyList = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            final item = historyList[index];
            final isApproved = item.status == 'approved';
            final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(item.processedAt);
            
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(
                  isApproved ? Icons.check_circle : Icons.cancel,
                  color: isApproved ? Colors.green : Colors.red,
                ),
                title: Text(item.userName),
                subtitle: Text('Jumlah: ${currencyFormatter.format(item.amount)}\nPada: $formattedDate'),
                trailing: Text(
                  isApproved ? 'Disetujui' : 'Ditolak',
                  style: TextStyle(
                    color: isApproved ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}