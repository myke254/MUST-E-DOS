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
      'title': 'file a complaint against a student',
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
    },
  ];
}

class DrawerData {
  var drawerTiles = [
    {
      'title': 'my requests',
      'hasSub': true,
      'sub': 'check the status of requests you\'ve submitted before',
      'image': 'assets/req.png',
      'color': Colors.greenAccent
    },
    {
      'title': 'Help',
      'hasSub': false,
      'sub': '',
      'image': 'assets/help.png',
      'color': Colors.white
    },
    {
      'title': 'F.A.Q',
      'hasSub': true,
      'sub': 'frequently asked questions',
      'image': 'assets/faq.png',
      'color': Colors.white
    }
  ];
}
