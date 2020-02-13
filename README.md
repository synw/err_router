# Err router

A logs router that can pop messages to the device screen. 
Based on the [err](https://github.com/synw/err) package. The messages can be routed to:

- Terminal and on device console
- Flash messages
- Snackbar messages

## Usage

Initialize the logger

   ```dart
   import 'package:err_router/err_router.dart';

   final ErrRouter log = ErrRouter();
   ```

Create an error with the [Err](https://pub.dev/documentation/err/latest/err/Err-class.html) class:

   ```dart
   import 'package:err_router/err_router.dart';

   final err = Err.error("Network error");
   ```

### Console messages

![Screenshot](img/console.png)

To print an error and save it to history

   ```dart
   log.console(err);
   ```

Accepted arguments: an `Err` instance or a string

### Snackbar messages

![Screenshot](img/messages.png)

   ```dart
   log.screen(err);
   ```

### Flash messages

![Screenshot](img/info_flash.png)

The flash messages are toast messages. They stay one second on the screen

   ```dart
   log.flash(err);
   ```

### History

To access the history:

   ```dart
   final List<Err> history = log.history;
   ```

### On device console

Navigate to `DeviceConsolePage(log)` to see the console on the device

## Libraries used

- [Flutter toast](https://pub.dartlang.org/packages/fluttertoast)
- [Flushbar](https://pub.dartlang.org/packages/flushbar)
