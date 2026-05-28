import 'package:flutter/material.dart';

// MD3 seed color — purple aligns with Google's productivity suite aesthetic
const Color kSeedColor = Color(0xFF6750A4);

// Note card color palette (background fill, MD3 tonal approach)
const Map<String, Color> kNoteColors = {
  'red':    Color(0xFFFFDAD6),
  'orange': Color(0xFFFFDCC2),
  'yellow': Color(0xFFFFECB3),
  'green':  Color(0xFFD4EDDA),
  'teal':   Color(0xFFCCEFEF),
  'blue':   Color(0xFFD3E4FD),
  'purple': Color(0xFFEADDFF),
  'pink':   Color(0xFFFFD8E4),
  'brown':  Color(0xFFEDD5BE),
  'grey':   Color(0xFFE1E1E1),
};

// Eisenhower quadrant background tints
const Color kQuadrantDoColor       = Color(0xFFFFDAD6); // urgent + important
const Color kQuadrantScheduleColor = Color(0xFFD3E4FD); // not urgent + important
const Color kQuadrantDelegateColor = Color(0xFFFFECB3); // urgent + not important
const Color kQuadrantEliminateColor = Color(0xFFE1E1E1); // not urgent + not important
