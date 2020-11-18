import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:woolala_app/screens/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditProfilePage extends StatefulWidget{
  final String currentOnlineUserId;
  EditProfilePage({
    this.currentOnlineUserId
});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>{
  TextEditingController profileNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  bool _profileNameValid = true;
  bool _bioValid = true;
  final picker = ImagePicker();
  File _image;
  PickedFile pickedFile;
  String img64;

  void initState(){
    super.initState();
    displayUserInfo();
  }

  displayUserInfo() async{
    setState(() {
      loading = true;

    });
    //access the user's info from the database and set the default text to be the current text
    profileNameController.text = currentUser.profileName;
    bioController.text = currentUser.bio;

    setState(() {
      loading = false;
    });
  }

  updateUserInfo()
  {
    setState(() {
      profileNameController.text.trim().length < 2 || profileNameController.text.isEmpty ? _profileNameValid = false : _profileNameValid = true;
      bioController.text.trim().length > 140 ? _bioValid = false : _bioValid = true;

    });
    if(_bioValid && _profileNameValid)
    {
      print("update user info on server");
      currentUser.setUserBio(bioController.text.trim());
      currentUser.setProfileName(profileNameController.text.trim());
      SnackBar successSB = SnackBar(content: Text("Profile Updated Successfully"),);
      _scaffoldGlobalKey.currentState.showSnackBar(successSB);
    }
    else{
      SnackBar failedSB = SnackBar(content: Text("Profile Failed to Update"),);
      _scaffoldGlobalKey.currentState.showSnackBar(failedSB);
    }

  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      key: _scaffoldGlobalKey,
      appBar: AppBar(
        leading: BackButton(
            color: Colors.white,
            onPressed: () => {Navigator.pushReplacementNamed(context, '/profile')},
        ),
        iconTheme: IconThemeData(color: Colors.blue),
        title: Text('Edit Profile', style: TextStyle(color: Colors.white),),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done, color: Colors.white, size: 30.0,),
            onPressed: () => {
              updateUserInfo(),
              },
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 16.0, bottom: 7.0),
                  child: Column(
                    children: <Widget> [
                      GestureDetector(
                        onTap: () => {print("Change profile Pic")},//pickImage(), setState((){})},
                        child: currentUser.createProfileAvatar(),
                      )
                    ]
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      createProfileNameTextFormField(),
                      createBioTextFormField(),
                      createPrivacySwitch(),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      )
    );
  }

  Row createPrivacySwitch(){
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
    Padding(
        padding: EdgeInsets.only(top: 15.0),
        child: Text(
          "Private Account",
          style: TextStyle(color: Colors.black, fontSize: 16.0),
        ),
        ),
      Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: Switch(
            value: currentUser.private,
            onChanged: (value){
              setState(() {
                currentUser.setPrivacy(value);
              });
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
            ),
        ),
      ],
    );
  }

  Column createProfileNameTextFormField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Profile Name",
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.black),
          controller: profileNameController,
          decoration: InputDecoration(
            hintText: "Write your profile name here",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            hintStyle: TextStyle(color: Colors.grey),
            errorText: _profileNameValid ? null : "Profile Name is insufficient",
          ),
        )

      ],
    );
  }

  Column createBioTextFormField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.black),
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Enter your bio here",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            hintStyle: TextStyle(color: Colors.grey),
            errorText: _bioValid ? null : "Bio is too long",
          ),
        )

      ],
    );
  }

    createProfilePicturePicker(){
      return FutureBuilder(
        future: changeProfilePic(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              if (snapshot.hasError)
                print('Error: ${snapshot.error}');
              else
                print('Result: ${snapshot.data}');
              }
          return currentUser.createProfileAvatar();
          }
        );
    }

  changeProfilePic() async{
  print("Picture Changing...");
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      final bytes = _image.readAsBytesSync();
      img64 = base64Encode(bytes);
    } else {
      img64 = "default";
    }
    await currentUser.setProfilePic(img64);
    print("Picture");
  }

  Future pickImage() async {
    pickedFile = await picker.getImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      final bytes = _image.readAsBytesSync();
      img64 = base64Encode(bytes);
    } else {
      img64 = "default";
    }
    //print(img64);
    http.Response res = await currentUser.setProfilePic(img64);
    Navigator.pushReplacementNamed(context, '/editProfile');
  }



}