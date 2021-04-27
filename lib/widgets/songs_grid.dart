import 'package:chhabrain_task_songslistener/screens/playMusic.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';

Widget songsGrid(List data) {
  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: 10),
    itemCount: data.length,
    itemBuilder: (context, index) {
      if (data[index] == null || data[index] == []) return Container();
      print(index);
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
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              Icon(Icons.favorite_outline_sharp,
                                  color: Colors.redAccent),
                              Text(data[index]['likes'].toString(),
                                  style: GoogleFonts.acme(
                                      fontSize: 12, color: Colors.black38)),
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
  );
}
