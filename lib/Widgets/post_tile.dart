import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/Screens/profile_page.dart';
import 'package:rsocial2/Screens/reaction_info.dart';
import '../constants.dart';
import '../post.dart';
import '../read_more.dart';
import '../user.dart';

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
                  child: widget.userPost.storyType=="W" ? ListTile(
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
                    "Investing with ${widget.userPost.investedWithUser.fname} ${widget.userPost.investedWithUser.lname}",
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
                    widget.userPost.storyType=="W" ? SizedBox() :
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
                    widget.userPost.storyType=="W" ? SizedBox() :
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
                    // Icon(Icons.favorite, color: Colors.pink),
                    // //SizedBox(width: 14,),
                    GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>Reaction_Info()));},
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
                      Column(
                        children: <Widget>[
                          SvgPicture.asset("images/fav.svg",color: postIcons,),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text("20",style: TextStyle(
                              fontFamily: "Lato",
                              fontSize:10,
                              color: postDesc,
                            ),),
                          )
                        ],
                      ),
                      SizedBox(width: 20,),
                      Column(
                        children: <Widget>[
                          SvgPicture.asset("images/thumb_up.svg",color: postIcons,),
                          //Icon(Icons.thumb_up,size: 30,color:postIcons),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text("20",
                              style: TextStyle(
                              fontFamily: "Lato",
                              fontSize:10,
                              color: postDesc,
                            ),),
                          )
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        children: <Widget>[
                          SvgPicture.asset("images/thumb_down.svg",color: postIcons,),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text("20",style: TextStyle(
                              fontFamily: "Lato",
                              fontSize:10,
                              color: postDesc,
                            ),),
                          )
                        ],
                      ),
                      SizedBox(width: 20,),
                      Column(
                        children: <Widget>[
                          SvgPicture.asset("images/angry.svg",color: postIcons,),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text("20",style: TextStyle(
                              fontFamily: "Lato",
                              fontSize:10,
                              color: postDesc,
                            ),),
                          )
                        ],
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
