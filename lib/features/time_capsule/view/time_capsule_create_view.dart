import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/app_images.dart';
import 'package:lumina/features/time_capsule/controller/time_capsule_controller.dart';
import 'package:lumina/features/time_capsule/widgets/preset_chip.dart';

class TimeCapsuleCreateView extends GetView<TimeCapsuleController> {
  const TimeCapsuleCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppImages.bookpage, fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xff32402F),
                          ),
                          onPressed: () => Get.back(),
                        ),
                        Expanded(
                          child: Text(
                            'Time Capsule',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff32402F),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Icon(
                          Icons.eco,
                          size: 16,
                          color: Color(0xff8D7B69),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Write a message to your future self',
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xff8D7B69),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xffF7EFDD),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xffE4D3B0),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          TextField(
                            maxLines: null,
                            minLines: 5,
                            onChanged: controller.updateMessage,
                            style: const TextStyle(
                              fontFamily: 'Lora',
                              fontStyle: FontStyle.italic,
                              fontSize: 15,
                              height: 1.7,
                              color: Color(0xff3E2E1A),
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Dear future me...',
                              hintStyle: TextStyle(
                                fontFamily: 'Lora',
                                fontStyle: FontStyle.italic,
                                color: Color(0xffB2A280),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: Color(0xff8D7B69),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Unlocks on',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xff8D7B69),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final date = controller.unlockDate.value;
                      return GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: date ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) controller.setCustomDate(picked);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffF7EFDD),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xffE4D3B0),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Color(0xff32402F),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                date != null
                                    ? DateFormat('d MMM yyyy').format(date)
                                    : 'Select date',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff32402F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 14),

                    Obx(
                      () => Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: controller.presets.map((preset) {
                          return PresetChip(
                            label: preset,
                            selected: controller.selectedPreset.value == preset,
                            onTap: () => controller.selectPreset(preset),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // TODO: apply share with partner in next update

                    // Obx(() => Row(
                    //       children: [
                    //         const Icon(Icons.people_outline, size: 18, color: Color(0xff32402F)),
                    //         const SizedBox(width: 8),
                    //         const Expanded(
                    //           child: Text(
                    //             'Share with partner\nwhen unlocked',
                    //             style: TextStyle(fontSize: 14),
                    //           ),
                    //         ),
                    //         Switch(
                    //           value: controller.shareWithPartner.value,
                    //           activeThumbColor: AppColors.primaryGreen,
                    //           onChanged: controller.toggleShare,
                    //         ),
                    //       ],
                    //     )),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.sealCapsule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(color: AppColors.accentGold),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.eco, size: 16, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Seal Capsule',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // TextButton(
                    //   onPressed: controller.debugTestNotificationInOneMinute,
                    //   child: const Text('DEBUG: Test notification in 1 min'),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
