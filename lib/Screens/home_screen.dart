import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ourchat/Models/chat_user_model.dart';
import 'package:ourchat/Screens/profile_screen.dart';
import 'package:ourchat/Widgets/chatusercard.dart';

import '../API/api.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<ChatUserModel> _list = [];
  List<ChatUserModel> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: (){
          if(_isSearching){
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);

          }else{
            return Future.value(true);

          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: Icon(Icons.home_outlined),
            title: _isSearching ?
                TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search using Name or Email',
                  ),
                  autofocus: true,
                  style: TextStyle(fontSize: 18, letterSpacing: 0.5),
                  onChanged: (val){
                    _searchList.clear();
                    for(var i in _list){
                      if(i.name.toLowerCase().contains(val.toLowerCase()) || i.email.toLowerCase().contains(val.toLowerCase())){
                        _searchList.add(i);
                      };
                      setState(() {
                        _searchList;
                      });
                    }
                  },
        
                )
                :Text('Family Fun'),
            actions: [
              IconButton(onPressed: (){
                setState(() {
                  _isSearching =! _isSearching;
                });
              },
                  icon: Icon( _isSearching ?Icons.cancel :Icons.search_outlined)),
              IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=>ProfileScreen(user: APIs.me)));
              }, icon: Icon(Icons.more_vert))
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 16.0, right: 8.0),
            child: FloatingActionButton(
              onPressed: ()async{
        
                  await APIs.auth.signOut();
                  await GoogleSignIn().signOut();
        
        
        
              },
              child: Icon(Icons.add_box_outlined, color: Colors.black),
            ),
          ),
          body: StreamBuilder(
            stream: APIs.getAllUsers(),
            builder: (context, snapshot){
        
              switch(snapshot.connectionState){
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Center(
                      child: CircularProgressIndicator());
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                 _list = data?.map((e)=> ChatUserModel.fromJson(e.data())).toList() ?? [];
                if(_list.isNotEmpty){
                  return ListView.builder(
                      itemCount: _isSearching ? _searchList.length: _list.length,
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.only(top: mq.height*.01, bottom: mq.height*.02),
                      itemBuilder: (context, index){
                        return ChatUserCard(user: _isSearching ? _searchList[index] : _list[index]);
        
                      });
                }else{
                  return Center(child: Text("No Connection Found!", style: TextStyle(fontSize: 20),));
                }
              }
            }
          ),
        ),
      ),
    );
  }
}
