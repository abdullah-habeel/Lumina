import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_background.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/core/routes/constants/widgets/time_aware_background.dart';
import 'package:lumina/core/utils/notification_dot.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:lumina/features/profile/widgets/animated_menu_tile.dart';
import 'package:lumina/features/shared/model/shared_model.dart';
import 'package:lumina/features/shared/view/receieved_share_page.dart';
import 'package:lumina/features/shared/widgets/dashed_action_button.dart';
import 'package:lumina/features/shared/widgets/paper_open_card.dart';
import 'package:lumina/features/shared/widgets/share_card/share_page_card.dart';
import 'package:lumina/features/shared/widgets/shared_delete_sheet.dart';

import '../controller/shared_controller.dart';
import '../controller/shared_memory_controller.dart';

class SharedHomeView extends StatefulWidget {
  const SharedHomeView({super.key});

  @override
  State<SharedHomeView> createState() => SharedHomeViewState();
}

class SharedHomeViewState extends State<SharedHomeView> {
  int _rebuildKey = 0;

  void replayAnimation() {
    setState(() => _rebuildKey++);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SharedController>();
    final memoryController = Get.find<SharedMemoryController>();

    return DefaultTabController(
      key: ValueKey(_rebuildKey),
      length: 2,
      child: TimeAwareBookBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: AppColors.primaryGreen),
            title: Builder(
              builder: (context) => Text(
                'Shared',
                style: GoogleFonts.fraunces(
                  color: DaylightAppColors.bookTitleText(
                    DaylightTime.of(context),
                  ),
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  // letterSpacing: 0.2,
                ),
              ),
            ),
            actions: [
              Obx(
                () => IconButton(
                  icon: NotificationDot(
                    show: controller.incomingRequests.isNotEmpty,
                    child: const Icon(Icons.people_alt_outlined),
                  ),
                  onPressed: () => Get.toNamed(AppRoutes.peopleITrust),
                ),
              ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(74),
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: _SharedTabSelector(),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              _ReceivedTab(
                controller: controller,
                memoryController: memoryController,
              ),
              _SentTab(memoryController: memoryController),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CUSTOM SHARED TAB SELECTOR
// ============================================================================
class _SharedTabSelector extends StatelessWidget {
  const _SharedTabSelector();

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.of(context);

    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        final selected = tabController.index;

        return SizedBox(
          height: 48,
          child: Row(
            children: [
              Expanded(
                child: _PaperTab(
                  label: 'Received',
                  selected: selected == 0,
                  onTap: () => tabController.animateTo(0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PaperTab(
                  label: 'Sent',
                  selected: selected == 1,
                  onTap: () => tabController.animateTo(1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PaperTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PaperTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2F4A3A) : const Color(0xFFF3E9D5),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? const Color(0xFF2F4A3A) : const Color(0xFFC4A574),
            width: 1,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontStyle: selected ? FontStyle.italic : FontStyle.normal,
            color: selected ? const Color(0xFFF7EED8) : const Color(0xFF5C4A2A),
          ),
        ),
      ),
    );
  }
}

class _ReceivedTab extends StatefulWidget {
  final SharedController controller;
  final SharedMemoryController memoryController;

  const _ReceivedTab({
    required this.controller,
    required this.memoryController,
  });

  @override
  State<_ReceivedTab> createState() => _ReceivedTabState();
}

class _ReceivedTabState extends State<_ReceivedTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<SharedDeleteScope?> _chooseDeleteScope(SharedPage page) {
    return showSharedDeleteSheet(context, page: page, allowEveryone: false);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView(
        padding: const EdgeInsets.only(
          top: 10,
          left: 15,
          right: 15,
        ).copyWith(bottom: 120 + MediaQuery.of(context).viewPadding.bottom),
        children: [
          if (widget.memoryController.receivedPages.isEmpty)
            const _SharedEmptyState(
              icon: Icons.mail_outline_rounded,
              message:
                  'When someone shares a memory with you, it will rest here for you to keep.',
            ),
          ...widget.memoryController.receivedPages.asMap().entries.map(
            (entry) => AnimatedMenuTile(
              index: entry.key,
              controller: _animController,
              child: Hero(
                tag: 'shared-card-${entry.value.id}',
                child: SharedPageCard(
                  key: ValueKey(entry.value.id),
                  page: entry.value,
                  onTap: () => PaperOpenTransition.open(
                    context,
                    destination: ReceivedSharedPageView(
                      initialPage: entry.value,
                    ),
                  ),
                  onChooseDeleteScope: _chooseDeleteScope,
                  onDelete: widget.memoryController.deleteSharedPage,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedMenuTile(
            index: widget.memoryController.receivedPages.length,
            controller: _animController,
            child: DoubleBorderActionButton(
              label: 'Add someone',
              onPressed: () => Get.toNamed(AppRoutes.addSomeone),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SENT TAB
// ============================================================================

class _SentTab extends StatefulWidget {
  final SharedMemoryController memoryController;

  const _SentTab({required this.memoryController});

  @override
  State<_SentTab> createState() => _SentTabState();
}

class _SentTabState extends State<_SentTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<SharedDeleteScope?> _chooseDeleteScope(SharedPage page) {
    return showSharedDeleteSheet(context, page: page, allowEveryone: true);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView(
        padding: const EdgeInsets.only(
          top: 10,
          left: 15,
          right: 15,
        ).copyWith(bottom: 120 + MediaQuery.of(context).viewPadding.bottom),
        children: [
          if (widget.memoryController.sentPages.isEmpty)
            const _SharedEmptyState(
              icon: Icons.favorite_border_rounded,
              message: 'Share your memory with someone whom you care',
            ),
          ...widget.memoryController.sentPages.asMap().entries.map(
            (entry) => AnimatedMenuTile(
              index: entry.key,
              controller: _animController,
              child: SharedPageCard(
                key: ValueKey(entry.value.id),
                page: entry.value,
                onTap: () => PaperOpenTransition.open(
                  context,
                  destination: ReceivedSharedPageView(initialPage: entry.value),
                ),
                onChooseDeleteScope: _chooseDeleteScope,
                onDelete: widget.memoryController.deleteSharedPage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SharedEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _SharedEmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 76, 24, 54),
      child: Column(
        children: [
          Icon(icon, size: 38, color: const Color(0xFF8D7954)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.fraunces(
              color: const Color(0xFF5C4A2A),
              fontSize: 17,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
