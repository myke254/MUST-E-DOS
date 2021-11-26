import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:office_of_the_dean/screens/responses.dart';
import 'package:office_of_the_dean/services/auth_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class Items extends StatelessWidget {
  const Items({
    Key? key,
    required this.size,
    required this.icon,
    required this.onTap,
    required this.label,
    required this.color,
  }) : super(key: key);

  final size;
  final IconData icon;
  final Function() onTap;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadiusDirectional.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            width: size.width / 2.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                ),
                Text(
                  label,
                  style: GoogleFonts.varela(
                      fontSize: 12, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Cards extends StatefulWidget {
  const Cards({
    Key? key,
    required this.label,
    required this.img,
    required this.taps,
  }) : super(key: key);

  final String label;
  final String img;

  final Function() taps;

  @override
  _CardsState createState() => _CardsState();
}

class _CardsState extends State<Cards> with TickerProviderStateMixin {
  late AnimationController animationController;
  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: new Duration(seconds: 2), vsync: this);
    animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 15,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.taps,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            CachedNetworkImage(
              height: 80,
              width: 100,
              imageUrl: widget.img,
              placeholder: (context, url) => Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: animationController.drive(ColorTween(
                          begin: Colors.pink, end: Colors.amberAccent)),
                    ),
                  )),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.aBeeZee(),
            )
          ],
        ),
      ),
    );
  }
}

class Tiles extends StatefulWidget {
  const Tiles(
      {Key? key,
      required this.label,
      required this.img,
      required this.docLength})
      : super(key: key);
  final String label;
  final String img;
  final docLength;

  @override
  _TilesState createState() => _TilesState();
}

class _TilesState extends State<Tiles> with TickerProviderStateMixin {
  late AnimationController animationController;
  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: new Duration(seconds: 2), vsync: this);
    animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: firestore.collection('requests').doc(widget.label).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          return ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            tileColor: Colors.grey.withOpacity(.1),
            subtitle: snapshot.hasData
                ? Text(
                    snapshot.data!.data() != null
                        ? 'latest request received ${timeago.format(snapshot.data!['latestDocTime'].toDate())}'
                        : '',
                    style: GoogleFonts.monda(
                        fontStyle: FontStyle.italic, fontSize: 12),
                  )
                : SizedBox(),
            onTap: widget.docLength != 0
                ? () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ReceivedRequests(
                          img: widget.img,
                          docId: widget.label,
                          appBarText: widget.label,
                        )))
                : () {},
            leading: CachedNetworkImage(
              height: 50,
              width: 50,
              imageUrl: widget.img,
              placeholder: (context, url) => Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: animationController.drive(ColorTween(
                          begin: Colors.pink, end: Colors.amberAccent)),
                    ),
                  )),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            title: Text(
              widget.label,
              style: GoogleFonts.monda(),
            ),
            trailing: Container(
              height: 30,
              width: 30,
              child: widget.docLength != 0
                  ? Card(
                      color: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Center(
                          child: Text(
                        widget.docLength.toString(),
                        style: GoogleFonts.monda(color: Colors.white),
                      )),
                    )
                  : Container(),
            ),
          );
        });
  }
}

class BottomBarTiles extends StatefulWidget {
  const BottomBarTiles(
      {Key? key,
      this.image,
      this.title,
      this.hasSubtitle,
      this.subtitle,
      this.index,
      this.color})
      : super(key: key);
  final image;
  final title;
  final hasSubtitle;
  final subtitle;
  final index;
  final color;
  @override
  _BottomBarTilesState createState() => _BottomBarTilesState();
}

class _BottomBarTilesState extends State<BottomBarTiles> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      onTap: () {
        print(widget.index);
      },
      leading: Card(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
                color: widget.color, borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: Image.asset(
                widget.image,
                height: 25,
                width: 25,
              ),
            ),
          ),
        ),
      ),
      title: Text(
        widget.title,
        style: GoogleFonts.varela(),
      ),
      subtitle: widget.hasSubtitle ? Text(widget.subtitle) : SizedBox(),
    );
  }
}
