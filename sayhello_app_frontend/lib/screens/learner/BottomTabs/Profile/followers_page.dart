import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/follower_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../models/learner.dart';
import '../Connect/others_profile_page.dart';

class FollowersPage extends StatefulWidget {
  final String learnerId;
  final String learnerName;
  final String title; // "Followers" or "Following"
  final bool isFollowers; // true for followers, false for following

  const FollowersPage({
    super.key,
    required this.learnerId,
    required this.learnerName,
    required this.title,
    required this.isFollowers,
  });

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    final followerProvider = Provider.of<FollowerProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.id ?? '';

    print('Loading data for ${widget.isFollowers ? "followers" : "following"}');
    print('Current user ID: $currentUserId');
    print('Target learner ID: ${widget.learnerId}');

    if (widget.isFollowers) {
      await followerProvider.loadFollowers(widget.learnerId);
    } else {
      await followerProvider.loadFollowing(widget.learnerId);
    }

    // Load follow status for all users
    final users = widget.isFollowers
        ? followerProvider.followers
        : followerProvider.following;

    for (final user in users) {
      if (user.id != currentUserId) {
        await followerProvider.checkFollowStatus(currentUserId, user.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF7A54FF);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            Text(
              widget.learnerName,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: Consumer2<FollowerProvider, AuthProvider>(
        builder: (context, followerProvider, authProvider, child) {
          if (followerProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            );
          }

          final users = widget.isFollowers
              ? followerProvider.followers
              : followerProvider.following;

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isFollowers
                        ? Icons.people_outline
                        : Icons.person_add_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.isFollowers
                        ? 'No followers yet'
                        : 'Not following anyone yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isFollowers
                        ? 'When people follow ${widget.learnerName}, they\'ll appear here'
                        : 'When ${widget.learnerName} follows people, they\'ll appear here',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            color: primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return _buildUserCard(context, user, isDark, primaryColor);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    Learner user,
    bool isDark,
    Color primaryColor,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to others profile page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OthersProfilePage(
              userId: user.id,
              name: user.name,
              avatar: user.profileImage ?? '',
              nativeLanguage: user.nativeLanguage,
              learningLanguage: user.learningLanguage,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: isDark ? 2 : 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Profile picture
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.transparent,
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? Icon(Icons.person, size: 28, color: Colors.grey[600])
                    : null,
              ),

              const SizedBox(width: 16),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      '@${user.username}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    if (user.bio != null && user.bio!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.bio!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.translate, size: 12, color: primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          '${_capitalizeFirst(user.nativeLanguage)} → ${_capitalizeFirst(user.learningLanguage)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalizeFirst(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }
}
