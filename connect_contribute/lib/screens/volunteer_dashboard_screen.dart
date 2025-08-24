import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'donation_screen.dart';

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  State<VolunteerDashboardScreen> createState() =>
      _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Removed unused selected index
  bool _isLoading = false;
  List<Map<String, dynamic>> _donationRequests = [];
  List<Map<String, dynamic>> _activeCampaigns = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final donationRequests = await ApiService.instance.getAllDonationRequests();
      final campaigns = await ApiService.instance.getAllCampaigns();
      setState(() {
        _donationRequests = donationRequests;
        _activeCampaigns = campaigns;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error fetching volunteer dashboard data: $e');
    }
  }

  // Removed unused _refreshAfterAction

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
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: _buildAppBar(),
          drawer: _buildDrawer(authProvider),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildFeedTab(),
              _buildRequestsTab(),
              _buildRewardsTab(),
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
            print('Menu button pressed - attempting to open drawer');
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Volunteer Hub',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          Text(
            'Make a difference',
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
              Tab(text: 'Feed'),
              Tab(text: 'Requests'),
              Tab(text: 'Rewards'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          _buildCommunityFeed(),
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
              _buildQuickStat('1,250', 'Impact\nPoints'),
              const SizedBox(width: 16),
              _buildQuickStat('50+', 'Hours\nVolunteered'),
              const SizedBox(width: 16),
              _buildQuickStat('12', 'Badges\nEarned'),
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

  Widget _buildCommunityFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Community Feed',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: View all posts
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
        _buildEnhancedSocialPost(
          'Priya Sharma',
          'Just donated 10 books to the Education NGO! 📚 Making education accessible for all children. #EducationForAll #Volunteering',
          '2 hours ago',
          'assets/images/donation.jpg',
          24,
          8,
          Icons.book,
          const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 16),
        _buildEnhancedSocialPost(
          'Rahul Kumar',
          'Volunteered at the food distribution drive today. The smiles on people\'s faces made it all worth it! 🍲❤️',
          '4 hours ago',
          'assets/images/volunteering.jpg',
          18,
          5,
          Icons.restaurant,
          const Color(0xFF10B981),
        ),
        const SizedBox(height: 16),
        _buildEnhancedSocialPost(
          'Anjali Patel',
          'Completed my 50th hour of volunteering! Thank you everyone for the support. Let\'s keep making a difference! 🎉',
          '1 day ago',
          'assets/images/celebration.jpg',
          32,
          12,
          Icons.celebration,
          const Color(0xFFF59E0B),
        ),
      ],
    );
  }

    Widget _buildRequestsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6A11CB)),
       );
    }
    if (_donationRequests.isEmpty && _activeCampaigns.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Text(
                'No urgent requests or campaigns found.\nPull to refresh',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Urgent Requests & Campaigns',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // TODO: View all requests
                },
                icon: const Icon(Icons.filter_list, size: 20),
                label: Text(
                  'Filter',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6A11CB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Fundraising campaigns list for volunteers to contribute
          ..._activeCampaigns.map((c) => Column(
                children: [
                  _buildVolunteerCampaignCard(c),
                  const SizedBox(height: 12),
                ],
              )).toList(),
          if (_activeCampaigns.isNotEmpty) const SizedBox(height: 12),
          ..._donationRequests.map(
            (d) => Column(
              children: [
                _buildEnhancedUrgentRequestCard(
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
          ).toList(),
        ],
      ),
    ),
    );
  }

  Widget _buildVolunteerCampaignCard(Map<String, dynamic> c) {
    final double target = (c['target_amount'] ?? 0).toDouble();
    final double raised = (c['raised_amount'] ?? 0).toDouble();
    final double progress = target > 0 ? (raised / target).clamp(0.0, 1.0) : 0.0;

    final TextEditingController controller = TextEditingController();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.campaign, color: Color(0xFF3B82F6), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c['title'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      c['description'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Raised', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
                  Text('₹${raised.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Target', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
                  Text('₹${target.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Amount (₹)',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    isDense: true,
                    enabled: false, // Make it read-only, amount will be set by UPI payment
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showEnhancedDonationDialog(c),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A11CB),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.qr_code_scanner, size: 16),
                label: const Text('UPI Pay'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPointsOverview(),
          const SizedBox(height: 24),
          _buildBadgesSection(),
          const SizedBox(height: 24),
          _buildCertificatesSection(),
        ],
      ),
    );
  }

  Widget _buildPointsOverview() {
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Impact Points',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Keep making a difference!',
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
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '1,250',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Current Points',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '1,500',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Next Milestone',
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
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.83,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '250 points to next milestone',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Badges',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildEnhancedBadgeCard(
              'First Donation',
              Icons.favorite,
              const Color(0xFFEF4444),
              true,
              'Donated for the first time',
            ),
            const SizedBox(width: 16),
            _buildEnhancedBadgeCard(
              'Community Helper',
              Icons.people,
              const Color(0xFF3B82F6),
              true,
              'Helped 10+ people',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildEnhancedBadgeCard(
              'Super Volunteer',
              Icons.star,
              const Color(0xFFF59E0B),
              false,
              'Complete 100 hours',
            ),
            const SizedBox(width: 16),
            _buildEnhancedBadgeCard(
              'Impact Leader',
              Icons.leaderboard,
              const Color(0xFF8B5CF6),
              false,
              'Lead 5+ campaigns',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCertificatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Certificates',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        _buildEnhancedCertificateCard(
          'Volunteer Excellence',
          'Awarded for 100+ hours of community service',
          '2024-01-15',
          Icons.celebration,
          const Color(0xFFF59E0B),
        ),
        const SizedBox(height: 12),
        _buildEnhancedCertificateCard(
          'Community Impact',
          'Recognized for outstanding contribution to education',
          '2023-12-20',
          Icons.school,
          const Color(0xFF3B82F6),
        ),
      ],
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
        'Share',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
                  'Share Your Impact',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildCreateOption(
                        'Share Activity',
                        Icons.camera_alt,
                        Colors.blue,
                        () {
                          Navigator.pop(context);
                          // TODO: Navigate to share activity screen
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCreateOption(
                        'Donate Now',
                        Icons.favorite,
                        Colors.red,
                        () {
                          Navigator.pop(context);
                          // TODO: Navigate to donation screen
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

  Widget _buildEnhancedSocialPost(
    String name,
    String content,
    String time,
    String imagePath,
    int likes,
    int comments,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF475569),
              height: 1.4,
            ),
          ),
          if (imagePath.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSocialPostAction(
                Icons.favorite_border,
                'Like',
                likes,
                color,
              ),
              const SizedBox(width: 16),
              _buildSocialPostAction(
                Icons.comment_outlined,
                'Comment',
                comments,
                color,
              ),
              const SizedBox(width: 16),
              _buildSocialPostAction(Icons.share, 'Share', 0, color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialPostAction(
    IconData icon,
    String label,
    int count,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color.withOpacity(0.7)),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: color.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedUrgentRequestCard(
    String title,
    String description,
    String target,
    String received,
    IconData icon,
    Color color,
    String percentage,
  ) {
    final targetAmount = int.parse(
      target.replaceAll(' items', '').replaceAll(' kg', ''),
    );
    final receivedAmount = int.parse(
      received.replaceAll(' received', '').replaceAll(' kg received', ''),
    );
    final progress = receivedAmount / targetAmount;

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to donation request details
        final donationRequest = {
          'title': title,
          'description': description,
          'quantity_needed': targetAmount,
          'quantity_received': receivedAmount,
          'unit': target.contains('kg') ? 'kg' : 'items',
          'category': 'Books',
          'deadline': '2024-03-15',
        };
        context.push('/donation-request-details', extra: donationRequest);
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
                      'Received',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      received,
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
                      'Needed',
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Urgent',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedBadgeCard(
    String title,
    IconData icon,
    Color color,
    bool isUnlocked,
    String description,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked ? color.withOpacity(0.1) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked ? color : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isUnlocked
                        ? color.withOpacity(0.2)
                        : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isUnlocked ? color : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isUnlocked ? color : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color:
                    isUnlocked
                        ? color.withOpacity(0.8)
                        : const Color(0xFF94A3B8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isUnlocked ? color : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isUnlocked ? 'Unlocked' : 'Locked',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedCertificateCard(
    String title,
    String description,
    String date,
    IconData icon,
    Color color,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Awarded on $date',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Color(0xFF64748B)),
            onPressed: () {
              // TODO: Download certificate
            },
          ),
        ],
      ),
    );
  }

  void _showEnhancedDonationDialog(Map<String, dynamic> campaign) {
    // Get UPI ID from campaign payment details, with a fallback to a valid test UPI ID
    final upiId = campaign['payment_details']?['upi_id'] ?? 'demo@paytm';
    final targetAmount = (campaign['target_amount'] ?? 0).toDouble();
    final currentRaised = (campaign['raised_amount'] ?? 0).toDouble();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DonationScreen(
          campaignId: campaign['_id'] ?? '',
          campaignTitle: campaign['title'] ?? 'Campaign',
          upiId: upiId,
          targetAmount: targetAmount,
          currentRaised: currentRaised,
          onSuccess: () async {
            // Refresh the data to show updated progress
            await _fetchData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thank you for your donation!'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrawer(AuthProvider authProvider) {
    final user = authProvider.user;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF6A11CB),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.volunteer_activism,
                  color: Colors.white,
                  size: 50,
                ),
                const SizedBox(height: 10),
                Text(
                  user?.name ?? 'Volunteer',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? 'volunteer@example.com',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.feed),
            title: const Text('Activity Feed'),
            onTap: () {
              Navigator.pop(context);
              _tabController.animateTo(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Donation Requests'),
            onTap: () {
              Navigator.pop(context);
              _tabController.animateTo(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Rewards'),
            onTap: () {
              Navigator.pop(context);
              _tabController.animateTo(2);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout? You will be redirected to the login screen.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _performLogout();
    }
  }

  Future<void> _performLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6A11CB),
            ),
          );
        },
      );

      // Perform logout
      await context.read<AuthProvider>().logout();

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        // Navigate to login screen
        context.go('/login');
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Logged out successfully',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error during logout: ${e.toString()}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}
