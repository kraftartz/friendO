import 'package:flutter/material.dart';
import 'package:friendo_ui/friendo_ui.dart' show Soft;

/// Build the app theme.
///
/// The only job here is to install the [Soft] tokens into
/// [ThemeData.extensions]. The values themselves live in friendo_ui, so
/// changing a colour or a radius needs no edit in this file.
/// The canvas behind a whole screen, from docs/DESIGN.md.
///
/// A chromatic night violet rather than black, so that a surface can sink into
/// it as well as rise out of it.
const canvasBase = Color(0xFF0D0B18);

ThemeData friendoTheme() => ThemeData.dark().copyWith(
  scaffoldBackgroundColor: canvasBase,
  extensions: const [Soft.dark()],
);
