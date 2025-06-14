import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../services/network_info_service.dart';
import '../../services/storage_service.dart';
import 'package:logging/logging.dart';

class ProfilePage extends StatefulWidget {
  final NetworkInfoService? networkInfoService;
  final StorageService? storageService;
  final ImagePicker? imagePicker;

  const ProfilePage({
    super.key,
    this.networkInfoService,
    this.storageService,
    this.imagePicker,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late NetworkInfoService _networkService;
  late StorageService _storageService;
  late ImagePicker _picker;
  final _logger = Logger('ProfilePage');

  Map<String, dynamic>? _networkInfo;
  bool _isUploading = false;
  bool _isInitialLoading = true;
  String? _profileImageUrl;
  final TextEditingController _usernameController = TextEditingController();
  bool _isEditingUsername = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Use injected services or create new ones
    _networkService = widget.networkInfoService ?? NetworkInfoService();
    _storageService = widget.storageService ?? StorageService();
    _picker = widget.imagePicker ?? ImagePicker();

    _initialLoad();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _initialLoad() async {
    try {
      await Future.wait([
        _loadNetworkInfo(),
        _loadProfileImage(),
        _loadUsername(),
      ]);
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _loadNetworkInfo() async {
    if (!mounted) return;
    try {
      final info = await _networkService.getNetworkInfo();
      if (!mounted) return;
      setState(() {
        _networkInfo = info;
      });
    } catch (e) {
      _logger.warning('Error loading network info: $e');
      if (!mounted) return;
      setState(() {
        _networkInfo = {'ip': 'Unknown', 'connectionType': 'Unknown'};
      });
    }
  }

  Future<void> _loadProfileImage() async {
    if (!mounted) return;
    final provider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final user = provider.user;
    if (user == null) return;

    try {
      final imageUrl = await _storageService.getProfileImage(user.uid);
      if (!mounted) return;
      setState(() {
        _profileImageUrl = imageUrl;
      });
    } catch (e) {
      _logger.warning('Error loading profile image: $e');
    }
  }

  Future<void> _loadUsername() async {
    if (!mounted) return;
    final provider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final user = provider.user;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final username = userDoc.data()?['username'] as String?;
        if (!mounted) return;
        setState(() {
          _usernameController.text = username ?? user.displayName ?? '';
        });
      } else {
        // If document doesn't exist, use display name
        if (!mounted) return;
        setState(() {
          _usernameController.text = user.displayName ?? '';
        });
      }
    } catch (e) {
      _logger.warning('Error loading username: $e');
      // Fallback to display name
      if (!mounted) return;
      setState(() {
        _usernameController.text = user.displayName ?? '';
      });
    }
  }

  Future<void> _updateProfilePhoto() async {
    if (!mounted) return;
    try {
      final provider =
          Provider.of<app_auth.AuthProvider>(context, listen: false);
      final user = provider.user;
      if (user == null) {
        throw Exception('Please sign in to upload profile photos');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      if (_profileImageUrl != null) {
        await DefaultCacheManager().removeFile(_profileImageUrl!);
      }

      final photoUrl = await _storageService.uploadProfileImage(
        user.uid,
        File(image.path),
      );

      if (!mounted) return;
      await provider.updateProfilePhoto(photoUrl);

      setState(() {
        _profileImageUrl = photoUrl;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _logger.warning('Upload error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _updateUsername() async {
    if (!mounted) return;
    try {
      final provider =
          Provider.of<app_auth.AuthProvider>(context, listen: false);
      final user = provider.user;
      if (user == null) {
        throw Exception('Please sign in to update username');
      }

      await user.updateDisplayName(_usernameController.text.trim());
      await user.reload();
      await provider.refreshUser();

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDoc.update({
        'username': _usernameController.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username updated successfully')),
      );

      setState(() {
        _isEditingUsername = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating username: $e')),
      );
    }
  }

  Future<void> _changePassword() async {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    // Capture the provider and page context here
    final app_auth.AuthProvider authProviderInstance =
        Provider.of<app_auth.AuthProvider>(context, listen: false);
    final BuildContext pageScaffoldContext =
        context; // Context from ProfilePage state

    return showDialog<void>(
      context:
          pageScaffoldContext, // Use the captured page context for showing the dialog
      builder: (BuildContext dialogContext) {
        // This is the context for the dialog route
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(); // Use dialogContext to pop itself
              },
            ),
            ElevatedButton(
              child: const Text('Change'),
              onPressed: () async {
                // Use the captured authProviderInstance
                final user = authProviderInstance.user;
                if (user == null) {
                  Navigator.of(dialogContext).pop();
                  return;
                }

                if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  // Use pageScaffoldContext for ScaffoldMessenger
                  ScaffoldMessenger.of(pageScaffoldContext).showSnackBar(
                    const SnackBar(
                      content: Text('New passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  // Re-authenticate user
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: currentPasswordController.text,
                  );
                  await user.reauthenticateWithCredential(credential);

                  // Update password
                  await user.updatePassword(newPasswordController.text);

                  Navigator.of(dialogContext).pop();
                  // Use pageScaffoldContext for ScaffoldMessenger
                  ScaffoldMessenger.of(pageScaffoldContext).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  // Use pageScaffoldContext for ScaffoldMessenger
                  ScaffoldMessenger.of(pageScaffoldContext).showSnackBar(
                    SnackBar(
                      content: Text('Error updating password: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: _profileImageUrl != null
              ? CachedNetworkImageProvider(_profileImageUrl!)
              : null,
          child: _profileImageUrl == null
              ? const Icon(Icons.person, size: 50)
              : null,
        ),
        if (_isUploading)
          const Positioned.fill(
            child: CircularProgressIndicator(),
          ),
        Positioned(
          bottom: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _isUploading ? null : _updateProfilePhoto,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
      ),
    );
  }

  Widget _buildEditableProfileCard({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required VoidCallback onSave,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: InputBorder.none,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.save),
          onPressed: onSave,
        ),
      ),
    );
  }

  bool _canChangePassword(User? user) {
    if (user == null) return false;
    return user.providerData.any((info) => info.providerId == 'password');
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<app_auth.AuthProvider>(context);
    final user = provider.user;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;

    if (_isInitialLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    _buildProfileImage(),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Account Information'),
                    _buildProfileCard(
                      icon: Icons.email,
                      title: 'Email',
                      subtitle: user?.email ?? 'No email',
                    ),
                    _isEditingUsername
                        ? _buildEditableProfileCard(
                            icon: Icons.person,
                            title: 'Username',
                            controller: _usernameController,
                            onSave: _updateUsername,
                          )
                        : _buildProfileCard(
                            icon: Icons.person,
                            title: 'Username',
                            subtitle: _usernameController.text.isEmpty
                                ? 'No username set'
                                : _usernameController.text,
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  _isEditingUsername = true;
                                });
                              },
                            ),
                          ),
                    if (_canChangePassword(user))
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.lock),
                          title: const Text('Change Password'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _changePassword,
                        ),
                      ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Network Information'),
                    _buildProfileCard(
                      icon: Icons.wifi,
                      title: 'IP Address',
                      subtitle: _networkInfo?['ip'] ?? 'Loading...',
                    ),
                    _buildProfileCard(
                      icon: Icons.network_check,
                      title: 'Connection Type',
                      subtitle: _networkInfo?['connectionType'] ?? 'Loading...',
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
