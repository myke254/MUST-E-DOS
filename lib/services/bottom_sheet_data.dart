import 'package:flutter/material.dart';

class BottomSheetData {
  var bottomSheetTiles = [
    {
      'title': 'report missing documents',
      'hasSub': true,
      'sub': 'e.g. missing ID, passport, ... etc.',
      'image': 'assets/id.png',
      'color': Colors.greenAccent
    },
    {
      'title': 'file a complaint against a student\n(NITAKUSEMA KWA DEAN😩😩)',
      'hasSub': true,
      'sub': 'e.g. bully, rogue behavior, ... etc.',
      'image': 'assets/bully.png',
      'color': Colors.pink
    },
    {
      'title': 'check out lost and found items',
      'hasSub': false,
      'sub': '',
      'image': 'assets/lostnfound.png',
      'color': Colors.blue
    },
    {
      'title': 'contact the office of the dean',
      'hasSub': false,
      'sub': '',
      'image': 'assets/contact.png',
      'color': Colors.green
    }
  ];
}
