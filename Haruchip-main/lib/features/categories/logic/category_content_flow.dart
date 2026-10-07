import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../couple/widgets/couple_relationship_setup_sheet.dart';
import '../../plan/providers/plan_provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../widgets/category_onboarding_sheets.dart';
import 'category_entry_mirrors.dart';

/// 카테고리 [draft](아직 목록에 없음)에 맞는 내용 입력창을 띄우고, 사용자가
/// 저장하면 그때 카테고리를 추가한다. 저장했으면 true, 닫았으면 false
/// (카테고리는 추가되지 않는다).
///
/// 대시보드 "+ 새 카테고리"와 온보딩(처음 시작) 둘 다 이 함수를 쓴다.
/// - 군대/육아/솔로/덕질/반려동물/직접설정: 전용 내용 시트 (시트가 직접 upsert)
/// - 일정/목표/루틴/시험/생일: 카테고리 안 항목 입력창으로 첫 항목
/// - 커플: 만난 날 및 재회 설정
Future<bool> collectContentAndAddCategory(
  BuildContext context,
  WidgetRef ref,
  Category draft,
) async {
  final notifier = ref.read(categoryListProvider.notifier);
  final key = draft.categoryKey;

  if (kCategoryKeysWithContentSheet.contains(key)) {
    final saved = await showContentSheetForCategory(context, category: draft, ref: ref);
    return saved == true;
  }

  if (kCategoryKeysWithFirstEntryForm.contains(key)) {
    final entry = await showFirstEntryFormForCategory(
      context,
      categoryKey: key,
      categoryId: draft.id,
    );
    if (entry == null) return false;
    notifier.upsertCategory(draft.copyWith(metadata: {
      'isInitialized': true,
      entry.metaKey: [entry.json],
    }));
    if (entry.mirrors.isNotEmpty) {
      ref.read(planListProvider.notifier).addItems(entry.mirrors);
    }
    return true;
  }

  if (key == 'couple') {
    final saved = await showCoupleRelationshipSetupSheet(context, ref);
    if (!saved) return false;
    notifier.upsertCategory(draft.copyWith(metadata: {'isInitialized': true}));
    return true;
  }

  // 입력할 내용이 정의되지 않은 타입 — 바로 추가.
  notifier.upsertCategory(draft);
  return true;
}

/// 내용 입력이 필요한 타입인지 (버튼 문구 "다음: 내용 입력하기" 판단용).
bool categoryNeedsContent(String categoryKey) =>
    kCategoryKeysWithContentSheet.contains(categoryKey) ||
    kCategoryKeysWithFirstEntryForm.contains(categoryKey) ||
    categoryKey == 'couple';
