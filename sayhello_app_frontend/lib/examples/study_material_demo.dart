import 'package:flutter/material.dart';
import '../screens/learner/BottomTabs/Learn/Enrolled/study_material.dart';

/// Example usage of the enhanced Study Materials functionality
/// This demo shows how the new features work with real URLs

class StudyMaterialDemo extends StatelessWidget {
  const StudyMaterialDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample course data for demonstration
    final sampleCourse = {
      'id': 'course_123',
      'title': 'Flutter Development Course',
      'instructor': 'John Doe',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Materials Demo'),
        backgroundColor: Color(0xFF7A54FF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demo Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📚 Study Materials Features',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    const Text('✅ View PDFs using Syncfusion PDF Viewer'),
                    const Text('✅ View images with zoom and pan controls'),
                    const Text('✅ Open DOC/DOCX files in browser'),
                    const Text('✅ Download files to local storage'),
                    const Text('✅ Expandable descriptions (More/Less)'),
                    const Text('✅ File type statistics (PDF, Images, Others)'),
                    const Text(
                      '✅ Material info chips (pages, rating, downloads)',
                    ),
                    const Text('✅ Color theme: Color(0xFF7A54FF)'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF7A54FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '💡 Tip: Click "View" to open materials in the built-in viewer!',
                        style: TextStyle(
                          color: Color(0xFF7A54FF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Launch Study Materials Tab
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7A54FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: const Text('Study Materials'),
                          backgroundColor: Color(0xFF7A54FF),
                          foregroundColor: Colors.white,
                        ),
                        body: StudyMaterialTab(course: sampleCourse),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.launch, color: Colors.white),
                label: const Text(
                  'Open Study Materials Tab',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Implementation Notes
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔧 Implementation Details',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailItem(
                                '📊 Header Statistics',
                                'Shows Total Materials, PDFs, Images, and Others count (removed size)',
                              ),
                              _buildDetailItem(
                                '📝 Expandable Descriptions',
                                'Long descriptions show "More/Less" buttons for better UX',
                              ),
                              _buildDetailItem(
                                '🎨 Color Theme',
                                'Uses Color(0xFF7A54FF) throughout the interface',
                              ),
                              _buildDetailItem(
                                '👁️ Smart Viewer',
                                'Auto-detects file types:\n• PDFs → Syncfusion PDF Viewer\n• Images → Zoomable Image Viewer\n• DOC/DOCX → Browser with Google Docs',
                              ),
                              _buildDetailItem(
                                '💾 Download Functionality',
                                'Downloads files to device storage with progress indication',
                              ),
                              _buildDetailItem(
                                '📦 Required Packages',
                                'syncfusion_flutter_pdfviewer: ^30.1.42\npath_provider: ^2.1.2',
                              ),
                              _buildDetailItem(
                                '🔗 Sample URLs',
                                'Uses real URLs for testing:\n• PDF documents\n• Sample images\n• Google Docs links',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF7A54FF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: Colors.grey[600], height: 1.4),
          ),
        ],
      ),
    );
  }
}

/// How to integrate the Study Materials functionality:
/// 
/// 1. Add required packages to pubspec.yaml:
/// ```yaml
/// dependencies:
///   syncfusion_flutter_pdfviewer: ^30.1.42
///   path_provider: ^2.1.2
/// ```
/// 
/// 2. Update your materials data structure to include 'url' field:
/// ```dart
/// final materials = [
///   {
///     'id': 'mat_1',
///     'title': 'Your PDF Document',
///     'description': 'Long description that will show More/Less...',
///     'type': 'pdf',
///     'url': 'https://your-server.com/document.pdf',
///     'pages': 24,
///     'rating': 4.8,
///     // ... other fields
///   },
/// ];
/// ```
/// 
/// 3. The viewer automatically handles:
/// - PDF files → Opens in Syncfusion PDF Viewer
/// - Images → Opens in zoomable image viewer  
/// - DOC/DOCX → Opens in browser with Google Docs viewer
/// - Downloads → Saves to device storage
/// 
/// 4. File type statistics are calculated automatically:
/// - Total Materials count
/// - PDF files count
/// - Image files count  
/// - Other files count
/// 
/// 5. Features included:
/// - Expandable descriptions with More/Less
/// - Download progress indication
/// - Error handling for failed loads
/// - Consistent Color(0xFF7A54FF) theming
/// - Material info chips (pages, rating, downloads)
/// - Favorite indicators
/// - Loading states for all operations
