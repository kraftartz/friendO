import 'package:flutter/material.dart';
import 'package:friendo_ui/friendo_ui.dart' show Soft;

/// Build the app theme.
///
/// The only job here is to install the [Soft] tokens into
/// [ThemeData.extensions]. The values themselves live in friendo_ui, so
/// changing a colour or a radius needs no edit in this file.
ThemeData friendoTheme() =>
    ThemeData.dark().copyWith(extensions: const [Soft.dark()]);
