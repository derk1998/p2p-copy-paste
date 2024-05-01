// Mocks generated by Mockito 5.4.4 from annotations
// in p2p_copy_paste/test/create_invite_screen_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:flutter/material.dart' as _i1;
import 'package:mockito/mockito.dart' as _i2;
import 'package:p2p_copy_paste/lifetime.dart' as _i5;
import 'package:p2p_copy_paste/models/invite.dart' as _i6;
import 'package:p2p_copy_paste/navigation_manager.dart' as _i7;
import 'package:p2p_copy_paste/services/clipboard.dart' as _i9;
import 'package:p2p_copy_paste/services/create_connection.dart' as _i8;
import 'package:p2p_copy_paste/create_invite/create_invite_service.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeGlobalKey_0<T extends _i1.State<_i1.StatefulWidget>>
    extends _i2.SmartFake implements _i1.GlobalKey<T> {
  _FakeGlobalKey_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [ICreateInviteService].
///
/// See the documentation for Mockito's code generation for more information.
class MockICreateInviteService extends _i2.Mock
    implements _i3.ICreateInviteService {
  MockICreateInviteService() {
    _i2.throwOnMissingStub(this);
  }

  @override
  _i4.Future<void> create(
    void Function(_i3.CreateInviteUpdate)? onCreateInviteUpdate,
    WeakReference<_i5.LifeTime>? lifeTime,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #create,
          [
            onCreateInviteUpdate,
            lifeTime,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<bool> accept(_i6.Invite? invite) => (super.noSuchMethod(
        Invocation.method(
          #accept,
          [invite],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<bool> decline(_i6.Invite? invite) => (super.noSuchMethod(
        Invocation.method(
          #decline,
          [invite],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);
}

/// A class which mocks [INavigator].
///
/// See the documentation for Mockito's code generation for more information.
class MockINavigator extends _i2.Mock implements _i7.INavigator {
  MockINavigator() {
    _i2.throwOnMissingStub(this);
  }

  @override
  void replaceScreen(_i1.Widget? view) => super.noSuchMethod(
        Invocation.method(
          #replaceScreen,
          [view],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void pushScreen(_i1.Widget? view) => super.noSuchMethod(
        Invocation.method(
          #pushScreen,
          [view],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i1.GlobalKey<_i1.NavigatorState> getNavigatorKey() => (super.noSuchMethod(
        Invocation.method(
          #getNavigatorKey,
          [],
        ),
        returnValue: _FakeGlobalKey_0<_i1.NavigatorState>(
          this,
          Invocation.method(
            #getNavigatorKey,
            [],
          ),
        ),
      ) as _i1.GlobalKey<_i1.NavigatorState>);

  @override
  void goToHome() => super.noSuchMethod(
        Invocation.method(
          #goToHome,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void popScreen() => super.noSuchMethod(
        Invocation.method(
          #popScreen,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void pushDialog(_i1.Widget? view) => super.noSuchMethod(
        Invocation.method(
          #pushDialog,
          [view],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [ICreateConnectionService].
///
/// See the documentation for Mockito's code generation for more information.
class MockICreateConnectionService extends _i2.Mock
    implements _i8.ICreateConnectionService {
  MockICreateConnectionService() {
    _i2.throwOnMissingStub(this);
  }

  @override
  _i4.Future<void> startNewConnection() => (super.noSuchMethod(
        Invocation.method(
          #startNewConnection,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  void setOnConnectionIdPublished(
          void Function(String)? onConnectionIdPublished) =>
      super.noSuchMethod(
        Invocation.method(
          #setOnConnectionIdPublished,
          [onConnectionIdPublished],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setOnConnectedListener(void Function()? onConnectedListener) =>
      super.noSuchMethod(
        Invocation.method(
          #setOnConnectedListener,
          [onConnectedListener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void close() => super.noSuchMethod(
        Invocation.method(
          #close,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setOnConnectionClosedListener(
          void Function()? onConnectionClosedListener) =>
      super.noSuchMethod(
        Invocation.method(
          #setOnConnectionClosedListener,
          [onConnectionClosedListener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setOnReceiveDataListener(void Function(String)? onReceiveDataListener) =>
      super.noSuchMethod(
        Invocation.method(
          #setOnReceiveDataListener,
          [onReceiveDataListener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void sendData(String? data) => super.noSuchMethod(
        Invocation.method(
          #sendData,
          [data],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [IClipboardService].
///
/// See the documentation for Mockito's code generation for more information.
class MockIClipboardService extends _i2.Mock implements _i9.IClipboardService {
  MockIClipboardService() {
    _i2.throwOnMissingStub(this);
  }

  @override
  _i4.Future<String?> get() => (super.noSuchMethod(
        Invocation.method(
          #get,
          [],
        ),
        returnValue: _i4.Future<String?>.value(),
      ) as _i4.Future<String?>);

  @override
  void set(String? data) => super.noSuchMethod(
        Invocation.method(
          #set,
          [data],
        ),
        returnValueForMissingStub: null,
      );
}
