# Description:
#   DebSoc Handler
#
# Note:
#   Remember to always make a team first
#
# Dependencies:
#   Firebase
#
# Configuration:
#   None
#
# Commands:
#   call the debate - initialize a new debate
#   i am in - add user to debate roster
#   i am out - remove user from debate roster
#   cancel the debate - remove the debate instance
#   set the debate - forms teams, decides adjes and sets up the debate format
#   set motion(x) abc def - registers motion no. x with title as abc and context as def
#   show motions - shows the list of motions
#   score user points - updates user role,adds points to the user in the debate as well as updates total tally
#   add xyz to debsoc - adds xyz to the member team
#   archive the debate date - saves a copy of the debate in the database
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
        authDomain: "debate-database.firebaseapp.com",
        databaseURL: "https://debate-database.firebaseio.com",
        storageBucket: "bucket.appspot.com"
    };
    firebase.initializeApp(config);
    database = firebase.database();

    robot.respond /call the debate/i, (msg) ->
        date = msg.match[1]
        name = msg.message.user.name
        database.ref().update({"debate":{Format: "", Motion: "", Names:"", Teams:""}})
        msg.send "Yes sir " + name + ", right away!"
        msg.send "@channel The debate has been called"

    robot.respond /i am in/i, (msg) ->
        name = msg.message.user.name
        ref = database.ref('/debate/Names')
        ref.update({"#{name}":{Role:"", Score:"0", Count:"0"}})
        msg.send "Hi " + name + ", welcome to the debate"

    robot.respond /i am out/i, (msg) ->
        name = msg.message.user.name
        ref = database.ref("/debate/Names/#{name}")
        ref.remove()
        msg.send "Ok! Sorry to see you go"

    robot.respond /cancel the debate/i, (msg) ->
        ref = database.ref()
        ref.update({"debate": null})
        msg.send "Now that's a waste of time"

    robot.respond /set the debate/i, (msg) ->
        shuffle = (source) ->
            return source unless source.length >= 2
            for index in [source.length-1..1]
                randomIndex = Math.floor Math.random() * (index + 1)
                [source[index], source[randomIndex]] = [source[randomIndex], source[index]]
            source
        ref = database.ref("/debate/Names")
        ref.once("value", (snapshot) -> 
            names = snapshot.val()
            length = snapshot.numChildren()
            if length < 7 
                msg.send "Not enough people! Cancel the debate"
            else if length >= 7 and length < 9
                ref = database.ref("/debate")
                ref.update({Format: "AP"})
                Names = []
                snapshot.forEach((data) ->
                    Names.push(data.key)
                    robot.logger.debug(snapshot.keys))
                Order = shuffle Names
                slice = length%6
                chair = Order[-1..]
                adjes = Order[-slice...-1]
                team1 = Order[0...3]
                team2 = Order[3...6]
                refer = database.ref("/debate/Teams")
                refer.update(Team1:"#{team1}")
                refer.update(Team2:"#{team2}")
                msg.send "The chair is #{chair}"
                msg.send "The adjes are #{adjes}"
                msg.send "Team 1 is : #{team1}"
                msg.send "Team 2 is : #{team2}"
            else if length >= 9 and length < 16
                ref = database.ref("/debate")
                ref.update({Format: "BP"})
                Names = []
                snapshot.forEach((data) ->
                    Names.push(data.key)
                    robot.logger.debug(snapshot.keys))
                Order = shuffle Names
                slice = length%8
                chair = Order[-1..]
                adjes = Order[-slice...-1]
                team1 = Order[0...2]
                team2 = Order[2...4]
                team3 = Order[4...6]
                team4 = Order[6...8]
                refer = database.ref("/debate/Teams")
                refer.update(Team1:"#{team1}")
                refer.update(Team2:"#{team2}")
                refer.update(Team3:"#{team3}")
                refer.update(Team4:"#{team4}")
                msg.send "The chair is #{chair}"
                msg.send "The adjes are #{adjes}"
                msg.send "Team 1 is : #{team1}"
                msg.send "Team 2 is : #{team2}"
                msg.send "Team 3 is : #{team3}"
                msg.send "Team 4 is : #{team4}")

    robot.respond /set motion(.+) (.+) (.+)/i, (msg) ->
        number = msg.match[1]
        motion = msg.match[2]
        context = msg.match[3]
        ref = database.ref("/debate/Motion")
        ref.update({"Motion#{number}": {Title:"#{motion}", Context:"#{context}"}})

    robot.respond /show motions/i, (msg) -> 
        ref = database.ref("/debate/Motion")
        ref.once("value", (snapshot) ->
            snap = snapshot.val()
            length = snapshot.numChildren()
            snapshot.forEach((data) ->
                msg.send ""
                msg.send "#{data.key}: #{data.val().Title}"
                if data.val().Context != "-"
                    msg.send "Context: #{data.val().Context}"))

    robot.respond /show people/i, (msg) ->
        ref = database.ref "/debate/Names"
        ref.once "value", (snapshot) ->
            snapshot.forEach((data) ->
                msg.send "#{data.key}")

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

    robot.respond /archive the debate (.+)/i, (msg) ->
        date = msg.match[1]
        ref = database.ref("/debate")
        ref.once("value", (snapshot) -> 
            debate = snapshot.val()
            ref.update({"Debate#{date}":{Format:"#{debate.Format}", Motion:"", Team:"", Names:""}}))
        refer = database.ref("/Debate#{date}")
        ref = database.ref("/debate/Names")
        ref.once("value", (snapshot) ->
            snapshot.forEach((data) ->
                refer.child("/Names").update({"#{data.key}":{Role:"#{data.val().Role}", Score:"#{data.val().Score}"}})))
        ref = database.ref("/debate/Motions")
        ref.once("value", (snapshot) ->
            snapshot.forEach((data) ->
                refer.child("/Motions").update({"#{data.key}":{Title:"#{data.val().Title}", Context:"#{data.val().Context}"}})))
        ref = database.ref("/debate/Teams")
        ref.once("value", (snapshot) -> 
            snapshot.forEach((data) ->
                refer.child("/Teams").update({"#{data.key}":"#{data.val()}"})))
        msg.send "Debate archived for #{date}"

    robot.respond /add (.+) to debsoc/i, (msg) ->
        name = msg.match[1]
        ref = database.ref("/Members")
        ref.update({"#{name}":{Attendance: "0", Speaker: "0", Adjudicator: "0"}})
        msg.send "Added " + name + " to DebSoc"