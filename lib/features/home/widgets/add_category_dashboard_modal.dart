import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../../categories/data/category_types.dart';
import '../../categories/models/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../categories/services/image_upload_service.dart';
import '../../onboarding/models/onboarding_category.dart';

/// "카테고리 추가하기" 모달 — CLAUDE.md §5("+ 새 카테고리 추가하기" 진입점),
/// §8(대시보드 명세).
///
/// 카테고리 & 디데이 커스텀 2단계: 타입 선택(STEP A) → 이름/아이콘/색상
/// 커스텀(STEP B) → [categoryListProvider]에 새 [Category] 인스턴스를
/// 추가한다. "카테고리는 태그 개념 — 동일 카테고리 다중 인스턴스 항상
/// 허용"(CLAUDE.md §5)이므로 STEP A는 이미 추가한 타입도 계속 보여준다
/// (기존처럼 already-selected 필터로 숨기지 않는다).
///
/// CLAUDE.md 공통 UI 모달 닫기 규칙(X 버튼 / 하단 닫기 버튼 / 배경 클릭)을
/// 모두 지원한다.
Future<void> showAddCategoryDashboardModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _AddCategoryDashboardModal(),
  );
}

/// STEP B에서 기본 이모지 외에 고를 수 있는 대체 이모지 chip 목록.
/// 특정 카테고리 타입에 종속되지 않는 범용 세트다.
const List<String> _alternateEmojis = [
  '🎯',
  '⭐',
  '🔥',
  '💡',
  '📌',
  '🎨',
  '🌈',
  '✨',
];

class _AddCategoryDashboardModal extends ConsumerStatefulWidget {
  const _AddCategoryDashboardModal();

  @override
  ConsumerState<_AddCategoryDashboardModal> createState() =>
      _AddCategoryDashboardModalState();
}

class _AddCategoryDashboardModalState
    extends ConsumerState<_AddCategoryDashboardModal> {
  OnboardingCategory? _selectedType;
  final _nameController = TextEditingController();
  String? _selectedEmoji;
  Color _selectedColor = AppColors.kFreeColorPresets.first;

  /// 배경 사진(§5 감성형 한정, §6 사진 업로드) — 업로드 중엔 null이 아니라
  /// [_uploadingBackground]로 별도 로딩 상태를 둔다(업로드 실패해도 이전
  /// 값을 잃지 않도록).
  String? _backgroundImageUrl;
  bool _uploadingBackground = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _selectType(OnboardingCategory type) {
    setState(() {
      _selectedType = type;
      _nameController.clear();
      _selectedEmoji = type.emoji;
      _selectedColor = AppColors.kFreeColorPresets.first;
      _backgroundImageUrl = null;
    });
  }

  void _backToTypeSelection() {
    setState(() => _selectedType = null);
  }

  Future<void> _pickBackgroundImage() async {
    setState(() => _uploadingBackground = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final url = await ref
          .read(imageUploadServiceProvider)
          .pickAndUpload(folder: 'category-background');
      if (!mounted) return;
      if (url == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('⚠️ 로그인 상태를 확인하거나 사진 선택을 다시 시도해주세요.')),
        );
      } else {
        setState(() => _backgroundImageUrl = url);
      }
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('⚠️ 사진 업로드에 실패했습니다. 다시 시도해주세요.')),
      );
    } finally {
      if (mounted) setState(() => _uploadingBackground = false);
    }
  }

  void _handleAdd(BuildContext context) {
    final type = _selectedType;
    if (type == null) return;
    final name = _nameController.text.trim().isEmpty
        ? type.labelKo
        : _nameController.text.trim();
    final emoji = _selectedEmoji ?? type.emoji;

    ref.read(categoryListProvider.notifier).addCategory(
          categoryKey: type.key,
          name: name,
          emoji: emoji,
          colorHex: colorToHex(_selectedColor),
          backgroundImageUrl: _backgroundImageUrl,
        );

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(content: Text("✨ '$name' 카테고리가 추가되었습니다!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = _selectedType;

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
                      Row(
                        children: [
                          if (type != null)
                            GestureDetector(
                              onTap: _backToTypeSelection,
                              child: const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  size: 20,
                                  color: AppColors.protoSubtitle,
                                ),
                              ),
                            ),
                          Text(
                            type == null ? '카테고리 추가하기' : '${type.labelKo} 커스텀',
                            style: AppTypography.heading2.copyWith(
                              color: AppColors.protoHeading,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: AppColors.protoSubtitle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (type == null) _buildStepA() else _buildStepB(type),
                  const SizedBox(height: 16),
                  if (type != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleAdd(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.protoButtonBg,
                          foregroundColor: AppColors.protoButtonText,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('추가하기'),
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

  Widget _buildStepA() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '어떤 카테고리를 추가할까요?',
          style: AppTypography.caption.copyWith(
            color: AppColors.protoSubtitle,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            for (final category in kCategoryTypes)
              InkWell(
                onTap: () => _selectType(category),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.protoCardBorder,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category.labelKo,
                        textAlign: TextAlign.center,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.protoCardText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepB(OnboardingCategory type) {
    final emojiChoices = <String>{type.emoji, ..._alternateEmojis}.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이름',
          style: AppTypography.caption.copyWith(
            color: AppColors.protoSubtitle,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          style: AppTypography.body.copyWith(color: AppColors.protoHeading),
          decoration: InputDecoration(
            hintText: type.labelKo,
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
          '아이콘',
          style: AppTypography.caption.copyWith(
            color: AppColors.protoSubtitle,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final emoji in emojiChoices)
              GestureDetector(
                onTap: () => setState(() => _selectedEmoji = emoji),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (_selectedEmoji ?? type.emoji) == emoji
                        ? AppColors.protoCardSelectedBg
                        : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (_selectedEmoji ?? type.emoji) == emoji
                          ? AppColors.protoCardSelectedBorder
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 18)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '색상',
          style: AppTypography.caption.copyWith(
            color: AppColors.protoSubtitle,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final color in AppColors.kFreeColorPresets)
              GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorToHex(_selectedColor) == colorToHex(color)
                          ? AppColors.protoHeading
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (type.group == CategoryGroup.emotional) ...[
          const SizedBox(height: 16),
          Text(
            '배경 사진 (선택)',
            style: AppTypography.caption.copyWith(
              color: AppColors.protoSubtitle,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _uploadingBackground ? null : _pickBackgroundImage,
            child: Container(
              width: double.infinity,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(14),
                image: _backgroundImageUrl == null
                    ? null
                    : DecorationImage(
                        image: NetworkImage(_backgroundImageUrl!),
                        fit: BoxFit.cover,
                      ),
              ),
              child: _uploadingBackground
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : _backgroundImageUrl == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 22,
                              color: AppColors.protoStepLabel,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '갤러리에서 사진 선택',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.protoSubtitle,
                              ),
                            ),
                          ],
                        )
                      : null,
            ),
          ),
        ],
      ],
    );
  }
}
