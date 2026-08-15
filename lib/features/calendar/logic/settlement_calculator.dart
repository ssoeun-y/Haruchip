/// CLAUDE.md §7-6 정산 로직 — haruchip_app.html의 calculateSettlement()를
/// Dart로 그대로 포팅한다(부채 최소화 그리디 알고리즘, 반올림 방식 포함).
/// 로직을 임의로 바꾸지 않는다 — html과 완전히 동일해야 한다.
library;

/// 정산 송금 제안 하나: [from]이 [to]에게 [amount]를 보내면 된다.
class SettlementTransaction {
  const SettlementTransaction({
    required this.from,
    required this.to,
    required this.amount,
  });

  final String from;
  final String to;
  final int amount;

  @override
  bool operator ==(Object other) =>
      other is SettlementTransaction &&
      other.from == from &&
      other.to == to &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(from, to, amount);

  @override
  String toString() => 'SettlementTransaction($from -> $to: $amount)';
}

/// 정산 계산 결과.
class SettlementResult {
  const SettlementResult({
    required this.total,
    required this.share,
    required this.tx,
  });

  /// 전체 지출 합계.
  final int total;

  /// 1인당 부담액(반올림).
  final int share;

  /// 부채 최소화 그리디로 계산한 송금 제안 목록.
  final List<SettlementTransaction> tx;
}

class _Balance {
  _Balance(this.name, this.balance);

  final String name;
  int balance;
}

/// html calculateSettlement()과 동일한 로직.
///
/// [payments]: key는 멤버 이름(uid), value는 그 사람이 실제로 낸 금액.
/// [members]: 참여자 전체 이름 목록(payments에 없는 멤버는 0원 낸 것으로
/// 취급 — html의 `payments[name] || 0`과 동일).
SettlementResult calculateSettlement(
  Map<String, int> payments,
  List<String> members,
) {
  final total = payments.values.fold<int>(0, (a, b) => a + b);
  // html의 Math.round(total / members.length)와 동일한 반올림(0.5는 올림).
  final share =
      members.isEmpty ? 0 : ((total / members.length) + 0.5).floor();

  final balances = members
      .map((name) => _Balance(name, (payments[name] ?? 0) - share))
      .toList();

  final creditors = balances.where((b) => b.balance > 0).toList()
    ..sort((a, b) => b.balance.compareTo(a.balance));
  final debtors = balances.where((b) => b.balance < 0).toList()
    ..sort((a, b) => a.balance.compareTo(b.balance));

  var i = 0;
  var j = 0;
  final tx = <SettlementTransaction>[];
  while (i < debtors.length && j < creditors.length) {
    final d = debtors[i];
    final c = creditors[j];
    final amt = (-d.balance < c.balance) ? -d.balance : c.balance;
    if (amt > 0) {
      tx.add(SettlementTransaction(from: d.name, to: c.name, amount: amt));
    }
    d.balance += amt;
    c.balance -= amt;
    if (d.balance.abs() < 1) i++;
    if (c.balance.abs() < 1) j++;
  }

  return SettlementResult(total: total, share: share, tx: tx);
}
