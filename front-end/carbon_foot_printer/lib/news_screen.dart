import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  // Mock data for news articles
  List<Map<String, String>> get mockNews => [
        {
          "title":
              "Forest finance plan backed by 34 countries endorses Brazil’s rainforest fund",
          "description":
              "A global coalition of nations has pledged new funding to preserve the Amazon rainforest.",
          "imageUrl":
              "https://cdn.climatechangenews.com/compressx-nextgen/uploads/2025/09/3257-1440x960.jpg.webp",
          "url":
              "https://www.climatechangenews.com/2025/09/26/forest-finance-plan-backed-by-34-countries-endorses-brazils-rainforest-fund/"
        },
        {
          "title":
              "Digging beyond oil: Saudi Arabia bids to become a hub for energy transition minerals",
          "description":
              "Saudi Arabia eyes a future in minerals vital for the green energy transition.",
          "imageUrl":
              "https://cdn.climatechangenews.com/compressx-nextgen/uploads/2025/09/SAUDI-MINING-MAADEN-1440x893.jpg.webp",
          "url":
              "https://www.climatechangenews.com/2025/09/10/digging-beyond-oil-saudi-arabia-bids-to-become-a-hub-for-energy-transition-minerals/"
        },
        {
          "title":
              "Major financiers neglect energy transition risks from mining as demand booms",
          "description":
              "New analysis warns investors of overlooked risks in booming mining projects.",
          "imageUrl":
              "https://cdn.climatechangenews.com/compressx-nextgen/uploads/2024/01/Zimbabwe-lithium.jpg.avif",
          "url":
              "https://www.climatechangenews.com/2025/09/03/major-financiers-neglect-energy-transition-risks-from-mining-as-demand-booms/"
        },
        {
          "title":
              "Victims of Zambian copper mine disaster demand multibillion-dollar payout",
          "description":
              "Communities affected by mining accidents push for justice and compensation.",
          "imageUrl":
              "https://cdn.climatechangenews.com/compressx-nextgen/uploads/2025/03/IMG_0407-1440x943.jpg.avif",
          "url":
              "https://www.climatechangenews.com/2025/09/02/victims-of-zambian-copper-mine-disaster-demand-multibillion-dollar-payout/"
        },
      ];

  // Helper to open URLs
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Environmental News",
        style: TextStyle(
          color: Colors.white,
        ),
        ),
        backgroundColor: const Color.fromARGB(255, 10, 79, 54),
      ),
      body: ListView.builder(
        itemCount: mockNews.length,
        itemBuilder: (context, index) {
          final article = mockNews[index];
          return Card(
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _launchURL(article["url"]!),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Article image
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      article["imageUrl"]!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(height: 180, color: Colors.grey[300]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article["title"]!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          article["description"]!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
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
