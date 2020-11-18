import 'package:flutter/material.dart';
import 'package:woolala_app/screens/homepage_screen.dart';
import 'package:woolala_app/main.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:woolala_app/models/user.dart';
import 'package:woolala_app/screens/follower_list_screen.dart';
import 'package:woolala_app/screens/following_list_screen.dart';
import 'package:woolala_app/screens/search_screen.dart';
import 'package:woolala_app/widgets/bottom_nav.dart';
//import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget{
  //the id of this profile
  final String userProfileEmail;
  ProfilePage(this.userProfileEmail);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //the account we are currently logged into
  final String currentOnlineUserEmail = currentUser.email;
  User profilePageOwner;
  bool checker = false;

  createProfileTop() {
    return FutureBuilder(
      future: getDoesUserExists(widget.userProfileEmail),
      builder: (context, dataSnapshot) {
        switch (dataSnapshot.connectionState) {
          case ConnectionState.waiting: return CircularProgressIndicator();
          default:
            if (dataSnapshot.hasError)
              return Text('Error: ${dataSnapshot.error}');
            else
              print('Result: ${dataSnapshot.data}');
        }
        profilePageOwner = dataSnapshot.data;
        return Padding(
            padding: EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  profilePageOwner.createProfileAvatar(),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      profilePageOwner.profileName, style: TextStyle(fontSize: 32.0, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 1.0),
                    child: Text(
                      profilePageOwner.userName, style: TextStyle(fontSize: 16.0, color: Colors.black38),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 3.0),
                    child: Text(
                      profilePageOwner.bio, style: TextStyle(fontSize: 20.0, color: Colors.black54, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  createIntColumns("Posts", profilePageOwner.postIDs.length),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => FollowerListScreen(widget.userProfileEmail)));
                                    },
                                    child: createIntColumns("Followers", profilePageOwner.followers.length ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => FollowingListScreen(widget.userProfileEmail)));
                                    },
                                    child: createIntColumns("Following", profilePageOwner.following.length -1 ),
                                  ),
                                  createAveragesColumn("Avg."),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: FutureBuilder(
                                    future: checkIfFollowing(),
                                    builder: (context, snapshot){
                                      return createButton();
                                    },
                                  ),
                                ),
                                //createButton(),
                              ],
                            ),
                          ],
                        ),
                      ),
                     ],
                  ),
                ],
            ),
        );
      },
    );
  }

  Column createIntColumns(String title, int count){
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          getFormattedText(count.toString()),
          style: TextStyle(fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 3.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
  String getFormattedText(String number)
  {
    if(number.length < 4)
      {//text < 1000
        return number;
      }
    else if(number.length < 7)
      {//text < 1,000,000
        return number[0] + "." + number[1] + " K";
      }
    else if(number.length < 10)
      {//text < 1,000,000,000
        return number[0] + "." + number[1] + " M";
      }
    else{
      // text > 1 billion
      return number[0] + "." + number[1] + " B";
    }

  }
    createAveragesColumn(String title) {
      return FutureBuilder(
        future: profilePageOwner.getAvgScore(),
        builder: (context, snapshot){

          switch (snapshot.connectionState) {
            case ConnectionState.waiting: return CircularProgressIndicator();
            default:
              if (snapshot.hasError)
                print('Error: ${snapshot.error}');
              else
                print('Result: ${snapshot.data}');
          }

          double avg = snapshot.data;
          return createDoubleColumns(title, avg);
        }
      );
    }

  Column createDoubleColumns(String title, double count) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toStringAsFixed(2),
          style: TextStyle(fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 3.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

 checkIfFollowing() async{
    User currentUser = await getDoesUserExists(currentOnlineUserEmail);
    User viewingUser = await getDoesUserExists(widget.userProfileEmail);
    for(int i = 0; i < currentUser.following.length; i++) {
      if(currentUser.following[i] == viewingUser.userID){
        print("true!");
        checker = true;
      }
    }
   }

  createButton() {
    bool ownProfile = currentOnlineUserEmail == widget.userProfileEmail;
    if(ownProfile)
    {
      return createButtonTitleAndFunction(title: 'Edit Profile', performFunction: editUserProfile, color: Colors.white);
    }
    else if(checker){
      Color followingColor = Colors.white;
      return createButtonTitleAndFunction(title: 'Following',color: followingColor);
    }
    else{
      return createButtonTitleAndFunction(title: 'Follow',color: Colors.blue);
    }
  }

  Container createButtonTitleAndFunction({String title, Function performFunction, Color color}){
  return Container(
    padding: EdgeInsets.only(top: 3.0),
    child: FlatButton(
      onPressed: performFunction,
      key: ValueKey(title),
      child: Container(
        width: 280.0,
        height: 35.0,
        child: Text(title, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black, width: 2.0),
            borderRadius: BorderRadius.circular(6.0),
        ),
      ),
    ),
  );
  }

  editUserProfile() {
    Navigator.pushReplacementNamed(context, '/editProfile');
  }

  @override
  Widget build(BuildContext context) {
    BottomNav bottomBar = BottomNav(context);
    bottomBar.currentIndex = 2;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton (
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), //place holder
          color: Colors.white,
        ),
        title: Text('WooLaLa', style: TextStyle(fontSize: 25, fontFamily: 'Lucida'), textAlign: TextAlign.center,),
        key: ValueKey("homepage"),
        actions: <Widget>[
          IconButton (
            icon: Icon(Icons.search),
            color: Colors.white,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage())),
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => {},//callFromHomePage(context),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          createProfileTop(),
        ],

      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          bottomBar.switchPage(index, context);
        },
        items: bottomBar.bottom_items,
        backgroundColor: Colors.blueGrey[400],
      ),
    );
  }
}