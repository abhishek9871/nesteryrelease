import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/providers/property_provider.dart';
import 'package:nestery_flutter/providers/missing_providers.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:nestery_flutter/widgets/loading_overlay.dart';
import 'package:nestery_flutter/widgets/property_card.dart';
import 'package:nestery_flutter/widgets/section_title.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Hotels', 'Apartments', 'Villas', 'Resorts'];

  @override
  void initState() {
    super.initState();
    // FutureProviders automatically load when watched, no manual loading needed
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final featuredProperties = ref.watch(featuredPropertiesProvider);
    final recommendedProperties = ref.watch(recommendedPropertiesProvider);

    return Scaffold(
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: featuredProperties.isLoading && recommendedProperties.isLoading,
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(featuredPropertiesProvider);
              ref.invalidate(recommendedPropertiesProvider);
            },
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  snap: true,
                  title: Row(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nestery',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        // Navigate to notifications
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_outline),
                      onPressed: () {
                        context.go('/profile');
                      },
                    ),
                  ],
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () {
                        context.go('/search');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Search properties...',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.tune,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Categories
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = category == _selectedCategory;
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Featured Properties
                SliverToBoxAdapter(
                  child: SectionTitle(
                    title: 'Featured Properties',
                    subtitle: 'Handpicked properties for you',
                    onSeeAllPressed: () {
                      context.go('/search', extra: {'featured': true});
                    },
                  ),
                ),

                // Featured Properties List
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 300,
                    child: featuredProperties.isLoading
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 280,
                                margin: const EdgeInsets.only(right: 16),
                                child: const Card(
                                  child: SizedBox(height: 200),
                                ),
                              );
                            },
                          )
                        : featuredProperties.error != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Error: ${featuredProperties.error}'),
                                    ElevatedButton(
                                      onPressed: () {
                                        ref.read(featuredPropertiesProvider.notifier).loadFeaturedProperties();
                                      },
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            : featuredProperties.properties.isEmpty
                                ? const Center(
                                    child: Text('No featured properties available'),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: featuredProperties.properties.length,
                                    itemBuilder: (context, index) {
                                      final property = featuredProperties.properties[index];
                                      return Container(
                                        width: 280,
                                        margin: const EdgeInsets.only(right: 16),
                                        child: PropertyCard(
                                          property: property,
                                          onTap: () {
                                            context.go('/property/${property.id}');
                                          },
                                        ),
                                      );
                                    },
                                  ),
                  ),
                ),

                // Recommended Properties
                SliverToBoxAdapter(
                  child: SectionTitle(
                    title: 'Recommended for You',
                    subtitle: 'Based on your preferences',
                    onSeeAllPressed: () {
                      context.go('/search', extra: {'recommended': true});
                    },
                  ),
                ),

                // Recommended Properties List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return recommendedProperties.when(
                        data: (properties) {
                          if (properties.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text('No recommendations available'),
                              ),
                            );
                          }
                          if (index >= properties.length) return const SizedBox.shrink();

                          final property = properties[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: PropertyCard(
                              property: property,
                              isHorizontal: true,
                              onTap: () {
                                context.go('/property/${property.id}');
                              },
                            ),
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Card(
                            child: SizedBox(height: 120),
                          ),
                        ),
                        error: (error, stack) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Column(
                              children: [
                                Text('Error: ${error.toString()}'),
                                ElevatedButton(
                                  onPressed: () {
                                    ref.invalidate(recommendedPropertiesProvider);
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: recommendedProperties.when(
                      data: (properties) => properties.isEmpty ? 1 : properties.length,
                      loading: () => 3,
                      error: (_, __) => 1,
                    ),
                  ),
                ),

                // Special Offers
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Constants.primaryColor,
                            Constants.secondaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Image.asset(
                              'assets/images/offer_illustration.png',
                              height: 120,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Special Offer',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Get 20% off on your first booking',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                CustomButton(
                                  text: 'Book Now',
                                  onPressed: () {
                                    // Navigate to special offers
                                  },
                                  backgroundColor: Colors.white,
                                  textColor: Constants.primaryColor,
                                  height: 36,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
