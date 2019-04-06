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
        child: Container(),
      ));
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: 2,
        key3: 3,
        child: Container(),
      ));
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: 2,
        key3: -3,
        child: Container(),
      ));
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: -2,
        key3: 3,
        child: Container(),
      ));
      expect(buildLog, [1, 2, 3, 1, 3, 2, 3]);
    });
    testWidgets('should rebuild subtree when new root is of another type',
        (tester) async {
      final buildLog = <int>[];
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: 1,
        key2: 2,
        key3: 3,
        child: Container(),
      ));
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: 1,
        key2: 2,
        key3: 3,
        child: Text('', textDirection: TextDirection.ltr),
      ));
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: 2,
        key3: 3,
        child: Text('', textDirection: TextDirection.ltr),
      ));
      expect(buildLog, [1, 2, 3, 1, 2, 3, 1]);
    });
  });
}

class TestFragments<T extends Widget> extends StatefulWidget {
  final Function(int) reportBuild;
  final int key1;
  final int key2;
  final int key3;
  final T child;

  const TestFragments(
      {Key key, this.reportBuild, this.key1, this.key2, this.key3, this.child})
      : super(key: key);

  @override
  _TestFragmentsState<T> createState() => _TestFragmentsState<T>();
}

class _TestFragmentsState<T extends Widget> extends State<TestFragments<T>>
    with Fragments {
  @override
  Widget build(BuildContext context) {
    final s = fragment(() => 'a', deps: []);
    assert(s is String);

    return Column(
      children: <Widget>[
        fragment(() {
          widget.reportBuild(1);
          return widget.child;
        }, deps: [widget.key1]),
        fragment(() {
          widget.reportBuild(2);
          return widget.child;
        }, deps: [widget.key2]),
        fragment(() {
          widget.reportBuild(3);
          return widget.child;
        }, deps: [widget.key3]),
      ],
    );
  }
}

class S extends StatefulWidget {
  @override
  _SState createState() => _SState();
}

class _SState extends State<S> with Fragments {
  String text;

  @override
  Widget build(BuildContext context) {
    return fragment(() => Text(text), deps: [text]);
  }
}
