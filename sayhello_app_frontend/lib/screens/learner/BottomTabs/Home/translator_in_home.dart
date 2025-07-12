import 'package:flutter/material.dart';

class TranslatorInHome extends StatefulWidget {
  const TranslatorInHome({super.key});

  @override
  State<TranslatorInHome> createState() => _TranslatorInHomeState();
}

class _TranslatorInHomeState extends State<TranslatorInHome> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String sourceLang = "English";
  String targetLang = "Japanese";
  String translatedText = "";
  String selectedLang = "";
  bool isSelectingSource = true;

  final Map<String, String> fakeTranslations = {
    "hello": "こんにちは",
    "goodbye": "さようなら",
    "thank you": "ありがとう",
    "yes": "はい",
    "no": "いいえ",
  };

  final List<String> allLanguages = [
    "English",
    "Chinese Simplified",
    "Japanese",
    "Korean",
    "Spanish",
    "French",
    "Portuguese",
  ];

  String _getSubtitle(String lang) {
    switch (lang) {
      case "English":
        return "English";
      case "Chinese Simplified":
        return "中文(简体)";
      case "Japanese":
        return "日本語";
      case "Korean":
        return "한국어";
      case "Spanish":
        return "Español";
      case "French":
        return "Français";
      case "Portuguese":
        return "Português";
      default:
        return "";
    }
  }

  void _translate() {
    String text = _inputController.text.trim().toLowerCase();
    setState(() {
      translatedText =
          fakeTranslations[text] ?? "Translation not available (dummy)";
    });
  }

  void _swapLanguages() {
    setState(() {
      final temp = sourceLang;
      sourceLang = targetLang;
      targetLang = temp;
      translatedText = "";
      _inputController.clear();
    });
  }

  void _openLanguageSelector(BuildContext context, bool isSource) {
    setState(() {
      isSelectingSource = isSource;
      selectedLang = isSource ? sourceLang : targetLang;
      _searchController.clear();
    });
    Scaffold.of(context).openEndDrawer();
  }

  void _applyLanguageSelection() {
    setState(() {
      if (isSelectingSource) {
        sourceLang = selectedLang;
      } else {
        targetLang = selectedLang;
      }
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    List<String> filteredLanguages = allLanguages
        .where(
          (lang) =>
              lang.toLowerCase().contains(_searchController.text.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // prevents default drawer icon
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // goes back to the previous screen
          },
        ),
        title: const Text(
          'Translate',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
        ], // forces NO icons on the right
      ),

      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: "Search",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14,
                      ), // ✅ aligns text nicely
                    ),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Popular",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredLanguages.length,
                  itemBuilder: (context, index) {
                    final lang = filteredLanguages[index];
                    final isSelected = selectedLang == lang;
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 9),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isSelected
                            ? Colors.deepPurple.withOpacity(isDark ? 0.2 : 0.1)
                            : isDark
                            ? const Color(0xFF1f1f1f)
                            : Colors.grey.shade200,
                        border: Border.all(
                          color: isSelected
                              ? Colors.deepPurple
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            selectedLang = lang;
                          });
                        },
                        title: Text(
                          lang,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.deepPurple
                                : isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          _getSubtitle(lang),
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.deepPurple)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _applyLanguageSelection,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final Color boxColor = isDark
              ? const Color(0xFF1F1F1F)
              : Colors.grey.shade200;
          final Color hintColor = isDark
              ? Colors.grey.shade600
              : Colors.grey.shade700;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language Selector Row
                  Container(
                    decoration: BoxDecoration(
                      color: boxColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // Source Language Button
                        Expanded(
                          child: InkWell(
                            onTap: () => _openLanguageSelector(context, true),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                // color: langButtonColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      sourceLang,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                    ),
                                  ),

                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Swap Icon
                        IconButton(
                          onPressed: _swapLanguages,
                          icon: const Icon(Icons.swap_horiz),
                          tooltip: "Swap languages",
                        ),
                        // Target Language Button
                        Expanded(
                          child: InkWell(
                            onTap: () => _openLanguageSelector(context, false),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      targetLang,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                    ),
                                  ),

                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Input Text Field Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: boxColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sourceLang,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _inputController,
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration.collapsed(
                            hintText: "Input text",
                            hintStyle: TextStyle(
                              color: hintColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Translate Button
                  ElevatedButton.icon(
                    onPressed: _translate,
                    icon: const Icon(Icons.translate),
                    label: const Text("Translate"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Translated Text Output
                  if (translatedText.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: boxColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        translatedText,
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
