import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:tech_pulse/ui/controllers/home_page_controller.dart';
import 'package:tech_pulse/ui/widgets/home/article_card.dart';
import 'package:tech_pulse/ui/widgets/home/stacked_news_head_image.dart';
import 'package:tech_pulse/ui/widgets/home/static_grid.dart';

class HomePage extends GetView<HomePageController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GetBuilder<HomePageController>(
      init: HomePageController(),
      builder: (controller) {
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, bool arg) => [
              SliverAppBar.medium(
                pinned: true,
                leading: IconButton(
                  onPressed: controller.onAvatarPressed,
                  icon: Obx(
                    () => Hero(
                      tag: ValueKey('MyAvatarHero'),
                      child: controller.getAvatar(),
                    ),
                  ),
                ),
                title: Text(
                  'TechPulse',
                  style: textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                bottom: TabBar(
                  controller: controller.tabController,
                  tabs: controller.tabs.map((tab) => Tab(text: tab)).toList(),
                  isScrollable: true,
                  enableFeedback: true,
                ),
                leadingWidth: 60,
                actionsPadding: EdgeInsets.symmetric(horizontal: 16.0),
                actions: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.search)),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    icon: Badge(
                      label: Text('99+'),
                      child: Icon(Icons.chat_bubble),
                    ),
                  ),
                ],
              ),
            ],
            body: TabBarView(
              controller: controller.tabController,
              children: List<Widget>.generate(
                controller.tabs.length,
                (tabIndex) => HomePageTab(tabIndex: tabIndex),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HomePageTab extends StatelessWidget {
  const HomePageTab({super.key, required this.tabIndex});

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomePageController>(
      init: HomePageController(),
      id: ValueKey(tabIndex),
      builder: (controller) {
        final carouselArticle = controller.getCarouselArticle(tabIndex);
        return RefreshIndicator(
          onRefresh: () async => controller.forceRefreshArticles(tabIndex),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (carouselArticle != null)
                  StackedNewsHeadImage(
                    carouselArticle,
                    heroTag: UniqueKey(),
                  ),
                StaticGrid(
                  columnCount: 2,
                  children: controller
                      .getTabContent(tabIndex)
                      .map<Widget>(
                        (article) => ArticleCardWidget(
                          article,
                          heroTag: UniqueKey(),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
