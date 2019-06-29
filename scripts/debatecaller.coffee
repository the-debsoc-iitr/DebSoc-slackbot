# Description:
#   DebSoc Handler
#
#   Remember to always make a team first
#
# Dependencies:
#   Firebase
#
# Configuration:
#   None
#
# Commands:
#   ship it - Display a motivation squirrel
#
# Author:
#   AyanChoudhary
#

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
        database.ref().update({"debate":{Format: "", Motion: "", Names:""}})
        msg.reply "Yes sir " + name + ", right away!"

    robot.respond /i am in/i, (msg) ->
        name = msg.message.user.name
        ref = database.ref('/debate/Names')
        ref.update({"#{name}":{Role:"", Score:"0", Count:"0"}})
        msg.reply "Hi " + name + ", welcome to the debate"

    robot.respond /i am out/i, (msg) ->
        name = msg.message.user.name
        ref = database.ref("/debate/Names/#{name}")
        ref.remove()
        msg.reply "Ok! Sorry to see you go"

    robot.respond /cancel the debate/i, (msg) ->
        ref = database.ref()
        ref.update({"debate": "null"})
        msg.reply "Now that's a waste of time"

    robot.respond /set the debate/i, (msg) ->
        ref = database.ref("/debate/Names")
        ref.once("value", (snapshot) -> 
            names = snapshot.val()
            length = snapshot.numChildren()
            if length < 7 
                msg.reply "Not enough people! Cancel the debate"
            else if length > 7 and length < 9
                ref = database.ref("/debate")
                ref.update({Format: "AP"})
            else if length > 9 and length < 16
                ref = database.ref("/debate")
                ref.update({Format: "BP"}))

    robot.respond /set motion (.+) (.+)/i, (msg) ->
        number = msg.match[1]
        motion = msg.match[2]
        ref = database.ref("/debate/Motion")
        ref.update({"Motion#{number}": "#{motion}"})

    robot.respond /show motions/i, (msg) -> 
        ref = database.ref("/debate/Motion")
        ref.once("value", (snapshot) ->
            snap = snapshot.val()
            msg.reply "Motion1: #{snap.Motion1}"
            msg.reply "Motion2: #{snap.Motion2}"
            msg.reply "Motion3: #{snap.Motion3}")

    robot.respond /score (.+) (.+)/i, (msg) ->
        name = msg.match[1]
        score = msg.match[2]
        ref = database.ref("/debate/Names/#{name}")
        ref.once("value", (snapshot) ->
            if score <= 10
                ref.update({Role:"Adjudicator"})
                snap = snapshot.val()
                count = parseInt(snap.Count,10)
                prevMark = parseFloat(snap.Score,10)
                setcount = count+1
                currMark = parseInt(score,10)
                mark = (prevMark*count+currMark)/setcount
                ref.update({Score: "#{mark}"})
                ref.update({Count: "#{setcount}"})
            else
                ref.update({Role:"Speaker"})
                snap = snapshot.val()
                count = parseInt(snap.Count,10)
                prevMark = parseFloat(snap.Score,10)
                setcount = count+1
                currMark = parseInt(score,10)
                mark = (prevMark*count+currMark)/setcount
                ref.update({Score: "#{mark}"})
                ref.update({Count: "#{setcount}"}))


    robot.respond /add (.+) to debsoc/i, (msg) ->
        name = msg.match[1]
        ref = database.ref("/Members")
        ref.update({"#{name}":{Attendance: "0", Speaker: "0", Adjudicator: "0"}})
        msg.reply "Added " + name + " to DebSoc"