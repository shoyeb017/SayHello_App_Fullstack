import 'package:flutter/material.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Feed Page')));
  }
}





// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Find Partners UI',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.light(),
//       darkTheme: ThemeData.dark(),
//       home: const ConnectPage(),
//     );
//   }
// }

// class ConnectPage extends StatelessWidget {
//   const ConnectPage({super.key});

//   void _openFilterSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (_) => const FilterSheet(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Find Partners"),
//         centerTitle: true,
//         actions: [
//           const Icon(Icons.flash_on),
//           const SizedBox(width: 12),
//           IconButton(
//             icon: const Icon(Icons.filter_alt_outlined),
//             onPressed: () => _openFilterSheet(context),
//           ),
//         ],
//         leading: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Image.network('https://i.imgur.com/YOUR_VIP_BADGE.png'),
//         ),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   FilterChipWidget(label: 'All', selected: true),
//                   FilterChipWidget(label: 'Serious Learners'),
//                   FilterChipWidget(label: 'Nearby'),
//                   FilterChipWidget(label: 'City'),
//                   FilterChipWidget(label: 'Gender'),
//                 ],
//               ),
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12),
//             child: Row(
//               children: [
//                 LanguageTab(label: 'Japanese', selected: true),
//                 SizedBox(width: 8),
//                 LanguageTab(label: 'Chinese'),
//                 SizedBox(width: 8),
//                 CircleAvatar(radius: 14, child: Icon(Icons.add, size: 16)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
// Expanded(
//   child: ListView(
//     padding: const EdgeInsets.symmetric(horizontal: 12),
//     children: const [
//       PartnerCard(),
//       PartnerCard(),
//       PartnerCard(),
//     ],
//   ),
// ),

//         ],
//       ),
//     );
//   }
// }

// class FilterChipWidget extends StatelessWidget {
//   final String label;
//   final bool selected;
//   const FilterChipWidget({super.key, required this.label, this.selected = false});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(right: 8),
//       child: Chip(
//         label: Text(label),
//         backgroundColor: selected ? Colors.deepPurple : Colors.grey.shade200,
//         labelStyle: TextStyle(
//           color: selected ? Colors.white : Colors.black,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }
// }

// class LanguageTab extends StatelessWidget {
//   final String label;
//   final bool selected;
//   const LanguageTab({super.key, required this.label, this.selected = false});

//   @override
//   Widget build(BuildContext context) {
//     return Chip(
//       label: Text(
//         label,
//         style: TextStyle(
//           color: selected ? Colors.white : Colors.black,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       backgroundColor: selected ? Colors.deepPurple : Colors.grey.shade300,
//     );
//   }
// }

// class PartnerCard extends StatelessWidget {
//   const PartnerCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CircleAvatar(
//               radius: 28,
//               backgroundImage: NetworkImage('https://i.imgur.com/BoN9kdC.png'),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       const Text(
//                         'Yusuke',
//                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                       ),
//                       const SizedBox(width: 6),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: Colors.orange,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: const Text('VIP', style: TextStyle(color: Colors.white, fontSize: 10)),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: const [
//                       Text("JP  ", style: TextStyle(fontSize: 12)),
//                       Icon(Icons.language, size: 14),
//                       Text("  EN  ", style: TextStyle(fontSize: 12)),
//                       Icon(Icons.language, size: 14),
//                       Text("  ID", style: TextStyle(fontSize: 12)),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   const Text(
//                     'My name is Yusuke from Japan...',
//                     style: TextStyle(fontSize: 13),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   Wrap(
//                     spacing: 6,
//                     runSpacing: -8,
//                     children: const [
//                       Chip(label: Text("Very active"), backgroundColor: Colors.orangeAccent),
//                       Chip(label: Text("ISTJ"), backgroundColor: Colors.grey),
//                       Chip(label: Text("Soccer"), backgroundColor: Colors.grey),
//                       Chip(label: Text("Basketball"), backgroundColor: Colors.grey),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//             const SizedBox(width: 8),
//             CircleAvatar(
//               backgroundColor: Colors.deepPurple,
//               child: Icon(Icons.waving_hand, color: Colors.white),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class FilterSheet extends StatelessWidget {
//   const FilterSheet({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: MediaQuery.of(context).viewInsets,
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: const [
//                 Icon(Icons.close),
//                 Text("Search", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 Text("Reset", style: TextStyle(color: Colors.deepPurple))
//               ],
//             ),
//             const SizedBox(height: 16),
//             const Text("\u{1F4A1} Filter options coming soon!"),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 minimumSize: const Size.fromHeight(50),
//               ),
//               child: const Text("Search", style: TextStyle(fontSize: 16)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';

// class ConnectPage extends StatelessWidget {
//   const ConnectPage({super.key});

//   void _openFilterSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (_) => const FilterSheet(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Find Partners"),
//         centerTitle: true,
//         actions: [
//           const Icon(Icons.flash_on),
//           const SizedBox(width: 12),
//           IconButton(
//             icon: const Icon(Icons.filter_alt_outlined),
//             onPressed: () => _openFilterSheet(context),
//           ),
//         ],
//         leading: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Image.network('https://i.imgur.com/YOUR_VIP_BADGE.png'),
//         ),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   FilterChipWidget(label: 'All', selected: true),
//                   FilterChipWidget(label: 'Serious Learners'),
//                   FilterChipWidget(label: 'Nearby'),
//                   FilterChipWidget(label: 'City'),
//                   FilterChipWidget(label: 'Gender'),
//                 ],
//               ),
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12),
//             child: Row(
//               children: [
//                 LanguageTab(label: 'Japanese', selected: true),
//                 SizedBox(width: 8),
//                 LanguageTab(label: 'Chinese'),
//                 SizedBox(width: 8),
//                 CircleAvatar(radius: 14, child: Icon(Icons.add, size: 16)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//        Expanded(
//   child: ListView(
//     padding: const EdgeInsets.symmetric(horizontal: 12),
//     children: const [
//       PartnerCard(),
//       PartnerCard(),
//       PartnerCard(),
//     ],
//   ),
// ),

//         ],
//       ),
//     );
//   }
// }

// class FilterChipWidget extends StatelessWidget {
//   final String label;
//   final bool selected;
//   const FilterChipWidget({super.key, required this.label, this.selected = false});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(right: 8),
//       child: Chip(
//         label: Text(label),
//         backgroundColor: selected ? Colors.deepPurple : Colors.grey.shade200,
//         labelStyle: TextStyle(
//           color: selected ? Colors.white : Colors.black,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }
// }

// class LanguageTab extends StatelessWidget {
//   final String label;
//   final bool selected;
//   const LanguageTab({super.key, required this.label, this.selected = false});

//   @override
//   Widget build(BuildContext context) {
//     return Chip(
//       label: Text(
//         label,
//         style: TextStyle(
//           color: selected ? Colors.white : Colors.black,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       backgroundColor: selected ? Colors.deepPurple : Colors.grey.shade300,
//     );
//   }
// }

// class PartnerCard extends StatelessWidget {
//   const PartnerCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CircleAvatar(
//               radius: 28,
//               backgroundImage: NetworkImage('https://i.imgur.com/BoN9kdC.png'),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       const Text(
//                         'Yusuke',
//                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                       ),
//                       const SizedBox(width: 6),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: Colors.orange,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: const Text('VIP', style: TextStyle(color: Colors.white, fontSize: 10)),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: const [
//                       Text("JP  ", style: TextStyle(fontSize: 12)),
//                       Icon(Icons.language, size: 14),
//                       Text("  EN  ", style: TextStyle(fontSize: 12)),
//                       Icon(Icons.language, size: 14),
//                       Text("  ID", style: TextStyle(fontSize: 12)),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   const Text(
//                     'My name is Yusuke from Japan...',
//                     style: TextStyle(fontSize: 13),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   Wrap(
//                     spacing: 6,
//                     runSpacing: -8,
//                     children: const [
//                       Chip(label: Text("Very active"), backgroundColor: Colors.orangeAccent),
//                       Chip(label: Text("ISTJ"), backgroundColor: Colors.grey),
//                       Chip(label: Text("Soccer"), backgroundColor: Colors.grey),
//                       Chip(label: Text("Basketball"), backgroundColor: Colors.grey),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//             const SizedBox(width: 8),
//             CircleAvatar(
//               backgroundColor: Colors.deepPurple,
//               child: Icon(Icons.waving_hand, color: Colors.white),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class FilterSheet extends StatelessWidget {
//   const FilterSheet({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: MediaQuery.of(context).viewInsets,
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: const [
//                 Icon(Icons.close),
//                 Text("Search", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 Text("Reset", style: TextStyle(color: Colors.deepPurple))
//               ],
//             ),
//             const SizedBox(height: 16),
//             const Text("\u{1F4A1} Filter options coming soon!"),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 minimumSize: const Size.fromHeight(50),
//               ),
//               child: const Text("Search", style: TextStyle(fontSize: 16)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
