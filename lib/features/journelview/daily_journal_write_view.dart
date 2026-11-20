import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/core/routes/constants/widgets/time_aware_background.dart';
import 'package:lumina/core/routes/model/journel_entry_model.dart';
import 'package:lumina/features/book_display/view/book_display_view.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:lumina/features/write_answer/controller/voice_input_controller.dart';
import 'package:lumina/features/write_answer/widgets/answer_input_field.dart';
import 'package:lumina/features/write_answer/widgets/question_card.dart';
import 'package:lumina/features/write_answer/widgets/save_memory_button.dart';

class DailyJournalWriteScreen extends StatefulWidget {
  final DateTime date;
  final String initialEntry;
  final String initialHeading;

  const DailyJournalWriteScreen({
    super.key,
    required this.date,
    this.initialEntry = '',
    this.initialHeading = '',
  });

  @override
  State<DailyJournalWriteScreen> createState() =>
      _DailyJournalWriteScreenState();
}

class _DailyJournalWriteScreenState extends State<DailyJournalWriteScreen> {
  late final TextEditingController _bodyController = TextEditingController(
    text: widget.initialEntry,
  );
  late final TextEditingController _headingController = TextEditingController(
    text: widget.initialHeading,
  );
  String _baseText = '';

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
  void initState() {
    super.initState();

    final voiceCtrl = Get.put(VoiceInputController());

    ever(voiceCtrl.isListening, (listening) {
      if (listening) {
        _baseText = _bodyController.text;
        if (_baseText.isNotEmpty && !_baseText.endsWith(' ')) {
          _baseText += ' ';
        }
      }
    });

    ever(voiceCtrl.transcribedText, (text) {
      if (!voiceCtrl.isListening.value || text.isEmpty) return;

      final updatedText = _baseText + text;

      if (updatedText.length < _bodyController.text.length) return;

      _bodyController.value = TextEditingValue(
        text: updatedText,
        selection: TextSelection.collapsed(offset: updatedText.length),
      );
    });
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _headingController.dispose();
    Get.delete<VoiceInputController>();
    super.dispose();
  }

  // NOTE: now takes an explicit context — pass the correctly-scoped
  // one from inside the tree (below DaylightPlainBackground), not
  // the State's own `context`.
  Future<void> _pickPhotos(BuildContext context) async {
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

  Future<void> _saveEntry(BuildContext context) async {
    if (_isSaving) return;

    final body = _bodyController.text.trim();
    final heading = _headingController.text.trim();

    if (body.isEmpty || heading.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add both a title and an entry before saving.'),
        ),
      );
      return;
    }

    _isSaving = true;
    setState(() {});

    final entry = JournalEntry(
      chapterId: 'daily_journal',
      questionId: _dailyQuestionId(widget.date),
      date: widget.date,
      question: heading,
      body: body,
      imagePaths: List.of(_imagePaths),
    );

    try {
      if (!mounted) return;

      Get.to(
        () => BookScreen(
          entries: [entry],
          initialIndex: 0,
          saveOnButtonTap: true,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save entry: $error')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  static String _dailyQuestionId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}-${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    return TimeAwareBookBackground(
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                _DailyJournalAppBar(onSave: () => _saveEntry(context)),

                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: QuestionCard(
                            headingController: _headingController,
                            month: _month,
                            day: _day,
                          ),
                        ),
                        const SizedBox(height: 16),
                        

                        const SizedBox(height: 16),
                        AnswerInputField(
                          controller: _bodyController,
                          onVoiceText: (text) {
                            final current = _bodyController.text;
                            final needsSpace =
                                current.isNotEmpty && !current.endsWith(' ');
                            _bodyController.text =
                                '${current}${needsSpace ? ' ' : ''}$text';
                            _bodyController
                                .selection = TextSelection.fromPosition(
                              TextPosition(offset: _bodyController.text.length),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(18),
                  child: SaveMemoryButton(
                    isLoading: _isSaving,
                    onPressed: _isSaving ? null : () => _saveEntry(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyJournalAppBar extends StatelessWidget {
  final VoidCallback onSave;

  const _DailyJournalAppBar({required this.onSave});

  @override
  Widget build(BuildContext context) {
    final hour = DaylightTime.of(context);
    final headingColor = DaylightAppColors.headingText(hour);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: headingColor, size: 28),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Expanded(
              child: Text(
                'Daily Journal',
                textAlign: TextAlign.center,
                style: GoogleFonts.fraunces(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: headingColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<List<String>> showPhotoSourceSheet(BuildContext context) async {
  final picker = ImagePicker();
  final hour = DaylightTime.of(context);
  final cardBg = DaylightAppColors.cardBackground(hour);
  final accent = DaylightAppColors.accentGold(hour);
  final textColor = DaylightAppColors.cardText(hour);

  return await showModalBottomSheet<List<String>>(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
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
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt, color: accent),
                title: Text('Camera', style: TextStyle(color: textColor)),
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
                leading: Icon(Icons.image, color: accent),
                title: Text('Gallery', style: TextStyle(color: textColor)),
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
