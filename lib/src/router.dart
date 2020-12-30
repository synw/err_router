import 'package:err/err.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'log.dart';

/// The error router
class ErrRouter {
  /// The main constructor
  ErrRouter();

  final ErrLogger _errLogger = ErrLogger();
  final int _maxDeviceConsoleMessages = 100;
  //final _messages = <String>[];

  /// The [Err] log history
  List<Err> get history => _errLogger.errs;

  /// Print an error to the console
  ///
  /// If [err] is not an [Err] it will be
  /// translated to a string as the message.
  /// Provide a [String] to just display a message
  void console(dynamic err) {
    switch (err is Err) {
      case true:
        final _err = err as Err;
        _dispatch(_err);
        _addErrToErrLogger(_err);
        break;
      default:
        final _msg = "$err";
        _dispatch(Err.fromType(_msg, ErrType.debug));
        _addStringToErrLogger(_msg, ErrType.debug);
    }
  }

  /// Display this [Err] to the user screen (flushbar)
  ///
  /// If [err] is not an [Err] it will be
  /// translated to a string as the message.
  /// Provide a [String] to just display a message
  void screen(dynamic err, BuildContext context) {
    assert(err != null);
    switch (err is Err) {
      case true:
        final _err = err as Err;
        _dispatch(_err, toScreen: true, context: context);
        _addErrToErrLogger(_err);
        break;
      default:
        final _msg = "$err";
        _dispatch(Err.fromType(_msg, ErrType.info),
            toScreen: true, context: context);
        _addStringToErrLogger(_msg, ErrType.info);
    }
  }

  /// Flash this [Err] to the user screen (toast)
  ///
  /// If [err] is not an [Err] it will be
  /// translated to a string as the message.
  /// Provide a [String] to just display a message
  /// Limitations: this method only works for mobile
  void flash(dynamic err) {
    switch (err is Err) {
      case true:
        final _err = err as Err;
        _dispatch(_err, toScreen: true, flash: true);
        _addErrToErrLogger(_err);
        break;
      default:
        final _msg = "$err";
        _dispatch(Err.fromType(_msg, ErrType.info),
            toScreen: true, flash: true);
        _addStringToErrLogger(_msg, ErrType.info);
    }
  }

  // ********************************
  //        Private methods
  // ********************************

  void _addErrToErrLogger(Err err) => _errLogger.add(err);

  void _addStringToErrLogger(String msg, ErrType errType) =>
      _errLogger.add(Err.fromType(msg, errType));

  void _dispatch(Err err,
      {BuildContext context,
      bool short = false,
      bool flash = false,
      int timeOnScreen = 1,
      bool toScreen = false}) {
    final _errMsg = err.message;
    // log to history
    _errLogger.errs.insert(0, err);
    if (_errLogger.errs.length > _maxDeviceConsoleMessages) {
      _errLogger.errs.removeLast();
    }
    // console log
    err.console();
    // screen log
    if (toScreen) {
      var msg = _errMsg;
      if (err.userMessage != null) {
        msg = err.userMessage;
      }
      final _err = _buildScreenMessage(err.type, msg,
          short: short, flash: flash, timeOnScreen: timeOnScreen);
      _popMsg(err: _err, context: context);
    }
  }

  _ErrDisplay _buildScreenMessage(ErrType _errType, String _errMsg,
      {bool short = false, bool flash = false, int timeOnScreen}) {
    switch (flash) {
      case true:
        final colors = _getColors(_errType);
        return _ErrDisplay(
            msg: _errMsg,
            type: _errType,
            toast: _ShortToast(
                errMsg: _errMsg,
                timeOnScreen: timeOnScreen,
                backgroundColor: colors["background_color"],
                textColor: colors["text_color"]));
    }
    return _ErrDisplay(
        msg: _errMsg,
        type: _errType,
        flushbar: _buildFlushbar(_errType, _errMsg, short: short));
  }

  void _popMsg({_ErrDisplay err, BuildContext context}) {
    switch (err.flushbar != null) {
      case true:
        err.show(context);
        break;
      default:
        err.show();
    }
  }

  Flushbar _buildFlushbar(ErrType _errType, String _errMsg,
      {bool short = false}) {
    final colors = _getColors(_errType);
    IconData _icon;
    final _backgroundColor = colors["background_color"];
    var _iconColor = Colors.white;
    Color _leftBarIndicatorColor;
    final _textColor = colors["text_color"];
    switch (_errType) {
      case ErrType.critical:
        _icon = Icons.error;
        _iconColor = Colors.red;
        _leftBarIndicatorColor = Colors.red;
        break;
      case ErrType.error:
        _icon = Icons.error_outline;
        _leftBarIndicatorColor = Colors.black;
        break;
      case ErrType.warning:
        _icon = Icons.warning;
        _leftBarIndicatorColor = Colors.black;
        break;
      case ErrType.info:
        _icon = Icons.info;
        break;
      case ErrType.debug:
        _icon = Icons.bug_report;
        _leftBarIndicatorColor = Colors.black;
        break;
    }
    Flushbar flush;
    flush = Flushbar<dynamic>(
      duration: short ? const Duration(seconds: 5) : const Duration(days: 365),
      icon: Icon(
        _icon,
        color: _iconColor,
        size: 35.0,
      ),
      leftBarIndicatorColor: _leftBarIndicatorColor,
      backgroundColor: _backgroundColor,
      messageText: Text(
        _errMsg,
        style: TextStyle(color: _textColor),
      ),
      titleText: Text(
        _getErrTypeString(_errType),
        style: TextStyle(color: _textColor),
        textScaleFactor: 1.6,
      ),
      isDismissible: true,
      mainButton: FlatButton(
        child: const Text("Ok"),
        onPressed: () => flush.dismiss(true),
      ),
    );
    return flush;
  }

  Map<String, Color> _getColors(ErrType _errType) {
    var _backgroundColor = Colors.black;
    var _textColor = Colors.white;
    switch (_errType) {
      case ErrType.critical:
        _backgroundColor = Colors.black;
        break;
      case ErrType.error:
        _backgroundColor = Colors.red;
        break;
      case ErrType.warning:
        _backgroundColor = Colors.deepOrange;
        break;
      case ErrType.info:
        _backgroundColor = Colors.lightBlueAccent;
        _textColor = Colors.black;
        break;
      case ErrType.debug:
        _backgroundColor = Colors.purple;
        break;
    }
    return {
      "background_color": _backgroundColor,
      "text_color": _textColor,
    };
  }

  String _getErrTypeString(ErrType _errType) {
    String type;
    switch (_errType) {
      case ErrType.critical:
        type = "Critical";
        break;
      case ErrType.error:
        type = "Error";
        break;
      case ErrType.warning:
        type = "Warning";
        break;
      case ErrType.info:
        type = "Info";
        break;
      case ErrType.debug:
        type = "Debug";
        break;
    }
    return type;
  }
}

class _ErrDisplay {
  _ErrDisplay(
      {@required this.msg, @required this.type, this.flushbar, this.toast});

  final Flushbar flushbar;
  final _ShortToast toast;
  final String msg;
  final ErrType type;

  /// The show method to pop the message on screen if needed.
  ///
  /// A [BuildContext] is required only for [Flushbar] messages,
  /// not the flash messages that use [Toast]
  void show([BuildContext context]) {
    if (toast != null) {
      toast.show();
      return;
    }
    if (flushbar != null) {
      if (context == null) {
        throw ArgumentError(
            "Pass the context to show if you use anything other "
            "than flash messages");
      }
      flushbar.show(context);
      return;
    }
  }
}

class _ShortToast {
  _ShortToast(
      {@required this.backgroundColor,
      @required this.textColor,
      @required this.errMsg,
      this.timeOnScreen});

  final Color backgroundColor;
  final Color textColor;
  final String errMsg;
  final int timeOnScreen;

  void show([BuildContext _]) {
    Fluttertoast.showToast(
        msg: errMsg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: timeOnScreen,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: 16.0);
  }
}
