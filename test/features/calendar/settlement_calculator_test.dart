import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/calendar/logic/settlement_calculator.dart';

void main() {
  group('calculateSettlement', () {
    test('haruchip_app.html mock(room-1)과 동일한 total/share/tx를 계산한다', () {
      final result = calculateSettlement(
        {'하루': 60000, '서연': 40000},
        ['하루', '민수', '서연', '도윤'],
      );

      expect(result.total, 100000);
      expect(result.share, 25000);

      // 그리디 알고리즘 결과가 결정적이므로 정확한 송금 목록을 검증한다.
      expect(result.tx, [
        const SettlementTransaction(from: '민수', to: '하루', amount: 25000),
        const SettlementTransaction(from: '도윤', to: '하루', amount: 10000),
        const SettlementTransaction(from: '도윤', to: '서연', amount: 15000),
      ]);

      // 수학적 정합성: 모든 송금 합계는 (실제 지출 - 1인당 부담액)이 양수인
      // 사람들의 초과분 합계와 같아야 한다(부채가 정확히 해소됨).
      final txTotal = result.tx.fold<int>(0, (sum, t) => sum + t.amount);
      expect(txTotal, 50000);
    });

    test('room-2 mock(팀장님 45000, 3명)도 동일 로직으로 계산된다', () {
      final result = calculateSettlement(
        {'팀장님': 45000},
        ['하루', '팀장님', '인턴'],
      );

      expect(result.total, 45000);
      expect(result.share, 15000);
      expect(result.tx, [
        const SettlementTransaction(from: '하루', to: '팀장님', amount: 15000),
        const SettlementTransaction(from: '인턴', to: '팀장님', amount: 15000),
      ]);
    });

    test('전원 동일 금액을 낸 경우 tx는 빈 리스트다(정산할 차액 없음)', () {
      final result = calculateSettlement(
        {'a': 10000, 'b': 10000, 'c': 10000},
        ['a', 'b', 'c'],
      );

      expect(result.total, 30000);
      expect(result.share, 10000);
      expect(result.tx, isEmpty);
    });

    test('아무도 안 낸 사람이 있어도 payments에 없으면 0원으로 취급한다', () {
      final result = calculateSettlement(
        {'a': 9000},
        ['a', 'b', 'c'],
      );

      expect(result.total, 9000);
      expect(result.share, 3000);
      expect(result.tx, [
        const SettlementTransaction(from: 'b', to: 'a', amount: 3000),
        const SettlementTransaction(from: 'c', to: 'a', amount: 3000),
      ]);
    });
  });
}
