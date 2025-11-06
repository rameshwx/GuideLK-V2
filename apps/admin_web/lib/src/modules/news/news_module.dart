import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/section_header.dart';

class NewsModule extends ConsumerWidget {
  const NewsModule({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        SectionHeader(
          title: 'News & alerts (stub)',
          subtitle: 'Reserved module for curated advisories and editorials.',
        ),
        Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What’s next'),
                SizedBox(height: 12),
                Text(
                  'This module will surface alerts from Sri Lanka Tourism, partner promos, and '
                  'seasonal guidance once the content ingestion service is wired. '
                  'For MVP the section remains a placeholder, but the routing and layout are ready '
                  'so the API response can drop in later.',
                ),
                SizedBox(height: 24),
                Text('Implementation hints'),
                SizedBox(height: 8),
                Text(
                  '• Add an /news endpoint to FastAPI when the feed is available.\n'
                  '• Store uploaded hero images under guidelkv2/media/news/.\n'
                  '• Consider scheduling daily refresh jobs to keep alerts timely.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
