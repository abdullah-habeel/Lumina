import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/bottom_navigation_bar.dart';
import 'package:lumina/core/controller/journal_controller.dart';
import 'package:lumina/features/ai_log/view/ai_log_view.dart';
import 'package:lumina/features/auth/binding/auth_binding.dart';
import 'package:lumina/features/auth/view/login_view.dart';
import 'package:lumina/features/auth/view/register_view.dart';
import 'package:lumina/features/auth/view/username_view.dart';
import 'package:lumina/features/chapter_detail/model/binding/chapter_detail_binding.dart';
import 'package:lumina/features/home/binding/home_binding.dart';
import 'package:lumina/features/home/view/home_view.dart';
import 'package:lumina/features/home/view/memory_detail_view.dart';
import 'package:lumina/features/home/view/memory_tree_view.dart';
import 'package:lumina/features/library/library_view.dart';
import 'package:lumina/features/music/view/music_selection_view.dart';
import 'package:lumina/features/music/view/sound_selection_view.dart';
import 'package:lumina/features/notification/binding/notification_binding.dart';
import 'package:lumina/features/notification/view/notification_view.dart';
import 'package:lumina/features/onboarding/view/onboarding_view.dart';
import 'package:lumina/features/onboarding/screens/breath_screen_view.dart';
import 'package:lumina/features/pin/binding/pin_binding.dart';
import 'package:lumina/features/pin/view/choose_pin_view.dart';
import 'package:lumina/features/pin/view/verify_current_pin_view.dart';
import 'package:lumina/features/profile/binding/profile_binding.dart';
import 'package:lumina/features/profile/controller/edit_profile_controller.dart';
import 'package:lumina/features/profile/view/edit_profile_view.dart';
import 'package:lumina/features/profile/view/profile_view.dart';
import 'package:lumina/features/questions/view/chapter_detail_view.dart';
import 'package:lumina/features/shared/binding/shared_binding.dart';
import 'package:lumina/features/shared/view/add_someone_view.dart';
import 'package:lumina/features/shared/view/choose_memory_view.dart';
import 'package:lumina/features/shared/view/people_i_trust_view.dart';
import 'package:lumina/features/shared/view/person_history_view.dart';
import 'package:lumina/features/shared/view/receieved_share_page.dart';
import 'package:lumina/features/shared/view/review_share_view.dart';
import 'package:lumina/features/shared/view/share_success_view.dart';
import 'package:lumina/features/shared/view/shared_home_view.dart';
import 'package:lumina/features/splash/binding/splash_binding.dart';
import 'package:lumina/features/splash/view/splash_view.dart';
import 'package:lumina/features/story/view/story_view.dart';
import 'package:lumina/features/time_capsule/binding/time_capsule_binding.dart';
import 'package:lumina/features/time_capsule/binding/time_capsule_list_bindig.dart';
import 'package:lumina/features/time_capsule/view/time_capsule_create_view.dart';
import 'package:lumina/features/time_capsule/view/time_capsule_list_view.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final pages = [
    // GetPage(name: AppRoutes.onboarding, page: () =>  OnboardingView()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingView()),
    GetPage(
      name: AppRoutes.breatheScreen,
      page: () => const BreatheScreenView(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.usernameSetup,
      page: () => const UsernameSetupView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    
    GetPage(
      name: AppRoutes.floatbook,
      page: () => const LibraryView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.chapterdetail,
      page: () => const ChapterDetailView(),
      binding: ChapterDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const BottomNavScreen(),
      binding: HomeBinding(), // keeps your existing HomeController setup
    ),
    GetPage(
      name: AppRoutes.timeCapsuleList,
      page: () => const TimeCapsuleListView(),
      binding: TimeCapsuleListBinding(),
    ),
    GetPage(
      name: AppRoutes.timeCapsuleCreate,
      page: () => const TimeCapsuleCreateView(),
      binding: TimeCapsuleBinding(),
    ),
    GetPage(
      name: AppRoutes.sharedHome,
      page: () => const SharedHomeView(),
      binding: SharedBinding(),
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(name: AppRoutes.peopleITrust, page: () => const PeopleITrustView()),
    GetPage(name: AppRoutes.addSomeone, page: () => const AddSomeoneView()),
    GetPage(name: AppRoutes.chooseMemory, page: () => const ChooseMemoryView()),
    GetPage(name: AppRoutes.reviewShare, page: () => const ReviewShareView()),
    GetPage(name: AppRoutes.shareSuccess, page: () => const ShareSuccessView()),
    GetPage(
      name: AppRoutes.receivedSharedPage,
      page: () => const ReceivedSharedPageView(),
    ),
    GetPage(
      name: AppRoutes.personHistory,
      page: () => const PersonHistoryView(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(name: AppRoutes.music, page: () => const MusicSelectionView()),
    GetPage(name: AppRoutes.sound, page: () => const SoundSelectionView()),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: AppRoutes.choosePin,
      page: () => const ChoosePinView(),
      binding: PinBinding(),
    ),
    GetPage(
      name: AppRoutes.verifyCurrentPin,
      page: () => const VerifyCurrentPinView(),
      binding: PinBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileView(),
      binding: BindingsBuilder(() {
        Get.put(EditProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.memoryTree,
      page: () => const MemoryTreeView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(name: AppRoutes.memoryDetail, page: () => const MemoryDetailView()),
     GetPage(name: AppRoutes.tellMyStory, page: () => const StoryView()),
     GetPage(name: AppRoutes.aiLog, page: () => const AiLogView()),
    
  ];
}
