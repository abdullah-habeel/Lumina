import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/widgets/time_aware_background.dart';
import 'package:lumina/core/routes/model/journel_entry_model.dart';
import 'package:lumina/features/book_display/view/book_display_view.dart';
import 'package:lumina/features/write_answer/widgets/save_memory_button.dart';

import '../widgets/answer_input_field.dart';
import '../widgets/question_card.dart';

class WriteAnswerScreen extends StatefulWidget {
  final String question;
  final DateTime date;
  final String chapterId;
  final String questionId;
  final String initialAnswer;

  const WriteAnswerScreen({
    super.key,
    required this.question,
    required this.date,
    required this.chapterId,
    required this.questionId,
    this.initialAnswer = '',
  });

  @override
  State<WriteAnswerScreen> createState() => _WriteAnswerScreenState();
}

class _WriteAnswerScreenState extends State<WriteAnswerScreen> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialAnswer,
  );

  final List<String> _imagePaths = [];
  bool _isSaving = false;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String get _month => _months[widget.date.month - 1];
  String get _day => '${widget.date.day}';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final remaining = 3 - _imagePaths.length;
    if (remaining <= 0) return;

    final picked = await showPhotoSourceSheet(context);
    if (picked.isNotEmpty) {
      setState(() {
        _imagePaths.addAll(picked.take(remaining));
      });
    }
  }

  void _removePhoto(int index) {
    setState(() => _imagePaths.removeAt(index));
  }

  Future<void> _saveMemory() async {
    if (_isSaving) return;
    _isSaving = true;
    setState(() {});

    final answerText = _controller.text.trim();

    final entry = JournalEntry(
      chapterId: widget.chapterId,
      questionId: widget.questionId,
      date: widget.date,
      question: widget.question,
      body: answerText.isEmpty ? null : answerText,
      imagePaths: List.of(_imagePaths),
    );

    try {
      if (!mounted) return;

      Get.to(
        () => BookScreen(
          entries: [entry],
          isReadOnly: false,
          saveOnButtonTap: true,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your entry. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TimeAwareBookBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Column(
                children: [
                  const _WriteAnswerAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: QuestionCard(
                              question: widget.question,
                              month: _month,
                              day: _day,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          AnswerInputField(controller: _controller),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: SaveMemoryButton(
                      isLoading: _isSaving,
                      onPressed: _isSaving ? null : _saveMemory,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WriteAnswerAppBar extends StatelessWidget {
  const _WriteAnswerAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.primaryGreen,
              size: 28,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Expanded(
            child: Text(
              'Write Answer',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

Future<List<String>> showPhotoSourceSheet(BuildContext context) async {
  final picker = ImagePicker();

  return await showModalBottomSheet<List<String>>(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Photo Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.primaryGreen),
                title: Text(
                  'Camera',
                  style: TextStyle(color: AppColors.primaryGreen),
                ),
                onTap: () async {
                  final photo = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  if (context.mounted) {
                    Navigator.pop(
                      context,
                      photo != null ? <String>[photo.path] : <String>[],
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.image, color: AppColors.primaryGreen),
                title: Text(
                  'Gallery',
                  style: TextStyle(color: AppColors.primaryGreen),
                ),
                onTap: () async {
                  final photos = await picker.pickMultiImage(imageQuality: 80);
                  if (context.mounted) {
                    Navigator.pop(context, photos.map((p) => p.path).toList());
                  }
                },
              ),
            ],
          ),
        ),
      ) ??
      <String>[];
}
