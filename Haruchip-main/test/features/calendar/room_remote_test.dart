import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/calendar/data/room_remote.dart';
import 'package:haruchip/features/calendar/models/schedule_room.dart';
import 'package:haruchip/features/calendar/providers/schedule_room_provider.dart';

/// 모임방 Firestore 동기화 — 가짜 Firestore 하나를 두 사용자가 같이 쓰는 상황.
/// (보안 규칙은 이 가짜 엔진이 getAfter/diff를 지원하지 않아 여기서 검증하지 않는다.)
const _host = RoomUser(uid: 'uid-host', displayName: '소은');
const _friend = RoomUser(uid: 'uid-friend', displayName: '민수');

FirestoreRoomRemote _remote(FakeFirebaseFirestore db, RoomUser user) =>
    FirestoreRoomRemote(db, authChanges: Stream.value(user));

/// 앱처럼 provider까지 띄운 사용자 한 명.
ProviderContainer _app(FakeFirebaseFirestore db, RoomUser user) {
  final c = ProviderContainer(overrides: [roomRemoteProvider.overrideWithValue(_remote(db, user))]);
  addTearDown(c.dispose);
  c.listen(scheduleRoomsProvider, (_, __) {}); // 구독 유지
  return c;
}

Future<void> _flush() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  test('방 만들기: 방·방장 멤버·7일짜리 초대코드가 함께 생긴다', () async {
    final db = FakeFirebaseFirestore();
    final room = await _remote(db, _host).createRoom(
      user: _host,
      name: '동창회',
      host: const RoomMember(uid: 'x', name: '소은', icon: '🐥'),
    );

    final roomDoc = await db.collection('scheduleRooms').doc(room.id).get();
    expect(roomDoc['hostUid'], 'uid-host');
    expect(roomDoc['memberUids'], ['uid-host']);
    final member = await db.doc('scheduleRooms/${room.id}/members/uid-host').get();
    expect(member['isHost'], isTrue);
    final code = await db.collection('inviteCodes').doc(room.inviteCode).get();
    expect(code['roomId'], room.id);
    final expires = (code['expiresAt'] as Timestamp).toDate();
    expect(expires.difference(DateTime.now()).inDays, inInclusiveRange(6, 7));
  });

  test('친구가 코드로 참가하면 두 사람 모두 같은 방을 실시간으로 본다', () async {
    final db = FakeFirebaseFirestore();
    final hostApp = _app(db, _host);
    final friendApp = _app(db, _friend);
    await _flush();

    final room = await hostApp.read(scheduleRoomsProvider.notifier).createRoomSynced(
          name: '동창회',
          hostMember: const RoomMember(uid: 'uid-host', name: '소은', icon: '🐥'),
        );
    final result = await friendApp.read(scheduleRoomsProvider.notifier).joinRoomSynced(
          room.inviteCode.toLowerCase(), // 소문자로 입력해도 된다
          const RoomMember(uid: 'uid-friend', name: '민수', icon: '🐶'),
        );
    await _flush();

    expect(result, JoinRoomResult.joined);
    final seenByHost = hostApp.read(scheduleRoomsProvider).single;
    final seenByFriend = friendApp.read(scheduleRoomsProvider).single;
    expect(seenByHost.members.map((m) => m.uid), containsAll(['uid-host', 'uid-friend']));
    expect(seenByFriend.id, room.id);
    expect(seenByFriend.members.first.isHost, isTrue, reason: '방장이 맨 앞');
  });

  test('없는 코드 / 만료된 코드 / 이미 참가한 방', () async {
    final db = FakeFirebaseFirestore();
    final remote = _remote(db, _host);
    final room = await remote.createRoom(user: _host, name: '모임', host: const RoomMember(uid: 'x', name: '소은', icon: '🐥'));
    const me = RoomMember(uid: 'uid-friend', name: '민수', icon: '🐶');

    expect(await remote.joinWithCode(user: _friend, rawCode: 'HC-NOPE00', me: me), JoinRoomResult.notFound);

    await db.collection('inviteCodes').doc('HC-OLD111').set({
      'roomId': room.id,
      'createdBy': 'uid-host',
      'expiresAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
    });
    expect(await remote.joinWithCode(user: _friend, rawCode: 'HC-OLD111', me: me), JoinRoomResult.expired);

    expect(await remote.joinWithCode(user: _host, rawCode: room.inviteCode, me: me), JoinRoomResult.alreadyMember);
  });

  test('한 코드를 여러 명이 쓸 수 있다 (다회용)', () async {
    final db = FakeFirebaseFirestore();
    final room = await _remote(db, _host)
        .createRoom(user: _host, name: '모임', host: const RoomMember(uid: 'x', name: '소은', icon: '🐥'));
    for (final u in ['a', 'b', 'c']) {
      final user = RoomUser(uid: 'uid-$u', displayName: u);
      final r = await _remote(db, user)
          .joinWithCode(user: user, rawCode: room.inviteCode, me: RoomMember(uid: user.uid, name: u, icon: '🙂'));
      expect(r, JoinRoomResult.joined);
    }
    final doc = await db.collection('scheduleRooms').doc(room.id).get();
    expect((doc['memberUids'] as List).length, 4);
  });

  test('가능 날짜 저장·방장 확정·댓글이 다른 멤버 화면에 반영된다', () async {
    final db = FakeFirebaseFirestore();
    final hostApp = _app(db, _host);
    final friendApp = _app(db, _friend);
    await _flush();
    final room = await hostApp.read(scheduleRoomsProvider.notifier).createRoomSynced(
          name: '동창회',
          hostMember: const RoomMember(uid: 'uid-host', name: '소은', icon: '🐥'),
        );
    await friendApp.read(scheduleRoomsProvider.notifier).joinRoomSynced(
          room.inviteCode,
          const RoomMember(uid: 'uid-friend', name: '민수', icon: '🐶'),
        );
    await _flush();

    hostApp.read(scheduleRoomsProvider.notifier).setMyAvailability(room.id, 'uid-host', {'2026-11-07', '2026-11-08'});
    friendApp.read(scheduleRoomsProvider.notifier).setMyAvailability(room.id, 'uid-friend', {'2026-11-08'});
    await _flush();

    final dates = hostApp.read(scheduleRoomsProvider).single.dates;
    expect(dates['2026-11-08'], containsAll(['uid-host', 'uid-friend']));
    expect(dates['2026-11-07'], ['uid-host']);

    hostApp.read(scheduleRoomsProvider.notifier).confirmDate(room.id, '2026-11-08');
    friendApp.read(scheduleRoomsProvider.notifier).addMeetingComment(
          room.id,
          NoticeComment(
            id: 'c1',
            authorUid: 'uid-friend',
            authorName: '민수',
            authorIcon: '🐶',
            content: '참석!',
            createdAt: DateTime(2026, 10, 7, 12),
          ),
        );
    await _flush();

    final seenByFriend = friendApp.read(scheduleRoomsProvider).single;
    expect(seenByFriend.confirmedDate, '2026-11-08');
    expect(hostApp.read(scheduleRoomsProvider).single.meetingComments.single.content, '참석!');
  });

  test('로그인 전·테스트(원격 없음)에서는 기존 목업 그대로', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(scheduleRoomsProvider), isNotEmpty);
    expect(c.read(currentUserProfileProvider).uid, '하루');
  });
}
