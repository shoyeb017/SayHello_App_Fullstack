import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import 'chat_item.dart';

class SearchPeopleInHome extends StatefulWidget {
  final List<ChatItem> allChats;

  const SearchPeopleInHome({super.key, required this.allChats});

  @override
  State<SearchPeopleInHome> createState() => _SearchPeopleInHomeState();
}

class _SearchPeopleInHomeState extends State<SearchPeopleInHome> {
  final TextEditingController _controller = TextEditingController();
  String query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredChats = widget.allChats
        .where((chat) => chat.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search bar with cancel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (value) => setState(() => query = value),
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        hintText: AppLocalizations.of(context)!.searchPeople,
                        hintStyle: const TextStyle(fontSize: 16),
                        filled: true,
                        fillColor: theme.brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                ],
              ),
            ),

            // const Divider(height: 1),

            // Filtered results
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ), // top/bottom padding
                itemCount: filteredChats.length,
                itemBuilder: (context, index) {
                  final chat = filteredChats[index];
                  return Column(
                    children: [
                      _ChatTile(chat: chat),
                      if (index !=
                          filteredChats.length -
                              1) // avoid divider after last item
                        Divider(
                          indent: 90, // aligns with avatar + padding approx
                          endIndent: 20, // stops short of right edge
                          height: 1,
                          thickness: 0.7,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade700
                              : Colors.grey.shade400,
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

class _ChatTile extends StatelessWidget {
  final ChatItem chat;
  const _ChatTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 1.5,
      ), // smaller vertical gap
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 32, // slightly bigger avatar
              backgroundImage: NetworkImage(chat.avatarUrl),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 14, // a bit bigger to match avatar
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.red,
                  border: Border.all(color: Colors.white, width: 1.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          chat.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          chat.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(chat.dateLabel, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            if (chat.myTurn)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF311b86)
                      : const Color(0xFFefecfd),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.of(context)!.newMessage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF765ae3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}
