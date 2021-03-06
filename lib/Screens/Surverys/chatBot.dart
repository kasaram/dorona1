import 'dart:convert';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatBot extends StatefulWidget {
  @override
  _ChatBotState createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  List<String> _data = [];
  static const String BOT_URL = "https://pradarsh.herokuapp.com/bot"; // replace with server address
  TextEditingController _queryController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("DORONA - Corona helpdesk"),
      ),
      body: Stack(
        children: <Widget>[
          AnimatedList(
            // key to call remove and insert from anywhere
              key: _listKey,
              initialItemCount: _data.length,
              itemBuilder: (BuildContext context, int index, Animation animation){
                return _buildItem(_data[index], animation, index);
              }
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.message, color: Colors.greenAccent,),
                hintText: "Query",
              ),
              controller: _queryController,
              textInputAction: TextInputAction.send,
              onSubmitted: (msg){
                this._getResponse();
              },
            ),
          )
        ],
      )
      ,
    );
  }
  http.Client _getClient(){
    return http.Client();
  }
  void _getResponse(){
    if (_queryController.text.length>0) {
      this._insertSingleItem(_queryController.text);
      var client = _getClient();
      if (_queryController.text.contains(
          new RegExp(r'survey', caseSensitive: false))) {
        try {
          client.post(BOT_URL, body: {"query": _queryController.text},)
            ..then((response) {
              Map<String, dynamic> data = json.decode(response.body);
              _insertSingleItem(data['response'] + "<bot>");

              //_insertSingleItem(response.body);
            });
        } catch (e) {
          print("Failed -> $e");
        } finally {
          client.close();
          _queryController.clear();
        }
        var c=0;
        while(c<4){
          try {
            client.post(BOT_URL, body: {"query": _queryController.text},)
              ..then((response) {
                Map<String, dynamic> data = json.decode(response.body);
                _insertSingleItem(data['response'] + "<bot>");

                //_insertSingleItem(response.body);
              });
          } catch (e) {
            print("Failed -> $e");
          } finally {
            client.close();
            _queryController.clear();
          }
        }
      }
      else{
        try {
          client.post(BOT_URL, body: {"query": _queryController.text},)
            ..then((response) {
              Map<String, dynamic> data = json.decode(response.body);
              _insertSingleItem(data['response'] + "<bot>");

              //_insertSingleItem(response.body);
            });
        } catch (e) {
          print("Failed -> $e");
        } finally {
          client.close();
          _queryController.clear();
        }
    }
    }
  }

  
  
  void _insertSingleItem(String message){
    _data.add(message);
    _listKey.currentState.insertItem(_data.length-1);
  }
  Widget _buildItem(String item, Animation animation,int index){
    bool mine = item.endsWith("<bot>");
    return SizeTransition(
        sizeFactor: animation,
        child: Padding(padding: EdgeInsets.only(top: 10),
          child: Container(
              alignment: mine ?  Alignment.topLeft : Alignment.topRight,
              child : Bubble(
                child: Text(item.replaceAll("<bot>", "")),
                color: mine ? Colors.blue : Colors.indigo,
                padding: BubbleEdges.all(10),
              )),
        )
    );
  }
}