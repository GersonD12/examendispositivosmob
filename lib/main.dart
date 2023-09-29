import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
//Instrucciones, para editar una tarea, toque la tarea, para borrar deslize a la izquierda y precione eliminar,para crear una tarea solo debe tocar el boton de agregar 
void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoListScreen(),
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBarTheme: AppBarTheme(
          color: Colors.black,
        ),
      ),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<TodoItem> _todos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do'),
      ),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: ListTile(
                  tileColor: _todos[index].color.withOpacity(0.7),
                  title: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _todos[index].titulo,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 0, 0, 0), // Color del texto en la tarea
                              ),
                            ),
                            Text(
                              _todos[index].description,
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color.fromARGB(255, 2, 2, 2), // Color del texto en la tarea
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  trailing: Checkbox(
                    value: _todos[index].isCompleted,
                    onChanged: (value) {
                      setState(() {
                        _todos[index].isCompleted = value!;
                      });
                    },
                  ),
                  onTap: () {
                    _editTodo(index);
                  },
                ),
                secondaryActions: <Widget>[
                  IconSlideAction(
                    caption: 'Eliminar',
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: () {
                      _deleteTodo(index);
                    },
                  ),
                ],
              ),
              Divider(
                color: Colors.black,
                height: 8.0,
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: Icon(Icons.add),
      ),
    );
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  void _addTodo() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TodoDetailScreen()),
    );

    if (result != null) {
      setState(() {
        _todos.add(result);
      });
    }
  }

  void _editTodo(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoDetailScreen(todo: _todos[index]),
      ),
    );

    if (result != null) {
      setState(() {
        _todos[index] = result;
      });
    }
  }
}

class TodoDetailScreen extends StatefulWidget {
  final TodoItem? todo;

  TodoDetailScreen({this.todo});

  @override
  _TodoDetailScreenState createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late bool _isCompleted;
  Color _selectedColor = Colors.blue; // Color por defecto

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.titulo ?? '');
    _descriptionController =
        TextEditingController(text: widget.todo?.description ?? '');
    _isCompleted = widget.todo?.isCompleted ?? false;

    if (widget.todo != null) {
      _selectedColor = widget.todo!.color; // Asigna el color existente de la tarea
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.todo == null ? 'Nueva Tarea' : 'Editar Tarea',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Ingrese el título',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Ingrese la descripción',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Color',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton<Color>(
              value: _selectedColor,
              items: <Color>[
                
                Colors.blue,
                 // Color azul
                Colors.red, // Color rojo
                const Color.fromARGB(255, 21, 97, 24), // Color verde
              ].map((Color color) {
                return DropdownMenuItem<Color>(
                  value: color,
                  child: Container(
                    width: 24,
                    height: 24,
                    color: color,
                  ),
                );
              }).toList(),
              onChanged: (Color? newValue) {
                setState(() {
                  _selectedColor = newValue!;
                });
              },
            ),
            SizedBox(height: 16.0),
            SizedBox(height: 32.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _saveTodo();
                },
                child: Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTodo() {
    final title = _titleController.text;
    final description = _descriptionController.text;

    if (title.isNotEmpty) {
      final result = TodoItem(
        titulo: title,
        description: description,
        isCompleted: _isCompleted,
        color: _selectedColor, // Asigna el color seleccionado a la tarea
      );

      Navigator.pop(context, result);
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('El título no puede estar vacío.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}

class TodoItem {
  final String titulo;
  final String description;
  bool isCompleted;
  Color color; // Agrega una propiedad para el color

  TodoItem({
    required this.titulo,
    required this.description,
    this.isCompleted = false,
    this.color = Colors.blue, // Color por defecto
  });
}
