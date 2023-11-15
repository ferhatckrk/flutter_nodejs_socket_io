import 'package:flutter/material.dart';
import 'package:flutter_socket_io/data/data.dart';
import 'package:flutter_socket_io/model/message.dart';
import 'package:flutter_socket_io/providers/home.dart';
import 'package:flutter_socket_io/socket/socket_client.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late IO.Socket _socket;
  final TextEditingController _messageInputController = TextEditingController();
  bool isWriting = false;
  _sendMessage() {
    _socket.emit('message-${Data.roomID}', {
      'message': _messageInputController.text.trim(),
      'sender': Data.userName
    });
    _messageInputController.clear();
  }

  _firstOpen() {
    _socket.emit("firstLogin-${Data.roomID}", {"name": "Ferhat  Çıkrık"});
  }

  _connectSocket() {
    _socket.onConnect((data) => print('Connection established'));
    _socket.onConnectError((data) => print('Connect Error: $data'));
    _socket.onDisconnect((data) => print('Socket.IO server disconnected'));
    _socket.on(
      'message-${Data.roomID}',
      (data) => Provider.of<HomeProvider>(context, listen: false).addNewMessage(
        Message.fromJson(data),
      ),
    );
    _socket.on('firstLogin-${Data.roomID}', (data) {
      print(data);
    });
    _socket.on('writing-${Data.roomID}', (data) {
      var name = data["name"];
      bool value = data["value"];
      setState(() {
        if (name != Data.userName) {
          isWriting = value;
        }
      });
    });
  }

  _writingEvent(bool value) {
    _socket.emit("writing-${Data.roomID}", {"name": Data.userName, "value": value});
  }

  @override
  void initState() {
    super.initState();
    //Important: If your server is running on localhost and you are testing your app on Android then replace http://localhost:3000 with http://10.0.2.2:3000
    _socket = SocketClient.instance.socket!;
    _connectSocket();
    _firstOpen();
  }

  @override
  void dispose() {
    _messageInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("object");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Socket.IO'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<HomeProvider>(
              builder: (_, provider, __) => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final message = provider.messages[index];
                  return Wrap(
                    alignment: message.senderUsername == Data.userName
                        ? WrapAlignment.end
                        : WrapAlignment.start,
                    children: [
                      Card(
                        color: message.senderUsername == Data.userName
                            ? Theme.of(context).primaryColorLight
                            : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                message.senderUsername == Data.userName
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                            children: [
                              Text(message.message),
                              Text(
                                DateFormat('hh:mm a').format(message.sentAt),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                },
                separatorBuilder: (_, index) => const SizedBox(
                  height: 5,
                ),
                itemCount: provider.messages.length,
              ),
            ),
          ),
          if (isWriting)
            const Align(
              alignment: Alignment.bottomLeft,
              child: Icon(
                Icons.more_horiz,
                color: Colors.amber,
                size: 50,
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageInputController,
                      onChanged: (value) async {
                        _writingEvent(true);
                        await Future.delayed(const Duration(seconds: 2));
                        _writingEvent(false);
                      },
                      onEditingComplete: () {
                        print("onEditingComplete");

                        _writingEvent(false);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Type your message here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_messageInputController.text.trim().isNotEmpty) {
                        _sendMessage();
                      }
                    },
                    icon: const Icon(Icons.send),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
