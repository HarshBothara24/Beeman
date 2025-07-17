import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SkeletonLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? AppTheme.dividerColor;
    final highlightColor = widget.highlightColor ?? AppTheme.backgroundColor;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                0.0,
                0.5,
                1.0,
              ],
              transform: GradientRotation(_animation.value * 3.14159 / 4),
            ),
          ),
        );
      },
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final bool showAvatar;
  final bool showTitle;
  final bool showSubtitle;
  final bool showButton;
  final int lineCount;

  const SkeletonCard({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.showAvatar = false,
    this.showTitle = true,
    this.showSubtitle = true,
    this.showButton = false,
    this.lineCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAvatar) ...[
            Row(
              children: [
                const SkeletonLoading(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoading(
                        width: double.infinity,
                        height: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      SkeletonLoading(
                        width: 120,
                        height: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (showTitle) ...[
            SkeletonLoading(
              width: double.infinity,
              height: 20,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
          ],
          if (showSubtitle) ...[
            ...List.generate(
              lineCount,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index < lineCount - 1 ? 8 : 0),
                child: SkeletonLoading(
                  width: index == lineCount - 1 ? 200 : double.infinity,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (showButton) ...[
            const Spacer(),
            SkeletonLoading(
              width: 100,
              height: 36,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ],
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets? padding;
  final bool showAvatar;
  final bool showTrailing;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
    this.showAvatar = true,
    this.showTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return Container(
          height: itemHeight,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (showAvatar) ...[
                const SkeletonLoading(
                  width: 48,
                  height: 48,
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SkeletonLoading(
                      width: double.infinity,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    SkeletonLoading(
                      width: 200,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              if (showTrailing) ...[
                const SizedBox(width: 16),
                const SkeletonLoading(
                  width: 24,
                  height: 24,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class SkeletonGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final EdgeInsets? padding;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const SkeletonGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.padding,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const SkeletonCard(
          showTitle: true,
          showSubtitle: true,
          lineCount: 1,
        );
      },
    );
  }
}

class SkeletonDashboard extends StatelessWidget {
  const SkeletonDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: CustomScrollView(
          slivers: [
            // App Bar Skeleton
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: const SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SkeletonLoading(
                            width: 120,
                            height: 16,
                            baseColor: Colors.white24,
                            highlightColor: Colors.white38,
                          ),
                          SizedBox(height: 8),
                          SkeletonLoading(
                            width: 200,
                            height: 24,
                            baseColor: Colors.white24,
                            highlightColor: Colors.white38,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content Skeleton
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card Skeleton
                    const SkeletonCard(
                      height: 100,
                      showAvatar: true,
                      showTitle: true,
                      showSubtitle: true,
                      lineCount: 1,
                    ),
                    const SizedBox(height: 24),

                    // Stats Row Skeleton
                    Row(
                      children: [
                        Expanded(
                          child: SkeletonCard(
                            height: 80,
                            showTitle: true,
                            showSubtitle: true,
                            lineCount: 1,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SkeletonCard(
                            height: 80,
                            showTitle: true,
                            showSubtitle: true,
                            lineCount: 1,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SkeletonCard(
                            height: 80,
                            showTitle: true,
                            showSubtitle: true,
                            lineCount: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Section Header Skeleton
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonLoading(
                          width: 150,
                          height: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        SkeletonLoading(
                          width: 80,
                          height: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Grid Skeleton
                    const SkeletonGrid(
                      itemCount: 4,
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}