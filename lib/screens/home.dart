import 'package:chhabrain_task_songslistener/screens/playMusic.dart';
import 'package:chhabrain_task_songslistener/utils/manageFile.dart';
import 'package:chhabrain_task_songslistener/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
// import 'package:just_audio/just_audio.dart';

class Home extends StatefulWidget {
  static const routeName = "/home";
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  ManageFiles _manageFiles = ManageFiles();
  List<dynamic> result = [];
  List data = [];
  int index;

  ScrollController controller;
  Future<List> getData() async {
    return await _manageFiles.getSongs();
  }

  void _scrollListener() async {
    print("hi");
    if (controller.position.extentAfter < 300) {
      putData(index);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller = new ScrollController()..addListener(_scrollListener);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    putData(0);
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  Future<List> putData(int index) async {
    var rdata = await getData();
    if (data.length + 10 < rdata.length) {
      print("1");
      for (int i = index; i < index + 10; i++) {
        data.add(rdata[i]);
      }
      index += 10;
    } else if (data.length < rdata.length) {
      print("2");
      for (int i = data.length; i < rdata.length; i++) {
        data.add(rdata[i]);
      }
      index = rdata.length;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(context),
      backgroundColor: Colors.black38,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.audiotrack_rounded),
            tooltip: "Add music",
            onPressed: () {
              _manageFiles.pickFile();
            },
          ),
        ],
        backgroundColor: Colors.blue[900],
        title: Text(
          "Chhabrain Music",
          style: GoogleFonts.openSans(
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<List>(
        future: _manageFiles.getSongs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          result = snapshot.data;
          return (data.length == 0)
              ? Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/music.png"),
                      SizedBox(
                        height: 50,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: Text(
                          "Add music to the app",
                          style: GoogleFonts.openSans(
                              fontSize: 30, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                )
              : RefreshIndicator(
                  displacement: 100,
                  triggerMode: RefreshIndicatorTriggerMode.onEdge,
                  key: _refreshIndicatorKey,
                  onRefresh: () {
                    return _manageFiles.getSongs().then((value) {
                      setState(() {
                        putData(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Screen Refressed"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    });
                  },
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: controller,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, mainAxisSpacing: 10),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      print(data.length);
                      print("##########$data");
                      if (data.length == index)
                        return Center(child: CircularProgressIndicator());
                      if (data.length == 0 || data == []) {
                        return Container(
                          child: Column(
                            children: [
                              Image.asset("assets/music.png"),
                              Text(
                                "Add music to the app",
                                style: GoogleFonts.roboto(
                                    fontSize: 20, color: Colors.white),
                              )
                            ],
                          ),
                        );
                      }
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, PlayMusic.routeName,
                              arguments: data[index]);
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            child: Container(
                              width: 150,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Image.asset(
                                      "assets/headphone.png",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    color: Colors.grey[100],
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: 100,
                                            height: 50,
                                            child: Marquee(
                                              text: data[index]["name"],
                                              velocity: 30,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Column(
                                            children: [
                                              Icon(Icons.favorite_outline_sharp,
                                                  color: Colors.redAccent),
                                              Text(
                                                  data[index]['likes']
                                                      .toString(),
                                                  style: GoogleFonts.acme(
                                                      fontSize: 12,
                                                      color: Colors.black38)),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
        },
      ),
    );
  }
}
