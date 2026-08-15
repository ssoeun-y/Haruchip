import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';

/// [BreakupReuniteDialog]가 어떤 기록을 남기는 다이얼로그인지 구분한다.
enum BreakupReuniteDialogMode { breakup, reunite }

/// 이별/재회 날짜를 고르는 다이얼로그 — CLAUDE.md §7-1.
///
/// 날짜 역전 방지 자체는 `couple_provider.dart`의 `addBreakup`/`addReunite`
/// (bool 반환)가 검증한다. 이 다이얼로그는 날짜를 고르고 확인을 누르면
/// 선택한 [DateTime]을 [Navigator.pop]으로 돌려주기만 한다.
///
/// 모달 닫기는 CLAUDE.md 공통 규칙대로 3가지를 모두 지원한다:
/// X 버튼, 하단 "닫기" 버튼, 배경(바깥) 클릭(`barrierDismissible: true`).
class BreakupReuniteDialog extends StatefulWidget {
  const BreakupReuniteDialog({super.key, required this.mode});

  final BreakupReuniteDialogMode mode;

  /// 다이얼로그를 열고 사용자가 확인한 날짜를 돌려준다. 취소/배경클릭/X면 null.
  static Future<DateTime?> show(
    BuildContext context, {
    required BreakupReuniteDialogMode mode,
  }) {
    return showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      builder: (_) => BreakupReuniteDialog(mode: mode),
    );
  }

  @override
  State<BreakupReuniteDialog> createState() => _BreakupReuniteDialogState();
}

class _BreakupReuniteDialogState extends State<BreakupReuniteDialog> {
  DateTime _selectedDate = DateTime.now();

  bool get _isBreakup => widget.mode == BreakupReuniteDialogMode.breakup;

  String _formatDate(DateTime date) =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isBreakup ? '이별 기록하기' : '재회 기록하기';
    final description = _isBreakup
        ? '이별한 날짜를 선택해주세요. 30일 안에 재회 기록을 추가하면 자동으로 복구돼요.'
        : '다시 만난 날짜를 선택해주세요.';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.protoCardBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
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
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTypography.caption.copyWith(
                color: AppColors.protoSubtitle,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.protoCoupleBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.protoCoupleBgMuted,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 20,
                      color: AppColors.protoCoupleTextStrong,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _formatDate(_selectedDate),
                      style: AppTypography.cardLabel.copyWith(
                        color: AppColors.protoCoupleTextStrong,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.protoCardText,
                      side: const BorderSide(
                        color: AppColors.protoCardBorder,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('닫기'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_selectedDate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.protoButtonBg,
                      foregroundColor: AppColors.protoButtonText,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('확인'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
