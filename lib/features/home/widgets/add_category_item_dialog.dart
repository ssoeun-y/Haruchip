import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../../plan/models/plan_item.dart';
import '../../plan/providers/plan_provider.dart';

/// "항목 추가" 모달 — CLAUDE.md §8(대시보드 카테고리 카드 "+ 추가",
/// 캘린더 탭 "+ 일정 추가").
///
/// haruchip_app.html 726~771줄 `openAddModal()`/`saveNewItem()`을 그대로
/// 재현한다(§5/§6): 제목 input + 날짜 picker + "등록하기" 버튼. 제목이
/// 비어 있으면 저장하지 않고 경고 스낵바만 띄운다.
///
/// [categoryKey]를 파라미터로 받는 재사용 가능한 함수로 만들어 대시보드의
/// 시험(`exam`)/생일(`birthday`) 카드 "+ 추가"와 캘린더 탭의 "+ 일정 추가"
/// (`plan` 고정)에서 함께 쓴다. CLAUDE.md 공통 UI 모달 닫기 규칙(X 버튼 /
/// 하단 닫기 버튼 / 배경 클릭)을 모두 지원한다.
Future<bool?> showAddCategoryItemDialog(
  BuildContext context, {
  required String categoryKey,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _AddCategoryItemDialog(categoryKey: categoryKey),
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

class _AddCategoryItemDialog extends ConsumerStatefulWidget {
  const _AddCategoryItemDialog({required this.categoryKey});

  final String categoryKey;

  @override
  ConsumerState<_AddCategoryItemDialog> createState() =>
      _AddCategoryItemDialogState();
}

class _AddCategoryItemDialogState
    extends ConsumerState<_AddCategoryItemDialog> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;

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

  void _handleSave() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 제목을 입력해주세요!')),
      );
      return;
    }
    ref.read(planListProvider.notifier).addItem(
          PlanItem(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: title,
            date: _selectedDate ?? DateTime.now(),
            categoryKey: widget.categoryKey,
          ),
        );
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(true);
    messenger.showSnackBar(
      const SnackBar(content: Text('✨ 새로운 항목이 추가되었습니다!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
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
              Text(
                '제목 / 이름',
                style: AppTypography.caption.copyWith(
                  color: AppColors.protoSubtitle,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                style: AppTypography.body.copyWith(
                  color: AppColors.protoHeading,
                ),
                decoration: InputDecoration(
                  hintText: '예: 정보처리기사 실기',
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
              const SizedBox(height: 16),
              Text(
                '날짜',
                style: AppTypography.caption.copyWith(
                  color: AppColors.protoSubtitle,
                ),
              ),
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
    );
  }
}
