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
        name = msg.message.user.name
        database.ref().set({'debate': 'null'})
        msg.reply "Yes sir " + name + ", right away!"
        setTimeout ->
            database.ref('/debate').on('value', (snapshot) ->   
                user = snapshot.val()
                length = snapshot.numChildren()
                if length != "null"
                    msg.reply 'So here we have ' + length + ' for debate'
                else
                    msg.reply 'Are you kidding, there is no one for a debate')
        , 10000

    robot.respond /cancel the debate/i, (msg) ->
        name = msg.message.user.name
        msg.reply "Very sorry to inform you that the debate has been called off"

    robot.respond /i am in/i, (msg) ->
        name = msg.message.user.name
        ref = database.ref('/debate')
        ref.set({name:name})
        msg.reply "Hi " + name + ", welcome to the debate"

    robot.respond /i am out/i, (msg) ->
        name = msg.message.user.name
        debate = robot.brain.get('debate')
        robot.brain.remove(debate.name)
        msg.reply "Ok! Sorry to see you go"