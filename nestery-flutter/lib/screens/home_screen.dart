import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/providers/property_provider.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/widgets/custom_button.dart';
import 'package:nestery_flutter/widgets/loading_overlay.dart';
import 'package:nestery_flutter/widgets/property_card.dart';
import 'package:nestery_flutter/widgets/search_bar.dart';
import 'package:nestery_flutter/widgets/section_title.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Hotels', 'Apartments', 'Villas', 'Resorts'];

  @override
  void initState() {
    super.initState();
    // Load featured properties when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(featuredPropertiesProvider.notifier).loadFeaturedProperties();
      ref.read(recommendedPropertiesProvider.notifier).loadRecommendedProperties();
    });
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
              await ref.read(featuredPropertiesProvider.notifier).loadFeaturedProperties();
              await ref.read(recommendedPropertiesProvider.notifier).loadRecommendedProperties();
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
                    child: SearchBar(
                      readOnly: true,
                      onTap: () {
                        context.go('/search');
                      },
                      onFilterTap: () {
                        // Show filter sheet
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          builder: (context) => FilterSheet(
                            initialFilters: {},
                            onApply: (filters) {
                              // Apply filters
                              context.go('/search', extra: filters);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Categories
                SliverToBoxAdapter(
                  child: CategorySelector(
                    categories: _categories,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      // Filter properties by category
                    },
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
                    child: featuredProperties.error != null
                        ? ErrorRetryWidget(
                            message: featuredProperties.error!,
                            onRetry: () {
                              ref.read(featuredPropertiesProvider.notifier).loadFeaturedProperties();
                            },
                          )
                        : featuredProperties.properties.isEmpty && !featuredProperties.isLoading
                            ? const EmptyStateWidget(
                                title: 'No Featured Properties',
                                message: 'We couldn\'t find any featured properties at the moment.',
                                icon: Icons.home_work_outlined,
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: featuredProperties.isLoading
                                    ? 3
                                    : featuredProperties.properties.length,
                                itemBuilder: (context, index) {
                                  if (featuredProperties.isLoading) {
                                    return Container(
                                      width: 280,
                                      margin: const EdgeInsets.only(right: 16),
                                      child: const PropertyCardShimmer(),
                                    );
                                  }

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
                      if (recommendedProperties.isLoading) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: PropertyCardShimmer(isHorizontal: true),
                        );
                      }

                      if (recommendedProperties.error != null) {
                        return ErrorRetryWidget(
                          message: recommendedProperties.error!,
                          onRetry: () {
                            ref.read(recommendedPropertiesProvider.notifier).loadRecommendedProperties();
                          },
                        );
                      }

                      if (recommendedProperties.properties.isEmpty) {
                        return const EmptyStateWidget(
                          title: 'No Recommendations Yet',
                          message: 'We\'ll recommend properties based on your preferences and browsing history.',
                          icon: Icons.recommend_outlined,
                        );
                      }

                      final property = recommendedProperties.properties[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: PropertyCard(
                          property: property,
                          isHorizontal: true,
                          onTap: () {
                            context.go('/property/${property.id}');
                          },
                        ),
                      );
                    },
                    childCount: recommendedProperties.isLoading
                        ? 3
                        : recommendedProperties.error != null || recommendedProperties.properties.isEmpty
                            ? 1
                            : recommendedProperties.properties.length,
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
