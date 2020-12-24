import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Screens/login_page.dart';
import 'package:rsocial2/Screens/profile_page.dart';
import 'package:rsocial2/Screens/reaction_info.dart';
import 'package:rsocial2/Screens/search_page.dart';
import 'package:rsocial2/Widgets/request_tile.dart';
import '../constants.dart';
import '../post.dart';
import '../read_more.dart';
import '../user.dart';
import 'package:http/http.dart' as http;


class Reaction {
  Reaction({
    this.id,
    this.storyId,
    this.reactionType,
  });

  String id;
  String storyId;
  String reactionType;

  factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
    id: json["id"],
    storyId: json["StoryId"],
    reactionType: json["ReactionType"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "StoryId": storyId,
    "ReactionType": reactionType,
  };
}

class Post_Tile extends StatefulWidget {
  Post userPost;
  var photoUrl;
  Post_Tile({this.userPost,this.photoUrl});
  @override
  _Post_TileState createState() => _Post_TileState();
}

class _Post_TileState extends State<Post_Tile> {
  List<String> fileList = [];
  bool isLoading =true;
  List<User> liked = [];
  List<User> loved = [];
  List<User> whatever = [];
  List<User> hated = [];
  List<Request_Tile> love = [];
  List<Request_Tile> likes = [];
  String rxn;
  int lovedCounter=0;
  int likedCounter=0;
  int whateverCounter=0;
  int hatedCounter=0;


  getReactions()
  {
    for(int i=0;i<widget.userPost.reactedBy.length;i++)
      {
        User user = widget.userPost.reactedBy[i];

        if(user.reactionType=='liked')
          {
            liked.add(user);
            likedCounter++;
          }
        else if(user.reactionType=='loved')
          {
            loved.add(user);
            lovedCounter++;
          }
        else if(user.reactionType=='whatever')
          {
            whatever.add(user);
            whateverCounter++;
          }
        else if(user.reactionType=='hated') {
          hated.add(user);
          hatedCounter++;
        }

        if(user.id==curUser.id)
          this.rxn=user.reactionType;
      }
  }

  convertStringToFile()
  {
    for(int i=0;i<widget.userPost.fileUpload.length;i++)
      {
        //print("hehe");
        fileList.add(widget.userPost.fileUpload[i]);
      }
    //print(fileList.length);
    setState(() {
      isLoading=false;
    });
  }

  @override
  void initState() {
    super.initState();
    getReactions();
    convertStringToFile();
  }

  showProfile(BuildContext context, User user,String photourl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(
          currentUser: curUser,
          photoUrl: photourl,
          user: user,
        ),
      ),
    );
  }

  react(String reactn) async {
    var url =
        'https://t43kpz2m5d.execute-api.ap-south-1.amazonaws.com/story/react';
    var user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot doc = await users.document(user.uid).get();
    var uid = doc['id'];
    //print(uid);
    Reaction reaction = Reaction(
      id: uid,
      storyId: widget.userPost.id,
      reactionType: reactn
    );
    var token = await user.getIdToken();
    //print(jsonEncode(reaction.toJson()));
    //print(token);
    var response = await http.put(
      url,
      encoding: Encoding.getByName("utf-8"),
      body: jsonEncode(reaction.toJson()),
      headers: {
        "Authorization": "Bearer: $token",
        "Content-Type": "application/json",
      },
    );
    print(response.statusCode);
    if(response.statusCode==200) {
      print(response.body);
      setState(() {
        String prevrxn =rxn;
        rxn=reactn;

        for(int i=0;i<widget.userPost.reactedBy.length;i++)
        {
          User user = widget.userPost.reactedBy[i];
          if(user.id==curUser.id)
            user.reactionType=reactn;
        }
        if(prevrxn!=rxn && rxn!="noreact")
          {
            if(prevrxn=="loved")
              lovedCounter--;
            else if(prevrxn=='liked')
              likedCounter--;
            else if(prevrxn=='whatever')
              whateverCounter--;
            else if(prevrxn=='hated')
              hatedCounter--;
          }
      });
    }
  }

  buildReactionTile()
  {
    for(int i=0;i<loved.length;i++)
      {
        Request_Tile tile = Request_Tile(request: false,text: "",user: loved[i],photourl: loved[i].photoUrl,curUser: curUser,);
        love.add(tile);
      }

    for(int i=0;i<liked.length;i++)
    {
      Request_Tile tile = Request_Tile(request: false,text: "",user: liked[i],photourl: liked[i].photoUrl,curUser: curUser,);
      likes.add(tile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Container(
        //margin: EdgeInsets.only(top: 5,bottom: 5),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(right: 15,left: 15,top: 15,bottom: 15),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: widget.userPost.storyType=="Wage" ? ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.only(left: 0,right: -35,bottom: 0),
                    leading: GestureDetector(
                      onTap: ()=>showProfile(context, widget.userPost.user,
                          widget.userPost.user.photoUrl),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(widget.userPost.user.photoUrl),
                      ),
                    ),
                    title: Text(
                      "${widget.userPost.user.fname} ${widget.userPost.user.lname}",
                      style: TextStyle(
                        //fontWeight: FontWeight.bold,
                        fontFamily: "Lato",
                        fontSize:14,
                        color:nameCol,
                      ),),
                  ) : ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.only(left: 0,right: -35,bottom: 0),
                    leading: GestureDetector(
                      onTap: ()=>showProfile(context, widget.userPost.user,
                          widget.userPost.user.photoUrl),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(widget.userPost.user.photoUrl),
                      ),
                    ),
                    title: Text(
                      "${widget.userPost.user.fname} ${widget.userPost.user.lname}",
                      style: TextStyle(
                      //fontWeight: FontWeight.bold,
                      fontFamily: "Lato",
                      fontSize:14,
                      color:nameCol,
                    ),),
                    subtitle:
                    Text( widget.userPost.investedWithUser==null ? "Investing alone" :
                    "Investing with ${widget.userPost.investedWithUser[0].fname} ${widget.userPost.investedWithUser[0].lname}",
                      style: TextStyle(
                        fontFamily: "Lato",
                        fontSize:12,
                        color:subtitile,
                      ),
                    ) ,
                  ),
                ),
                //SizedBox(width: 1,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    widget.userPost.storyType=="Wage" ? SizedBox() :
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            SvgPicture.asset("images/coins.svg",color: colorCoins,),
                            Container(
                              child: Text("Invested",
                                style: TextStyle(
                                    fontFamily: "Lato",
                                  fontSize:12,
                                    color:subtitile),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6,),
                        Container(
                          child: Text("${widget.userPost.investedAmount}",
                            style: TextStyle(
                              fontFamily: "Lato",
                              fontSize:12,color:Color(0xff4DBAE6),
                            ),
                          ),
                          //transform: Matrix4.translationValues(-35, 0.0, 0.0),
                        ),
                      ],
                    ),
                    SizedBox(width: 14,),
                    widget.userPost.storyType=="Wage" ? SizedBox() :
                        SizedBox(),
                    // Column(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: <Widget>[
                    //     Row(
                    //       children: <Widget>[
                    //         SvgPicture.asset("images/coins.svg",color: colorCoins,),
                    //
                    //         Container(
                    //           //transform: Matrix4.translationValues(-38, 0.0, 0.0),
                    //           child: Text("Profit",
                    //             style: TextStyle(
                    //               fontFamily: "Lato",
                    //               fontSize:12,color:subtitile,
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //     SizedBox(height: 6,),
                    //     Container(
                    //       child: Text("500",
                    //         style: TextStyle(
                    //           fontFamily: "Lato",
                    //           fontSize:12,color:Color(0xff37B44B),
                    //         ),
                    //     //     TextStyle(
                    //     //     fontSize: 12,
                    //     //     color: Color(0xff37B44B)
                    //     // ),
                    //       ),
                    //       //transform: Matrix4.translationValues(-35, 0.0, 0.0),
                    //     ),
                    //   ],
                    // ),
                    SizedBox(width: 14,),

                    if(lovedCounter==0 && likedCounter==0 && whateverCounter==0 && hatedCounter==0)
                      SizedBox()
                    else if(lovedCounter>=likedCounter && lovedCounter>=whateverCounter && lovedCounter>=hatedCounter)
                      SvgPicture.asset("images/loved.svg",
                        color: colorPrimaryBlue,
                      )
                    else if(likedCounter>lovedCounter && likedCounter>=whateverCounter && likedCounter>=hatedCounter)
                        SvgPicture.asset("images/liked.svg",
                          color: colorPrimaryBlue,
                        )
                    else if(whateverCounter>lovedCounter && whateverCounter>likedCounter && whateverCounter>=hatedCounter)
                          SvgPicture.asset("images/whatever.svg",
                            color: colorPrimaryBlue,
                          )
                    else if(hatedCounter>likedCounter && hatedCounter>lovedCounter && hatedCounter>whateverCounter)
                      SvgPicture.asset("images/hated.svg",
                            color: colorPrimaryBlue,
                          ),
                    //SizedBox(width: 14,),
                    GestureDetector(
                        onTap: (){
                          buildReactionTile();
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>Reaction_Info(like: likes,love: love,)));},
                        child: Icon(
                          Icons.more_vert,
                          color: Color(0xff707070),
                          size: 30,)
                    ),
                  ],
                ),
              ],
            ),
            widget.userPost.storyText==null ? Container(height: 0,) : Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Read_More(
                 "${widget.userPost.storyText}",
                  trimLines: 2,
                  colorClickableText: Colors.blueGrey,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: "...Show More",
                  trimExpandedText: " Show Less",
                  style: TextStyle(
                    fontSize:14,
                    fontFamily: "Lato",
                    color: postDesc,
                  ),
                )
              /*Text(
                "today was a great day with my cats! ",
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                softWrap: true,
                style: GoogleFonts.lato(
                  fontSize:15,
                  color: postDesc,
                ),
                //textAlign: TextAlign.left,
              ),*/
            ),
            Padding(
              padding: widget.userPost.storyText==null ? EdgeInsets.only(top: 0,bottom: 15) :EdgeInsets.symmetric(vertical: 15),
              child: Container(
                height: widget.userPost.fileUpload.length != 0 ? 250 : 0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8)
                ),
                child: isLoading==false?Swiper(
                    loop: false,
                    pagination: SwiperPagination(),
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.userPost.fileUpload.length,
                    itemBuilder:
                        (BuildContext context, int index) {
                      return Stack(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.withOpacity(0.2),
                                image: DecorationImage(
                                    image: NetworkImage(
                                      fileList[index],
                                    ),
                                    fit: BoxFit.cover)),
                            height: 250,
                          ),
                          // Container(
                          //   decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.only(
                          //           bottomRight:
                          //           Radius.circular(8)),
                          //       color: Colors.red
                          //           .withOpacity(0.2)),
                          //   child: IconButton(
                          //     icon: Icon(
                          //       Icons.clear,
                          //     ),
                          //     onPressed: () {
                          //       setState(() {
                          //         fileList.removeAt(index);
                          //         list.removeAt(index);
                          //       });
                          //     },
                          //   ),
                          // )
                        ],
                      );
                    }): Center(
                  child: CircularProgressIndicator(),
                )
              )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[

                      GestureDetector(
                        onTap:()=> { rxn=='loved' ? {
                          react("noreact"),
                          lovedCounter--
                        }: {react("loved"),
                          lovedCounter++
                        }},
                        child: Column(
                          children: <Widget>[
                            SvgPicture.asset("images/loved.svg",
                              color: rxn=="loved" ? colorPrimaryBlue : postIcons,),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(lovedCounter.toString(),
                                style: TextStyle(
                                fontFamily: "Lato",
                                fontSize:10,
                                color: postDesc,
                              ),),
                            )
                          ],
                        ),
                      ),

                      SizedBox(width: 20,),
                      GestureDetector(
                        onTap:()=>{ rxn=='liked' ? {
                          react("noreact"),
                          likedCounter--
                        }: {
                          react("liked"),
                          likedCounter++
                        }
                        },
                        child: Column(
                          children: <Widget>[
                            SvgPicture.asset("images/liked.svg",
                              color: rxn=="liked" ? colorPrimaryBlue :postIcons,),
                            //Icon(Icons.thumb_up,size: 30,color:postIcons),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(likedCounter.toString(),
                                style: TextStyle(
                                fontFamily: "Lato",
                                fontSize:10,
                                color: postDesc,
                              ),),
                            )
                          ],
                        ),
                      ),


                      SizedBox(width: 20),
                      GestureDetector(
                        onTap:()=>{ rxn=='whatever' ? {react("noreact"), whateverCounter-- }: {react("whatever"), whateverCounter++}},
                        child: Column(
                          children: <Widget>[
                            SvgPicture.asset("images/whatever.svg",
                              color: rxn=="whatever" ? colorPrimaryBlue : postIcons,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(whateverCounter.toString(),style: TextStyle(
                                fontFamily: "Lato",
                                fontSize:10,
                                color: postDesc,
                              ),),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 20,),
                      GestureDetector(
                        onTap:()=>{ rxn=='hated' ? {react("noreact"), hatedCounter-- }: {react("hated"), hatedCounter++}},
                        child: Column(
                          children: <Widget>[
                            SvgPicture.asset("images/hated.svg",
                              color: rxn=="hated" ? colorPrimaryBlue : postIcons,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(hatedCounter.toString(),style: TextStyle(
                                fontFamily: "Lato",
                                fontSize:10,
                                color: postDesc,
                              ),),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20,),
                //Container(),


                Column(
                  children: <Widget>[
                    SvgPicture.asset("images/share.svg",color: postIcons,),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("Share",style: TextStyle(
                        fontFamily: "Lato",
                        fontSize:10,
                        color: postDesc,
                      ),),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
