const express = require("express");
const app = express();
const http = require("http");
const server = http.createServer(app);
const { Server } = require("socket.io");
const io = new Server(server);
const messages = [];
 
const roomID =makeid(5);
console.log("roomID==>>"+roomID);
io.on("connection", (socket) => { 
  console.log("connected"); 
  const username = socket.handshake.query.username;


  socket.on("message-"+roomID, (data) => {
    const message = {
      message: data.message,
      senderUsername: username,
      sentAt: Date.now(),
    };
    messages.push(message);
    io.emit("message-"+roomID, message);
  });

  socket.on("firstLogin-"+roomID, (data) => {
    const name = data.name;
    io.emit("firstLogin-"+roomID, "Welcome to My App " + name);
    console.log(name);
  });

  socket.on("writing-"+roomID, (data) => {
    var value = data.value;
    const name = data.name;
    io.emit("writing-"+roomID, { name: name, value: value });
  });
});

function makeid(length) {
  let result = '';
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  const charactersLength = characters.length;
  let counter = 0;
  while (counter < length) {
    result += characters.charAt(Math.floor(Math.random() * charactersLength));
    counter += 1;
  }
  return result;
}

server.listen("3000", () => {
  console.log("listening on *:3000");
});
