import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../../categories/data/category_types.dart';
import '../../categories/logic/repeat_rule.dart';
import '../../categories/models/exam_timeline.dart';
import '../../categories/services/image_upload_service.dart';
import '../../plan/models/plan_item.dart';
import '../../plan/providers/plan_provider.dart';

/// [categoryKey]가 프로필 사진 업로드 UI(§5.5 아기 "프로필 사진 원형
/// 프레임", §5.6 반려동물 "사진+이름 카드형 프로필")를 노출해야 하는지.
bool _hasPhotoUpload(String categoryKey) =>
    categoryKey == 'baby' || categoryKey == 'pet';

/// "항목 추가" 모달 — CLAUDE.md §8(대시보드 카테고리 카드 "+ 추가",
/// 캘린더 탭 "+ 일정 추가").
///
/// haruchip_app.html 726~771줄 `openAddModal()`/`saveNewItem()`을 그대로
/// 재현한다(§5/§6): 제목 input + 날짜 picker + "등록하기" 버튼. 제목이
/// 비어 있으면 저장하지 않고 경고 스낵바만 띄운다.
///
/// 카테고리 & 디데이 커스텀 3단계: 표시방식/반복/캘린더 연동 입력을
/// 추가했다(핸드오프 문서 §1 `DdayItem`).
///
/// [categoryKey]를 파라미터로 받는 재사용 가능한 함수로 만들어 대시보드의
/// 시험(`exam`)/생일(`birthday`)/범용 카드 "+ 추가"와 캘린더 탭의
/// "+ 일정 추가"(`plan` 고정)에서 함께 쓴다. [categoryInstanceId]를 넘기면
/// 해당 [Category] 인스턴스에 항목이 귀속된다(다중 인스턴스 카드 분기용) —
/// 넘기지 않는 기존 호출부는 그대로 legacy(categoryKey만으로 필터링)
/// 항목이 된다. CLAUDE.md 공통 UI 모달 닫기 규칙(X 버튼 / 하단 닫기 버튼 /
/// 배경 클릭)을 모두 지원한다.
Future<bool?> showAddCategoryItemDialog(
  BuildContext context, {
  required String categoryKey,
  String? categoryInstanceId,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _AddCategoryItemDialog(
      categoryKey: categoryKey,
      categoryInstanceId: categoryInstanceId,
    ),
  );
}

String _titleFor(String categoryKey) {
  switch (categoryKey) {
    case 'exam':
      return '시험 / 자격증 추가';
    case 'birthday':
      return '생일 추가';
    case 'pet':
      return '반려동물 기록 추가';
    case 'plan':
      return '일정 추가';
    default:
      return '항목 추가';
  }
}

const List<({DdayDisplayMode mode, String label})> _displayModeOptions = [
  (mode: DdayDisplayMode.dday, label: 'D-Day'),
  (mode: DdayDisplayMode.daysCount, label: 'N일째'),
  (mode: DdayDisplayMode.monthsCount, label: '개월수'),
];

const List<({RepeatType type, String label})> _repeatOptions = [
  (type: RepeatType.none, label: '없음'),
  (type: RepeatType.weekly, label: '매주'),
  (type: RepeatType.monthly, label: '매달'),
  (type: RepeatType.yearly, label: '매년'),
];

const List<({int weekday, String label})> _weekdayOptions = [
  (weekday: DateTime.monday, label: '월'),
  (weekday: DateTime.tuesday, label: '화'),
  (weekday: DateTime.wednesday, label: '수'),
  (weekday: DateTime.thursday, label: '목'),
  (weekday: DateTime.friday, label: '금'),
  (weekday: DateTime.saturday, label: '토'),
  (weekday: DateTime.sunday, label: '일'),
];

class _AddCategoryItemDialog extends ConsumerStatefulWidget {
  const _AddCategoryItemDialog({
    required this.categoryKey,
    this.categoryInstanceId,
  });

  final String categoryKey;
  final String? categoryInstanceId;

  @override
  ConsumerState<_AddCategoryItemDialog> createState() =>
      _AddCategoryItemDialogState();
}

class _AddCategoryItemDialogState
    extends ConsumerState<_AddCategoryItemDialog> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;

  DdayDisplayMode _displayMode = DdayDisplayMode.dday;
  late RepeatType _repeatType;
  List<int> _selectedWeekdays = const [];

  bool _syncGoogle = false;
  bool _syncNaver = false;
  bool _syncHaruchip = false;

  String? _photoUrl;
  bool _uploadingPhoto = false;

  /// 시험 카테고리(§5.4) 전용 타임라인 입력 상태 — stage별로 선택한 날짜만
  /// 채워지고, 나머지는 null(미정)로 남는다.
  final Map<ExamStage, DateTime?> _examTimeline = {
    for (final stage in ExamStage.values) stage: null,
  };

  @override
  void initState() {
    super.initState();
    _repeatType = widget.categoryKey == 'birthday'
        ? RepeatConfig.yearlyDefault.type
        : RepeatConfig.none.type;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTimelineDate(ExamStage stage) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _examTimeline[stage] ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _examTimeline[stage] = picked);
    }
  }

  Future<void> _pickPhoto() async {
    setState(() => _uploadingPhoto = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final url = await ref
          .read(imageUploadServiceProvider)
          .pickAndUpload(folder: widget.categoryKey);
      if (!mounted) return;
      if (url == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('⚠️ 로그인 상태를 확인하거나 사진 선택을 다시 시도해주세요.')),
        );
      } else {
        setState(() => _photoUrl = url);
      }
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('⚠️ 사진 업로드에 실패했습니다. 다시 시도해주세요.')),
      );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  void _toggleWeekday(int weekday) {
    setState(() {
      if (_selectedWeekdays.contains(weekday)) {
        _selectedWeekdays = _selectedWeekdays.where((w) => w != weekday).toList();
      } else {
        _selectedWeekdays = [..._selectedWeekdays, weekday];
      }
    });
  }

  void _handleSave() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 제목을 입력해주세요!')),
      );
      return;
    }
    final examTimelineEntries = <ExamTimelineEntry>[
      for (final entry in _examTimeline.entries)
        if (entry.value != null)
          ExamTimelineEntry(stage: entry.key, date: entry.value!),
    ];
    ref.read(planListProvider.notifier).addItem(
          PlanItem(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: title,
            date: _selectedDate ?? DateTime.now(),
            categoryKey: widget.categoryKey,
            categoryInstanceId: widget.categoryInstanceId,
            displayMode: _displayMode,
            repeatConfig: RepeatConfig(
              type: _repeatType,
              weekdays: _repeatType == RepeatType.weekly ? _selectedWeekdays : const [],
            ),
            calendarSync: CalendarSyncFlags(
              google: _syncGoogle,
              naver: _syncNaver,
              haruchip: _syncHaruchip,
            ),
            examTimeline: examTimelineEntries,
            photoUrl: _photoUrl,
          ),
        );
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(true);
    messenger.showSnackBar(
      const SnackBar(content: Text('✨ 새로운 항목이 추가되었습니다!')),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: AppTypography.caption.copyWith(color: AppColors.protoSubtitle),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.protoCardBg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _titleFor(widget.categoryKey),
                          style: AppTypography.heading2.copyWith(
                            color: AppColors.protoHeading,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: AppColors.protoSubtitle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sectionLabel('제목 / 이름'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleController,
                    style: AppTypography.body.copyWith(
                      color: AppColors.protoHeading,
                    ),
                    decoration: InputDecoration(
                      hintText: ddayTitlePlaceholder[widget.categoryKey] ??
                          ddayTitlePlaceholder['custom']!,
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (_hasPhotoUpload(widget.categoryKey)) ...[
                    const SizedBox(height: 16),
                    _sectionLabel('사진 (선택)'),
                    const SizedBox(height: 8),
                    Center(
                      child: GestureDetector(
                        onTap: _uploadingPhoto ? null : _pickPhoto,
                        child: Container(
                          width: 72,
                          height: 72,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            shape: BoxShape.circle,
                            image: _photoUrl == null
                                ? null
                                : DecorationImage(
                                    image: NetworkImage(_photoUrl!),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          child: _uploadingPhoto
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : _photoUrl == null
                                  ? const Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 22,
                                      color: AppColors.protoStepLabel,
                                    )
                                  : null,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _sectionLabel('날짜'),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            size: 18,
                            color: AppColors.protoStepLabel,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedDate == null
                                ? '날짜를 선택해주세요'
                                : _formatDate(_selectedDate!),
                            style: AppTypography.cardLabel.copyWith(
                              color: AppColors.protoHeading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionLabel('표시방식'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option in _displayModeOptions)
                        _ChoiceChip(
                          label: option.label,
                          selected: _displayMode == option.mode,
                          onTap: () =>
                              setState(() => _displayMode = option.mode),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sectionLabel('반복'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option in _repeatOptions)
                        _ChoiceChip(
                          label: option.label,
                          selected: _repeatType == option.type,
                          onTap: () =>
                              setState(() => _repeatType = option.type),
                        ),
                    ],
                  ),
                  if (_repeatType == RepeatType.weekly) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final option in _weekdayOptions)
                          _ChoiceChip(
                            label: option.label,
                            selected:
                                _selectedWeekdays.contains(option.weekday),
                            onTap: () => _toggleWeekday(option.weekday),
                          ),
                      ],
                    ),
                  ],
                  if (widget.categoryKey == 'exam') ...[
                    const SizedBox(height: 16),
                    _sectionLabel('타임라인 (선택)'),
                    const SizedBox(height: 8),
                    for (final stage in ExamStage.values)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: InkWell(
                          onTap: () => _pickTimelineDate(stage),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    stage.labelKo,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.protoCardText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  _examTimeline[stage] == null
                                      ? '미정'
                                      : _formatDate(_examTimeline[stage]!),
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.protoStepLabel,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 16),
                  _sectionLabel('캘린더 연동'),
                  const SizedBox(height: 4),
                  _SyncCheckboxRow(
                    label: '구글 캘린더',
                    value: _syncGoogle,
                    onChanged: (v) => setState(() => _syncGoogle = v),
                  ),
                  _SyncCheckboxRow(
                    label: '네이버 캘린더',
                    value: _syncNaver,
                    onChanged: (v) => setState(() => _syncNaver = v),
                  ),
                  _SyncCheckboxRow(
                    label: '하루칩 캘린더',
                    value: _syncHaruchip,
                    onChanged: (v) => setState(() => _syncHaruchip = v),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.protoButtonBg,
                        foregroundColor: AppColors.protoButtonText,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('등록하기'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('닫기'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.protoCardSelectedBg
              : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.protoCardSelectedBorder
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: selected
                ? AppColors.protoCardSelectedText
                : AppColors.protoCardText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SyncCheckboxRow extends StatelessWidget {
  const _SyncCheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: AppColors.protoButtonBg,
              checkColor: AppColors.protoButtonText,
            ),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.protoCardText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
