import 'package:flutter/foundation.dart' as _i3;
import 'package:flutter/src/widgets/framework.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

class _FakeWidget_0 extends _i1.Fake implements _i2.Widget {
  @override
  String toString({_i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeInheritedWidget_1 extends _i1.Fake implements _i2.InheritedWidget {
  @override
  String toString({_i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeDiagnosticsNode_2 extends _i1.Fake implements _i3.DiagnosticsNode {
  @override
  String toString(
          {_i3.TextTreeConfiguration? parentConfiguration,
          _i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.info}) =>
      super.toString();
}

/// A class which mocks [BuildContext].
///
/// See the documentation for Mockito's code generation for more information.
class MockBuildContext extends _i1.Mock implements _i2.BuildContext {
  MockBuildContext() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Widget get widget => (super.noSuchMethod(Invocation.getter(#widget),
      returnValue: _FakeWidget_0()) as _i2.Widget);
  @override
  bool get debugDoingBuild => (super
          .noSuchMethod(Invocation.getter(#debugDoingBuild), returnValue: false)
      as bool);
  @override
  _i2.InheritedWidget dependOnInheritedElement(_i2.InheritedElement? ancestor,
          {Object? aspect}) =>
      (super.noSuchMethod(
          Invocation.method(
              #dependOnInheritedElement, [ancestor], {#aspect: aspect}),
          returnValue: _FakeInheritedWidget_1()) as _i2.InheritedWidget);
  @override
  void visitAncestorElements(bool Function(_i2.Element)? visitor) =>
      super.noSuchMethod(Invocation.method(#visitAncestorElements, [visitor]),
          returnValueForMissingStub: null);
  @override
  void visitChildElements(_i2.ElementVisitor? visitor) =>
      super.noSuchMethod(Invocation.method(#visitChildElements, [visitor]),
          returnValueForMissingStub: null);
  @override
  _i3.DiagnosticsNode describeElement(String? name,
          {_i3.DiagnosticsTreeStyle? style =
              _i3.DiagnosticsTreeStyle.errorProperty}) =>
      (super.noSuchMethod(
          Invocation.method(#describeElement, [name], {#style: style}),
          returnValue: _FakeDiagnosticsNode_2()) as _i3.DiagnosticsNode);
  @override
  _i3.DiagnosticsNode describeWidget(String? name,
          {_i3.DiagnosticsTreeStyle? style =
              _i3.DiagnosticsTreeStyle.errorProperty}) =>
      (super.noSuchMethod(
          Invocation.method(#describeWidget, [name], {#style: style}),
          returnValue: _FakeDiagnosticsNode_2()) as _i3.DiagnosticsNode);
  @override
  List<_i3.DiagnosticsNode> describeMissingAncestor(
          {Type? expectedAncestorType}) =>
      (super.noSuchMethod(
          Invocation.method(#describeMissingAncestor, [],
              {#expectedAncestorType: expectedAncestorType}),
          returnValue: <_i3.DiagnosticsNode>[]) as List<_i3.DiagnosticsNode>);
  @override
  _i3.DiagnosticsNode describeOwnershipChain(String? name) =>
      (super.noSuchMethod(Invocation.method(#describeOwnershipChain, [name]),
          returnValue: _FakeDiagnosticsNode_2()) as _i3.DiagnosticsNode);
}
