import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // To format date and time
import 'package:shared_preferences/shared_preferences.dart'; // For local storage

class Todoscreen extends StatefulWidget {
  const Todoscreen({super.key});

  @override
  _TodoscreenState createState() => _TodoscreenState();
}

class _TodoscreenState extends State<Todoscreen> {
  List<String> _itemList = []; // The list of items
  final TextEditingController _textController = TextEditingController(); // Text controller for the input

  @override
  void initState() {
    super.initState();
    readNoDoList(); // Load the list when the app starts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          Flexible(
            child: ReorderableListView(
              padding: const EdgeInsets.all(8.0),
              onReorder: _onReorder, // Handle reordering
              children: _itemList
                  .asMap()
                  .map((index, item) => MapEntry(
                index,
                Card(
                  key: Key('$item-$index'), // Ensure unique key for each item
                  color: Colors.white10,
                  child: ListTile(
                    title: Text(
                      item,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Listener(
                      key: Key(item),
                      child: const Icon(
                        Icons.remove_circle,
                        color: Colors.redAccent,
                      ),
                      onPointerDown: (event) => _removeItem(index), // Remove item on tap
                    ),
                    onTap: () => _showEditDialog(index), // Edit item on tap
                  ),
                ),
              ))
                  .values
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add item',
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _showFormDialog,
      ),
    );
  }

  // Function to handle reordering of items
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _itemList.removeAt(oldIndex); // Remove the item from the old position
      _itemList.insert(newIndex, item); // Insert the item at the new position
    });
    saveNoDoList(); // Save the updated list
  }

  // Show the Add Item Dialog
  void _showFormDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Item',
                    icon: Icon(Icons.note_add),
                    hintText: "Enter your item",
                  ),
                ),
              ),
            ],
          ),
          actions: [
            // Save Button
            TextButton(
              onPressed: () {
                _addItem(); // Save the item
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Save'),
            ),
            // Cancel Button
            TextButton(
              onPressed: () {
                _textController.clear(); // Clear the text field
                Navigator.pop(context); // Just close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Show the Edit Item Dialog
  void _showEditDialog(int index) {
    _textController.text = _itemList[index].split(" - ")[0]; // Extract the item text (before the timestamp)

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Edit Item',
                    icon: Icon(Icons.edit),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            // Save Button
            TextButton(
              onPressed: () {
                _editItem(index); // Save the edited item
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Save'),
            ),
            // Cancel Button
            TextButton(
              onPressed: () {
                _textController.clear(); // Clear the text field
                Navigator.pop(context); // Close the dialog without saving
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to add a new item with the current date and time
  void _addItem() {
    if (_textController.text.isNotEmpty) {
      String formattedDateTime = _getCurrentDateTime(); // Get current date and time
      setState(() {
        _itemList.add('${_textController.text} - $formattedDateTime'); // Append the item with the current date and time
      });
      _textController.clear();
      saveNoDoList(); // Save the updated list
    }
  }

  // Function to edit an existing item
  void _editItem(int index) {
    if (_textController.text.isNotEmpty) {
      String formattedDateTime = _getCurrentDateTime(); // Get current date and time
      setState(() {
        _itemList[index] = '${_textController.text} - $formattedDateTime'; // Update the item with the new text and current date/time
      });
      _textController.clear();
      saveNoDoList(); // Save the updated list
    }
  }

  // Function to remove an item
  void _removeItem(int index) {
    setState(() {
      _itemList.removeAt(index);
    });
    saveNoDoList(); // Save the updated list
  }

  // Function to get the current date and time in a specific format
  String _getCurrentDateTime() {
    DateTime now = DateTime.now();
    return DateFormat('yyyy-MM-dd – kk:mm').format(now); // Format the date and time
  }

  // Function to save the list of items using SharedPreferences
  void saveNoDoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('todoList', _itemList); // Save the item list
  }

  // Function to load the saved list of items
  void readNoDoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedList = prefs.getStringList('todoList');
    if (savedList != null) {
      setState(() {
        _itemList = savedList; // Load the saved list
      });
    }
  }
}
