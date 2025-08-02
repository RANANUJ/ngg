import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../themes/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class NGODashboardScreen extends StatefulWidget {
  const NGODashboardScreen({super.key});

  @override
  State<NGODashboardScreen> createState() => _NGODashboardScreenState();
}

class _NGODashboardScreenState extends State<NGODashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  bool _isLoading = false;
  List<Map<String, dynamic>> _campaigns = [];
  List<Map<String, dynamic>> _donationRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final campaigns = await ApiService().getUserCampaigns();
      final donationRequests = await ApiService().getUserDonationRequests();
      print('Fetched campaigns: ' + campaigns.toString());
      print('Fetched donation requests: ' + donationRequests.toString());
      setState(() {
        _campaigns = campaigns;
        _donationRequests = donationRequests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error fetching data: $e');
    }
  }

  void _refreshAfterCreate() async {
    await Future.delayed(const Duration(seconds: 1));
    await _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        if (user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF6A11CB)),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: _buildAppBar(),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildFundraisingTab(),
              _buildDonationsTab(),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF6A11CB)),
          onPressed: () {
            // TODO: Open drawer
          },
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NGO Dashboard',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          Text(
            'Manage your impact',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF6A11CB),
            ),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF6A11CB)),
            onPressed: () {
              // TODO: Navigate to profile
            },
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelColor: const Color(0xFF6A11CB),
            unselectedLabelColor: const Color(0xFF94A3B8),
            indicatorColor: const Color(0xFF6A11CB),
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Fundraising'),
              Tab(text: 'Donations'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    // Calculate stats from real data
    int totalCampaigns = _campaigns.length;
    double totalRaised = 0;
    double totalTarget = 0;
    for (var c in _campaigns) {
      totalRaised += (c['raised_amount'] ?? 0).toDouble();
      totalTarget += (c['target_amount'] ?? 0).toDouble();
    }
    int totalDonationRequests = _donationRequests.length;
    int totalItemsNeeded = 0;
    int totalItemsReceived = 0;
    for (var d in _donationRequests) {
      var needed = d['quantity_needed'] ?? 0;
      var received = d['quantity_received'] ?? 0;
      if (needed is int) {
        totalItemsNeeded += needed;
      } else if (needed is num) {
        totalItemsNeeded += needed.round();
      } else {
        totalItemsNeeded += int.tryParse(needed.toString()) ?? 0;
      }
      if (received is int) {
        totalItemsReceived += received;
      } else if (received is num) {
        totalItemsReceived += received.round();
      } else {
        totalItemsReceived += int.tryParse(received.toString()) ?? 0;
      }
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          _buildStatsGrid(
            totalCampaigns: totalCampaigns,
            totalRaised: totalRaised,
            totalTarget: totalTarget,
            totalDonationRequests: totalDonationRequests,
            totalItemsNeeded: totalItemsNeeded,
            totalItemsReceived: totalItemsReceived,
          ),
          const SizedBox(height: 24),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A11CB).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.volunteer_activism,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ready to make a difference today?',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildQuickStat('5', 'Active\nCampaigns'),
              const SizedBox(width: 16),
              _buildQuickStat('₹45K', 'Total\nRaised'),
              const SizedBox(width: 16),
              _buildQuickStat('23', 'Active\nVolunteers'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid({
    required int totalCampaigns,
    required double totalRaised,
    required double totalTarget,
    required int totalDonationRequests,
    required int totalItemsNeeded,
    required int totalItemsReceived,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Active Campaigns',
          totalCampaigns.toString(),
          Icons.campaign,
          const Color(0xFF6A11CB),
          'Total fundraising campaigns',
        ),
        _buildStatCard(
          'Total Raised',
          '₹${totalRaised.toStringAsFixed(0)}',
          Icons.monetization_on,
          const Color(0xFF10B981),
          'Total money raised',
        ),
        _buildStatCard(
          'Donation Requests',
          totalDonationRequests.toString(),
          Icons.inventory,
          const Color(0xFFF59E0B),
          'Total donation requests',
        ),
        _buildStatCard(
          'Items Received',
          totalItemsReceived.toString(),
          Icons.check_circle,
          const Color(0xFF3B82F6),
          'Total items received',
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: View all activities
              },
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6A11CB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildActivityCard(
          'New donation received for Winter Campaign',
          '2 hours ago',
          Icons.favorite,
          const Color(0xFFEF4444),
          '₹5,000',
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          'Volunteer Priya joined your campaign',
          '4 hours ago',
          Icons.person_add,
          const Color(0xFF10B981),
          'New Volunteer',
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          'Fundraising goal reached for Education Project',
          '1 day ago',
          Icons.celebration,
          const Color(0xFFF59E0B),
          'Goal Achieved',
        ),
      ],
    );
  }

  Widget _buildActivityCard(
    String title,
    String time,
    IconData icon,
    Color color,
    String badge,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badge,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundraisingTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6A11CB)),
      );
    }
    if (_campaigns.isEmpty) {
      return Center(
        child: Text(
          'No fundraising campaigns found.',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Fundraising Campaigns',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  await context.push('/create-fundraising');
                },
                icon: const Icon(Icons.add, size: 20),
                label: Text(
                  'New Campaign',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6A11CB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._campaigns.map(
            (c) => Column(
              children: [
                _buildEnhancedFundraisingCard(
                  c['title'] ?? '',
                  c['description'] ?? '',
                  '₹${c['target_amount']?.toStringAsFixed(0) ?? '0'}',
                  '₹${c['raised_amount']?.toStringAsFixed(0) ?? '0'}',
                  c['end_date']?.toString().substring(0, 10) ?? '',
                  Icons.campaign,
                  const Color(0xFF3B82F6),
                  '${((c['raised_amount'] ?? 0) / ((c['target_amount'] ?? 1) == 0 ? 1 : c['target_amount'])) * 100 ~/ 1}%',
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6A11CB)),
      );
    }
    if (_donationRequests.isEmpty) {
      return Center(
        child: Text(
          'No donation requests found.',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Donation Requests',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  await context.push('/create-donation-request');
                  _refreshAfterCreate();
                },
                icon: const Icon(Icons.add, size: 20),
                label: Text(
                  'New Request',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6A11CB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._donationRequests.map(
            (d) => Column(
              children: [
                _buildEnhancedDonationCard(
                  d['title'] ?? '',
                  d['description'] ?? '',
                  '${d['quantity_needed'] ?? 0} ${d['unit'] ?? ''}',
                  '${d['quantity_received'] ?? 0} received',
                  Icons.inventory,
                  const Color(0xFFF59E0B),
                  '${((d['quantity_received'] ?? 0) / ((d['quantity_needed'] ?? 1) == 0 ? 1 : d['quantity_needed'])) * 100 ~/ 1}%',
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        _showCreateOptions(context);
      },
      backgroundColor: const Color(0xFF6A11CB),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: Text(
        'Create',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildEnhancedFundraisingCard(
    String title,
    String description,
    String target,
    String raised,
    String endDate,
    IconData icon,
    Color color,
    String percentage,
  ) {
    final targetAmount = double.parse(
      target.replaceAll('₹', '').replaceAll(',', ''),
    );
    final raisedAmount = double.parse(
      raised.replaceAll('₹', '').replaceAll(',', ''),
    );
    final progress = raisedAmount / targetAmount;

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to campaign details
        final campaign = {
          'title': title,
          'description': description,
          'target_amount': targetAmount,
          'raised_amount': raisedAmount,
          'end_date': endDate,
          'category': 'Education',
          'payment_details': {
            'bank_account': '1234567890',
            'upi_id': 'ngo@upi',
            'qr_code': 'https://example.com/qr.png',
          },
        };
        context.push('/campaign-details', extra: campaign);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    percentage,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Raised',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      raised,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Target',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      target,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toInt()}% Complete',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  'Ends $endDate',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedDonationCard(
    String title,
    String description,
    String needed,
    String received,
    IconData icon,
    Color color,
    String percentage,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Needed',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          needed,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Received',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          received,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  percentage,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF64748B)),
                onPressed: () {
                  // TODO: Edit donation request
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create New',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildCreateOption(
                        'Fundraising Campaign',
                        Icons.monetization_on,
                        Colors.green,
                        () {
                          Navigator.pop(context);
                          context.push('/create-fundraising');
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCreateOption(
                        'Donation Request',
                        Icons.inventory,
                        Colors.blue,
                        () {
                          Navigator.pop(context);
                          context.push('/create-donation-request');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildCreateOption(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCard(
    String title,
    String description,
    String needed,
    String received,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Needed: $needed',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Received: $received',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Edit donation request
            },
          ),
        ],
      ),
    );
  }
}
