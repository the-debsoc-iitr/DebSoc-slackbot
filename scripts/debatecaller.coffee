#This bot is for calling debates

#This bot will schedule debates and assign teams
#This bot can also be called for cancelling the debate

module.exports = (robot) ->

    firebase = require("firebase/app")
    require('firebase/auth');
    require('firebase/database');
    config = {
        apiKey: "apiKey",
        authDomain: "projectId.firebaseapp.com",
        databaseURL: "https://database-c8afc.firebaseio.com",
        storageBucket: "bucket.appspot.com"
    };
    firebase.initializeApp(config);
    database = firebase.database();

    robot.respond /call the debate/i, (msg) ->
        date = msg.match[1]
        name = msg.message.user.name
        database.ref().update({"debate": "null"})
        msg.reply "Yes sir " + name + ", right away!"

    robot.respond /i am in/i, (msg) ->
        name = msg.message.user.name
        ref = database.ref('/debate')
        ref.update({"#{name}": name})
        msg.reply "Hi " + name + ", welcome to the debate"

    robot.respond /i am out/i, (msg) ->
        name = msg.message.user.name
        ref = database.ref("/debate/#{name}")
        ref.remove()
        ref = database.ref()
        ref.update({"debate": "null"})
        msg.reply "Ok! Sorry to see you go"

    robot.respond /cancel the debate/i, (msg) ->
        ref = database.ref()
        ref.update({"debate": "null"})
        msg.reply "Now that's a waste of time"

    robot.respond /add (.+) to debsoc/i, (msg) ->
        name = msg.match[1]
        ref = database.ref("/Members")
        ref.update({"#{name}":{Attendance: "0", Speaker: "0", Adjudicator: "0"}})
        msg.reply "Added " + name + " to DebSoc"