import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../providers/military_provider.dart';

/// 군대(곰신) 복무 정보 설정 다이얼로그 — CLAUDE.md §5.3.
///
/// 입대일/전역일(필수) + 다음 휴가일(선택) 날짜 피커. 저장하면
/// [militaryServiceProvider]를 갱신한다. `breakup_reunite_dialog.dart` 톤을
/// 그대로 따른다 — CLAUDE.md 공통 모달 닫기 규칙(X 버튼 / 하단 "닫기" 버튼 /
/// 배경 클릭)을 모두 지원한다(`barrierDismissible: true` + X + 닫기 버튼).
Future<void> showMilitarySetupDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _MilitarySetupDialog(),
  );
}

class _MilitarySetupDialog extends ConsumerStatefulWidget {
  const _MilitarySetupDialog();

  @override
  ConsumerState<_MilitarySetupDialog> createState() =>
      _MilitarySetupDialogState();
}

class _MilitarySetupDialogState extends ConsumerState<_MilitarySetupDialog> {
  late DateTime _enlistDate;
  late DateTime _dischargeDate;
  DateTime? _nextLeaveDate;

  @override
  void initState() {
    super.initState();
    final service = ref.read(militaryServiceProvider);
    _enlistDate = service.enlistDate;
    _dischargeDate = service.dischargeDate;
    _nextLeaveDate = service.nextLeaveDate;
  }

  String _formatDate(DateTime date) =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

  Future<void> _pickEnlistDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _enlistDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _enlistDate = picked);
    }
  }

  Future<void> _pickDischargeDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dischargeDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _dischargeDate = picked);
    }
  }

  Future<void> _pickNextLeaveDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextLeaveDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _nextLeaveDate = picked);
    }
  }

  void _handleSave() {
    ref.read(militaryServiceProvider.notifier).setService(
          enlistDate: _enlistDate,
          dischargeDate: _dischargeDate,
        );
    ref.read(militaryServiceProvider.notifier).setNextLeave(_nextLeaveDate);
    Navigator.of(context).pop();
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: AppTypography.caption.copyWith(color: AppColors.protoSubtitle),
      );

  Widget _dateField({
    required DateTime? date,
    required VoidCallback onTap,
    String placeholder = '날짜를 선택해주세요',
  }) {
    return InkWell(
      onTap: onTap,
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
              date == null ? placeholder : _formatDate(date),
              style: AppTypography.cardLabel.copyWith(
                color: AppColors.protoHeading,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                          '군대 (곰신) 설정',
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
                  _sectionLabel('입대일'),
                  const SizedBox(height: 6),
                  _dateField(date: _enlistDate, onTap: _pickEnlistDate),
                  const SizedBox(height: 16),
                  _sectionLabel('전역일'),
                  const SizedBox(height: 6),
                  _dateField(date: _dischargeDate, onTap: _pickDischargeDate),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionLabel('다음 휴가일 (선택)'),
                      if (_nextLeaveDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _nextLeaveDate = null),
                          child: Text(
                            '지우기',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.protoSubtitle,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _dateField(
                    date: _nextLeaveDate,
                    onTap: _pickNextLeaveDate,
                    placeholder: '휴가일을 선택해주세요',
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
                      child: const Text('저장'),
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
