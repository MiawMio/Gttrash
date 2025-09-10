import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

// Model SubmissionHistory (tetap sama)
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
    DateTime processedAtDate;
    final processedAtData = json['processed_at'];

    if (processedAtData is Map<String, dynamic> && processedAtData.containsKey('_seconds')) {
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

// Model WithdrawalHistory (tetap sama)
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

  factory WithdrawalHistory.fromJson(Map<String, dynamic> json) {
    DateTime processedAtDate;
    final processedAtData = json['processed_at'];

    if (processedAtData is Map<String, dynamic> && processedAtData.containsKey('_seconds')) {
      final seconds = processedAtData['_seconds'] as int;
      processedAtDate = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    } else if (processedAtData is String) {
      processedAtDate = DateTime.parse(processedAtData);
    } else {
      processedAtDate = DateTime.now();
    }

    return WithdrawalHistory(
      userName: json['user_name'] ?? 'Unknown User',
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] ?? 'unknown',
      processedAt: processedAtDate.toLocal(),
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

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  DateTime? _selectedDate;

  bool _isLoadingSubmissions = true;
  bool _isLoadingWithdrawals = true;
  List<SubmissionHistory> _submissionHistory = [];
  List<WithdrawalHistory> _withdrawalHistory = [];
  int _submissionCurrentPage = 1;
  int _withdrawalCurrentPage = 1;
  int _submissionTotalPages = 1;
  int _withdrawalTotalPages = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _reloadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery != _searchController.text) {
        setState(() {
          _searchQuery = _searchController.text;
        });
        _reloadData(resetPage: true);
      }
    });
  }
  
  void _reloadData({bool resetPage = false}) {
    if (resetPage) {
      _submissionCurrentPage = 1;
      _withdrawalCurrentPage = 1;
    }
    _fetchSubmissionHistory(_submissionCurrentPage, _searchQuery, _selectedDate);
    _fetchWithdrawalHistory(_withdrawalCurrentPage, _searchQuery, _selectedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _reloadData(resetPage: true);
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
    _reloadData(resetPage: true);
  }

  Future<void> _fetchSubmissionHistory(int page, String search, DateTime? date) async {
    setState(() => _isLoadingSubmissions = true);
    try {
      String dateQuery = date != null ? '&date=${DateFormat('yyyy-MM-dd').format(date)}' : '';
      final url = 'https://trash-api-azure.vercel.app/api/history?page=$page&limit=8&search=$search$dateQuery';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        setState(() {
          _submissionHistory = data.map((item) => SubmissionHistory.fromJson(item)).toList();
          _submissionTotalPages = body['totalPages'] ?? 1;
          _submissionCurrentPage = body['currentPage'] ?? 1;
        });
      } else {
        throw Exception('Failed to load submission history');
      }
    } finally {
      if(mounted) setState(() => _isLoadingSubmissions = false);
    }
  }

  Future<void> _fetchWithdrawalHistory(int page, String search, DateTime? date) async {
    setState(() => _isLoadingWithdrawals = true);
    try {
      // <<< INI BAGIAN YANG DIPERBAIKI >>>
      String dateQuery = date != null ? '&date=${DateFormat('yyyy-MM-dd').format(date)}' : '';
      final url = 'https://trash-api-azure.vercel.app/api/withdrawal-history?page=$page&limit=8&search=$search$dateQuery';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        setState(() {
          _withdrawalHistory = data.map((item) => WithdrawalHistory.fromJson(item)).toList();
          _withdrawalTotalPages = body['totalPages'] ?? 1;
          _withdrawalCurrentPage = body['currentPage'] ?? 1;
        });
      } else {
        throw Exception('Failed to load withdrawal history');
      }
    } finally {
      if(mounted) setState(() => _isLoadingWithdrawals = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
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
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan nama...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: _selectedDate != null ? AppColors.primaryGreen : Colors.grey),
                  onPressed: () => _selectDate(context),
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red),
                    onPressed: _clearDateFilter,
                  )
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSubmissionHistoryList(),
                _buildWithdrawalHistoryList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionHistoryList() {
    if (_isLoadingSubmissions) return const Center(child: CircularProgressIndicator());
    if (_submissionHistory.isEmpty) return const Center(child: Text('Tidak ada data yang cocok.'));

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            itemCount: _submissionHistory.length,
            itemBuilder: (context, index) {
              final item = _submissionHistory[index];
              final isApproved = item.status == 'approved';
              final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(item.processedAt);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
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
                        fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
        _buildPaginationControls(
          currentPage: _submissionCurrentPage,
          totalPages: _submissionTotalPages,
          onPageChanged: (page) => _fetchSubmissionHistory(page, _searchQuery, _selectedDate),
        ),
      ],
    );
  }
  
  Widget _buildWithdrawalHistoryList() {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    if (_isLoadingWithdrawals) return const Center(child: CircularProgressIndicator());
    if (_withdrawalHistory.isEmpty) return const Center(child: Text('Tidak ada data yang cocok.'));
    
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            itemCount: _withdrawalHistory.length,
            itemBuilder: (context, index) {
              final item = _withdrawalHistory[index];
              final isApproved = item.status == 'approved';
              final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(item.processedAt);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        _buildPaginationControls(
          currentPage: _withdrawalCurrentPage,
          totalPages: _withdrawalTotalPages,
          onPageChanged: (page) => _fetchWithdrawalHistory(page, _searchQuery, _selectedDate),
        ),
      ],
    );
  }

  Widget _buildPaginationControls({
    required int currentPage,
    required int totalPages,
    required ValueChanged<int> onPageChanged,
  }) {
    if (totalPages <= 1) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
          ),
          Text('Halaman $currentPage dari $totalPages'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
          ),
        ],
      ),
    );
  }
}