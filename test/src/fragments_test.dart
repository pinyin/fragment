import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragment/fragment.dart';

// TODO test named subtrees

void main() {
  group('Fragments', () {
    testWidgets('should rebuild subtree only when deps are not identical',
        (tester) async {
      final buildLog = <int>[];
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: 1,
        key2: 2,
        key3: 3,
        key4: 4,
        child: Container(),
      ));
      expect(buildLog, [1, 4, 2, 3]);
      buildLog.clear();
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: 2,
        key3: 3,
        key4: 4,
        child: Container(),
      ));
      expect(buildLog, [1]);
      buildLog.clear();
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: 2,
        key3: -3,
        key4: 4,
        child: Container(),
      ));
      expect(buildLog, [3]);
      buildLog.clear();
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: -2,
        key3: 3,
        key4: 4,
        child: Container(),
      ));
      expect(buildLog, [2, 3]);
      buildLog.clear();
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: -2,
        key3: 3,
        key4: -4,
        child: Container(),
      ));
      expect(buildLog, [1, 4]);
      buildLog.clear();
    });
  });
}

class TestFragments extends StatefulWidget {
  final Function(int) reportBuild;
  final int key1;
  final int key2;
  final int key3;
  final int key4;
  final Widget child;

  const TestFragments(
      {Key key,
      this.reportBuild,
      this.key1,
      this.key2,
      this.key3,
      this.child,
      this.key4})
      : super(key: key);

  @override
  _TestFragmentsState createState() => _TestFragmentsState();
}

class _TestFragmentsState extends State<TestFragments> with Fragments {
  @override
  void initState() {
    super.initState();
    print('init');
  }

  @override
  Widget build(BuildContext context) {
    final s = fragment((_) => 'a', keys: []);
    assert(s is String);

    return Column(
      children: <Widget>[
        fragment((_) {
          widget.reportBuild(1);
          fragment((_) {
            widget.reportBuild(4);
          }, keys: [widget.key4]);
          return widget.child;
        }, keys: [widget.key1, widget.key4]),
        fragment((_) {
          widget.reportBuild(2);
          return widget.child;
        }, keys: [widget.key2]),
        fragment((_) {
          widget.reportBuild(3);
          return widget.child;
        }, keys: [widget.key3]),
      ],
    );
  }
}
