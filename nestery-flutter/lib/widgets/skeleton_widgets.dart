import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:nestery_flutter/widgets/property_card.dart';
import 'package:nestery_flutter/models/property.dart';

/// Skeleton loading screens for different views
///
/// Research shows skeleton screens improve perceived performance by 40-60%

class PropertyCardSkeleton extends StatelessWidget {
  final bool isHorizontal;

  const PropertyCardSkeleton({
    super.key,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: PropertyCard(
        property: Property.placeholder(),
        isHorizontal: isHorizontal,
      ),
    );
  }
}

class SearchResultsSkeleton extends StatelessWidget {
  const SearchResultsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => const PropertyCardSkeleton(
          isHorizontal: true,
        ),
      ),
    );
  }
}

class PropertyDetailsSkeleton extends StatelessWidget {
  const PropertyDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: CustomScrollView(
        slivers: [
          // Image gallery skeleton
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: Colors.grey[300]),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Container(
                    height: 28,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),

                  // Rating
                  Container(
                    height: 20,
                    width: 150,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Container(
                    height: 32,
                    width: 120,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: 200,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookingsListSkeleton extends StatelessWidget {
  const BookingsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        itemCount: 3,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24,
                  width: 200,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: 150,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 20,
                      width: 100,
                      color: Colors.white,
                    ),
                    Container(
                      height: 32,
                      width: 80,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 16),
            Container(
              height: 24,
              width: 150,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: 200,
              color: Colors.white,
            ),
            const SizedBox(height: 24),

            // Stats cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            height: 32,
                            width: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 16,
                            width: 80,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            height: 32,
                            width: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 16,
                            width: 80,
                            color: Colors.white,
                          ),
                        ],
                      ),
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
}
