import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// 사진 업로드 흐름 — 카테고리&디데이 핸드오프 문서 §6 "이미지 업로드 확정":
/// 갤러리에서 선택(`image_picker`) → Storage 업로드(`firebase_storage`) →
/// 다운로드 URL을 `photoUrl`/`Category.backgroundImageUrl`에 저장.
///
/// 저장 경로를 `users/{uid}/uploads/{folder}/...`로 고정해 `storage.rules`
/// (repo 루트)가 `request.auth.uid == uid`인 경로만 쓰기를 허용하게 한다 —
/// CLAUDE.md §9 "Broken Access Control" 대응. 비로그인 상태([currentUser]가
/// null)면 아무 것도 하지 않고 null을 돌려준다(호출부가 스낵바로 안내).
class ImageUploadService {
  ImageUploadService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// 갤러리에서 이미지 하나를 골라 업로드하고 다운로드 URL을 돌려준다.
  /// 로그인 상태가 아니거나 사용자가 선택을 취소하면 null.
  ///
  /// [folder]는 업로드 목적 구분용 하위 경로 — 예: 'baby', 'pet',
  /// 'category-background'. 카테고리/항목 id별로 더 세분화하지 않는다(이번
  /// 단계는 "사진 업로드가 되는가"까지만 — 파일 정리/삭제는 범위 밖).
  Future<String?> pickAndUpload({required String folder}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final fileName = '${DateTime.now().microsecondsSinceEpoch}_${picked.name}';
    final ref = FirebaseStorage.instance.ref('users/$uid/uploads/$folder/$fileName');
    await ref.putFile(File(picked.path));
    return ref.getDownloadURL();
  }
}

final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  return ImageUploadService();
});
