import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragment/fragment.dart';

// TODO test InheritedWidget

void main() {
  group('Fragment', () {
    testWidgets('should call builder only when deps are not identical',
        (tester) async {
      final buildLog = <int>[];
      await tester.pumpWidget(TestFragment(
        reportBuild: (v) => buildLog.add(v),
        key1: 1,
        key2: 2,
        key3: 3,
      ));
      await tester.pumpWidget(TestFragment(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: 2,
        key3: 3,
      ));
      await tester.pumpWidget(TestFragment(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: 2,
        key3: -3,
      ));
      await tester.pumpWidget(TestFragment(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: -2,
        key3: 3,
      ));
      expect(buildLog, [1, 2, 3, 1, 3, 2, 3]);
    });
  });
  group('Fragments', () {
    testWidgets('should rebuild subtree only when deps are not identical',
        (tester) async {
      final buildLog = <int>[];
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: 1,
        key2: 2,
        key3: 3,
      ));
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: 2,
        key3: 3,
      ));
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: 2,
        key3: -3,
      ));
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: -2,
        key3: 3,
      ));
      expect(buildLog, [1, 2, 3, 1, 3, 2, 3]);
    });
  });
}

class TestFragment extends StatefulWidget {
  final Function(int) reportBuild;
  final int key1;
  final int key2;
  final int key3;

  const TestFragment(
      {Key key, this.reportBuild, this.key1, this.key2, this.key3})
      : super(key: key);

  @override
  _TestFragmentState createState() => _TestFragmentState();
}

class _TestFragmentState extends State<TestFragment> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Fragment(
          builder: (BuildContext context) {
            context.widget;
            widget.reportBuild(1);
            return Container();
          },
          deps: [widget.key1],
        ),
        Fragment(
          builder: (BuildContext context) {
            widget.reportBuild(2);
            return Container();
          },
          deps: [widget.key2],
        ),
        Fragment(
          builder: (BuildContext context) {
            widget.reportBuild(3);
            return Container();
          },
          deps: [widget.key3],
        ),
      ],
    );
  }
}

class TestFragments extends StatefulWidget {
  final Function(int) reportBuild;
  final int key1;
  final int key2;
  final int key3;

  const TestFragments(
      {Key key, this.reportBuild, this.key1, this.key2, this.key3})
      : super(key: key);

  @override
  _TestFragmentsState createState() => _TestFragmentsState();
}

class _TestFragmentsState extends State<TestFragments> with Fragments {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        fragment(
          builder: () {
            widget.reportBuild(1);
            return Container();
          },
          deps: [widget.key1],
        ),
        fragment(
          builder: () {
            widget.reportBuild(2);
            return Container();
          },
          deps: [widget.key2],
        ),
        fragment(
          builder: () {
            widget.reportBuild(3);
            return Container();
          },
          deps: [widget.key3],
        ),
      ],
    );
  }
}
