import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/schedule_room.dart';

/// 모임방 Firestore 동기화 (CLAUDE.md §4 scheduleRooms / inviteCodes).
///
/// 구조
/// ```
/// scheduleRooms/{roomId}                name, description, categoryTag, hostUid,
///                                       memberUids[], confirmedDate, inviteCode, createdAt
///   members/{uid}                       uid, name, icon, colorHex, isHost, joinedWithCode
///   availability/{uid}                  dates: { "YYYY-MM-DD": [ {start,end}, ... ] }  ([] = 하루 종일)
///   comments/{id}                       확정 모임 댓글
///   events/{id}                         공유 캘린더 일정
/// inviteCodes/{code}                    roomId, createdBy, expiresAt (다회용, 7일)
/// ```
/// 접근 제어는 `firestore.rules`가 한다 — 이 클래스는 규칙이 허용하는
/// 순서(같은 batch로 방+멤버+코드 생성, 코드 확인 후 본인만 멤버 추가)로만 쓴다.
/// 공지/투표/정산은 아직 기기 로컬 상태로 남아 있다(다음 단계).

/// 로그인한 사용자 (Firebase Auth에서 필요한 값만).
class RoomUser {
  const RoomUser({required this.uid, required this.displayName});

  final String uid;
  final String displayName;
}

enum JoinRoomResult { joined, alreadyMember, notFound, expired, failed }

/// 초대코드 유효 기간 (CLAUDE.md 2026-10 결정).
const Duration kInviteCodeLifetime = Duration(days: 7);

class FirestoreRoomRemote {
  FirestoreRoomRemote(this._db, {required this.authChanges});

  final FirebaseFirestore _db;

  /// 로그인 상태 스트림 (앱: FirebaseAuth, 테스트: 직접 주입).
  final Stream<RoomUser?> authChanges;

  CollectionReference<Map<String, dynamic>> get _rooms => _db.collection('scheduleRooms');
  CollectionReference<Map<String, dynamic>> get _codes => _db.collection('inviteCodes');

  static String newInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return 'HC-${List.generate(6, (_) => chars[random.nextInt(chars.length)]).join()}';
  }

  /// 방 만들기: 방 + 방장 멤버 문서 + 초대코드를 한 batch로 쓴다.
  Future<ScheduleRoom> createRoom({
    required RoomUser user,
    required String name,
    String? description,
    String categoryTag = '모임',
    required RoomMember host,
  }) async {
    final roomRef = _rooms.doc();
    final code = newInviteCode();
    final hostMember = host.copyWith(isHost: true);
    final batch = _db.batch()
      ..set(roomRef, {
        'name': name,
        'description': description,
        'categoryTag': categoryTag,
        'hostUid': user.uid,
        'memberUids': [user.uid],
        'confirmedDate': null,
        'inviteCode': code,
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..set(roomRef.collection('members').doc(user.uid), _memberJson(hostMember, user.uid))
      ..set(_codes.doc(code), {
        'roomId': roomRef.id,
        'createdBy': user.uid,
        'expiresAt': Timestamp.fromDate(DateTime.now().add(kInviteCodeLifetime)),
      });
    await batch.commit();
    return ScheduleRoom(
      id: roomRef.id,
      name: name,
      description: description,
      categoryTag: categoryTag,
      inviteCode: code,
      members: [hostMember.copyWith(uid: user.uid)],
      dates: const {},
    );
  }

  /// 방장이 초대코드를 새로 발급 (7일 연장 효과).
  Future<String> reissueInviteCode({required RoomUser user, required String roomId}) async {
    final code = newInviteCode();
    final batch = _db.batch()
      ..set(_codes.doc(code), {
        'roomId': roomId,
        'createdBy': user.uid,
        'expiresAt': Timestamp.fromDate(DateTime.now().add(kInviteCodeLifetime)),
      })
      ..update(_rooms.doc(roomId), {'inviteCode': code});
    await batch.commit();
    return code;
  }

  /// 초대코드로 참가: 코드 확인 → 본인 멤버 문서 + memberUids에 본인 추가.
  Future<JoinRoomResult> joinWithCode({
    required RoomUser user,
    required String rawCode,
    required RoomMember me,
  }) async {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) return JoinRoomResult.notFound;
    final codeSnap = await _codes.doc(code).get();
    final data = codeSnap.data();
    if (!codeSnap.exists || data == null) return JoinRoomResult.notFound;
    final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
    if (expiresAt == null || expiresAt.isBefore(DateTime.now())) return JoinRoomResult.expired;
    final roomId = data['roomId'] as String;
    final roomRef = _rooms.doc(roomId);

    // 이미 멤버면 방 문서를 읽을 수 있다 (멤버가 아니면 규칙상 읽기 거부 → 그대로 진행).
    try {
      final roomSnap = await roomRef.get();
      final uids = (roomSnap.data()?['memberUids'] as List?)?.cast<String>() ?? const [];
      if (uids.contains(user.uid)) return JoinRoomResult.alreadyMember;
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') rethrow;
    }

    final memberJson = _memberJson(me.copyWith(isHost: false), user.uid)..['joinedWithCode'] = code;
    final batch = _db.batch()
      ..set(roomRef.collection('members').doc(user.uid), memberJson)
      ..update(roomRef, {'memberUids': FieldValue.arrayUnion([user.uid])});
    await batch.commit();
    return JoinRoomResult.joined;
  }

  Future<void> setMyAvailability({required String roomId, required String uid, required Set<String> dates}) {
    return _rooms.doc(roomId).collection('availability').doc(uid).set({
      'dates': {for (final d in dates) d: <Map<String, String>>[]},
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> confirmDate({required String roomId, required String date}) {
    return _rooms.doc(roomId).update({'confirmedDate': date});
  }

  Future<void> addMeetingComment({required String roomId, required NoticeComment comment}) {
    return _rooms.doc(roomId).collection('comments').doc(comment.id).set(comment.toJson());
  }

  Future<void> addEvent({required String roomId, required RoomSharedEvent event}) {
    return _rooms.doc(roomId).collection('events').doc(event.id).set(event.toJson());
  }

  Future<void> removeEvent({required String roomId, required String eventId}) {
    return _rooms.doc(roomId).collection('events').doc(eventId).delete();
  }

  Future<void> updateMyMember({
    required String roomId,
    required String uid,
    String? name,
    String? icon,
    String? colorHex,
  }) {
    return _rooms.doc(roomId).collection('members').doc(uid).update({
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (colorHex != null) 'colorHex': colorHex,
    });
  }

  /// 내가 멤버인 방들을 실시간으로 — 방 문서 + 하위 컬렉션 4개를 묶어
  /// [ScheduleRoom]으로 내보낸다.
  Stream<List<ScheduleRoom>> watchMyRooms(String uid) {
    final controller = StreamController<List<ScheduleRoom>>();
    final parts = <String, _RoomParts>{};
    final roomSubs = <String, List<StreamSubscription<dynamic>>>{};
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? listSub;

    void emit() {
      if (controller.isClosed) return;
      final rooms = parts.values.where((p) => p.room != null).map((p) => p.build()).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      controller.add(rooms);
    }

    void onError(Object e) {
      if (!controller.isClosed) controller.addError(e);
    }

    void watchRoom(String roomId) {
      final p = parts.putIfAbsent(roomId, () => _RoomParts(roomId));
      final ref = _rooms.doc(roomId);
      roomSubs[roomId] = [
        ref.collection('members').snapshots().listen((s) {
          p.members = s.docs.map((d) => _memberFromJson(d.data(), d.id)).toList();
          emit();
        }, onError: onError),
        ref.collection('availability').snapshots().listen((s) {
          p.availability = {
            for (final d in s.docs) d.id: ((d.data()['dates'] as Map?) ?? const {}).keys.cast<String>().toSet(),
          };
          emit();
        }, onError: onError),
        ref.collection('comments').orderBy('createdAt').snapshots().listen((s) {
          p.comments = s.docs.map((d) => NoticeComment.fromJson(d.data())).toList();
          emit();
        }, onError: onError),
        ref.collection('events').snapshots().listen((s) {
          p.events = s.docs.map((d) => RoomSharedEvent.fromJson(d.data())).toList();
          emit();
        }, onError: onError),
      ];
    }

    void unwatchRoom(String roomId) {
      for (final s in roomSubs.remove(roomId) ?? const <StreamSubscription<dynamic>>[]) {
        s.cancel();
      }
      parts.remove(roomId);
    }

    controller.onListen = () {
      listSub = _rooms.where('memberUids', arrayContains: uid).snapshots().listen((snap) {
        final ids = snap.docs.map((d) => d.id).toSet();
        for (final gone in parts.keys.where((k) => !ids.contains(k)).toList()) {
          unwatchRoom(gone);
        }
        for (final d in snap.docs) {
          if (!roomSubs.containsKey(d.id)) watchRoom(d.id);
          parts[d.id]!.room = d.data();
        }
        emit();
      }, onError: onError);
    };
    controller.onCancel = () async {
      await listSub?.cancel();
      for (final id in roomSubs.keys.toList()) {
        unwatchRoom(id);
      }
    };
    return controller.stream;
  }

  static Map<String, dynamic> _memberJson(RoomMember m, String uid) => {
        'uid': uid,
        'name': m.name,
        'icon': m.icon,
        'colorHex': m.colorHex,
        'isHost': m.isHost,
      };

  static RoomMember _memberFromJson(Map<String, dynamic> j, String id) => RoomMember(
        uid: j['uid'] as String? ?? id,
        name: j['name'] as String? ?? '멤버',
        icon: j['icon'] as String? ?? '🙂',
        colorHex: j['colorHex'] as String? ?? '#DFE7FD',
        isHost: j['isHost'] as bool? ?? false,
      );
}

class _RoomParts {
  _RoomParts(this.id);

  final String id;
  Map<String, dynamic>? room;
  List<RoomMember> members = const [];
  Map<String, Set<String>> availability = const {};
  List<NoticeComment> comments = const [];
  List<RoomSharedEvent> events = const [];

  ScheduleRoom build() {
    final r = room!;
    final dates = <String, List<String>>{};
    availability.forEach((uid, ds) {
      for (final d in ds) {
        dates.putIfAbsent(d, () => []).add(uid);
      }
    });
    // 호스트가 맨 앞
    final sortedMembers = [...members]..sort((a, b) => (b.isHost ? 1 : 0) - (a.isHost ? 1 : 0));
    return ScheduleRoom(
      id: id,
      name: r['name'] as String? ?? '모임',
      description: r['description'] as String?,
      categoryTag: r['categoryTag'] as String? ?? '모임',
      inviteCode: r['inviteCode'] as String? ?? '',
      members: sortedMembers,
      dates: dates,
      confirmedDate: r['confirmedDate'] as String?,
      events: events,
      meetingComments: comments,
    );
  }
}

/// 앱에서만 [FirestoreRoomRemote]로 override된다 (main.dart). 기본값 null =
/// 기존처럼 기기 안 목업 데이터로 동작 — 테스트/오프라인 개발용.
final roomRemoteProvider = Provider<FirestoreRoomRemote?>((ref) => null);

/// 로그인한 사용자. 원격 동기화가 꺼져 있으면 항상 null.
final roomAuthUserProvider = StreamProvider<RoomUser?>((ref) {
  final remote = ref.watch(roomRemoteProvider);
  if (remote == null) return Stream.value(null);
  return remote.authChanges;
});

/// 모임방 동기화 중 마지막 오류 (화면에서 스낵바로 보여준다).
final roomSyncErrorProvider = StateProvider<String?>((ref) => null);

/// 앱에서 쓰는 FirebaseAuth → [RoomUser] 스트림.
Stream<RoomUser?> firebaseRoomUserChanges() {
  return fb_auth.FirebaseAuth.instance.authStateChanges().map((u) => u == null
      ? null
      : RoomUser(uid: u.uid, displayName: (u.displayName?.trim().isNotEmpty ?? false) ? u.displayName!.trim() : '나'));
}
