import 'package:face_locker/core/services/auth_service.dart';
import 'package:face_locker/core/theme/app_theme.dart';
import 'package:face_locker/core/services/user_service.dart';
import 'package:face_locker/features/auth/data/models/user_model.dart';
import 'package:face_locker/features/auth/presentation/pages/login_page.dart';
import 'package:face_locker/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _user = _userService.currentUser;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.getMe();
      final data = response['data'];
      final userJson = data is Map<String, dynamic> ? data : response;
      final user = UserModel.fromJson(userJson);
      _userService.updateUser(user);
      if (mounted) setState(() => _user = user);
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'Failed to load profile.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _authService.logout();
    _userService.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  String _buildDisplayName() {
    final user = _user;
    if (user == null) return 'Unknown';
    if (user.fullName.isNotEmpty) return user.fullName;
    final composed = '${user.firstName} ${user.lastName}'.trim();
    return composed.isEmpty ? 'Unknown' : composed;
  }

  String _formatBirthday(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String _formatGender(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: AppTheme.softPanel(),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: const Color(0xFFDBEAFE),
                      child: Text(
                        _buildInitials(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _buildDisplayName(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.text,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (_user?.role ?? 'USER').toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.primaryDark,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppTheme.danger,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 14),
              _InfoField(
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                value: _user?.email ?? '-',
              ),
              const SizedBox(height: 12),
              _InfoField(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: _user?.phoneNumber ?? '-',
              ),
              const SizedBox(height: 12),
              _InfoField(
                icon: Icons.badge_outlined,
                label: 'Gender',
                value: _formatGender(_user?.gender),
              ),
              const SizedBox(height: 12),
              _InfoField(
                icon: Icons.cake_outlined,
                label: 'Birthday',
                value: _formatBirthday(_user?.birthday),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () async {
                  final updatedUser = await Navigator.push<UserModel>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfilePage(user: _user),
                    ),
                  );

                  if (!mounted) return;

                  if (updatedUser != null) {
                    _userService.updateUser(updatedUser);
                    setState(() {
                      _user = updatedUser;
                      _errorMessage = null;
                    });
                  } else {
                    await _loadProfile();
                  }
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Profile'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Log out'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.danger,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildInitials() {
    final user = _user;
    if (user == null) return '?';
    final first = user.firstName.isNotEmpty ? user.firstName[0] : '';
    final last = user.lastName.isNotEmpty ? user.lastName[0] : '';
    final initials = (first + last).toUpperCase();
    return initials.isNotEmpty ? initials : '?';
  }
}

// ─── Info display field ──────────────────────────────────────────────────────

class _InfoField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoField({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.softPanel(),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.muted, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
