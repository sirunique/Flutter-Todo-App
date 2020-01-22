import 'package:flutter/material.dart';
import 'package:todo/models/todo_item.dart';
import 'package:todo/utils/database.dart';
import 'package:todo/utils/date_formatter.dart';

class ToDoScreen extends StatefulWidget{
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen>{
  var db = DatabaseHelper();

  final List<ToDoItem> _itemList = <ToDoItem>[];
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState(){
    super.initState();
    _readToDoList();
  }

  _readToDoList() async{
    List items = await db.getItems();
    items.forEach((item){
      ToDoItem toDoItem = ToDoItem.fromMap(item);
      print("To Do Items: {$toDoItem.itemName}");
      setState(() {
          _itemList.add(ToDoItem.map(item));
      });
    });
  }

  _deleteToDo(int id, int index) async{
    await db.deleteItem(id);
    setState(() {
     _itemList.removeAt(index); 
    });
  }

  _updateItem(ToDoItem item, int index) async{
    var alert = new AlertDialog(
      title: Text('Update Item'),
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              autofocus: true,
              controller: _textEditingController,
              decoration: InputDecoration(
                labelText: 'Item',
                hintText: _itemList[index].itemName,
                icon: Icon(Icons.update),
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () async{
            ToDoItem newItemUpdated = ToDoItem.fromMap({
              'itemName' : _textEditingController.text,
              'dateCreated' : dateFormatted(),
              'id' : item.id
            });
            _handleSubmittedUpdate(index, item);
            await db.updateItem(newItemUpdated);
            setState(() {
             _readToDoList(); 
            });
            Navigator.pop(context);
          },
          child: Text('Update'),
        ),
        FlatButton(
          onPressed: ()=> Navigator.pop(context),
          child: Text('Cancle'),
        )
      ],
    );
    showDialog(
      context: context,
      builder: (_){
        return alert;
      }
    );
  }

  void _handleSubmitted(String text) async{
    _textEditingController.clear();
    // ToDoItem toDoItem = ToDoItem(text, DateTime.now().toIso8601String());
    ToDoItem toDoItem = ToDoItem(text, dateFormatted());
    int savedItemId = await db.saveItem(toDoItem);
    print("Iteam Saved : $savedItemId");
    ToDoItem addedItem = await db.getItem(savedItemId);
    setState(() {
        _itemList.insert(0, addedItem); 
    });
  }

  void _handleSubmittedUpdate(int index, ToDoItem item){
    setState(() {
     _itemList.removeWhere((element){
       _itemList[index].itemName == item.itemName;
     });
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: false,
              itemCount: _itemList.length,
              itemBuilder:(_, int index){
                return Card(
                  color:Colors.white10,
                  child: ListTile(
                    title: _itemList[index],
                    onLongPress: ()=> 
                      _updateItem(_itemList[index], index),
                    trailing: Listener(
                      key: Key(_itemList[index].itemName),
                      child: Icon(Icons.remove_circle, 
                      color:Colors.redAccent,),
                      onPointerDown: (pointerEvent) =>
                        _deleteToDo(_itemList[index].id, index),
                  ),

                )
                );
              }
            )
          ),
          Divider(
            height: 1.0,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Item',
        backgroundColor: Colors.redAccent,
        child: ListTile(
          title: Icon(Icons.add),
        ),
        onPressed: _showFormDialog,
      ),
    );
  }

  void _showFormDialog(){
    var alert = AlertDialog(
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              autofocus: true,
              controller: _textEditingController,
              decoration: InputDecoration(
                labelText:"Item",
                hintText: "eg. Don't Buy Stuff",
                icon: Icon(Icons.note_add),
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed:(){
             _handleSubmitted(_textEditingController.text);
             _textEditingController.clear();
             Navigator.pop(context);
          },
          child: Text('Save'),
        ),
        FlatButton(
          onPressed: ()=> Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
    );

    showDialog(context: context, builder:(_){
        return alert;
    });
  }

  

}
