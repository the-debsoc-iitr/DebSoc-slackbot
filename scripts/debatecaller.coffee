#This bot is for calling debates

#This bot will schedule debates and assign teams
#This bot can also be called for cancelling the debate

module.exports = (robot) ->
    robot.respond /call the debate/i, (msg) ->
        name = msg.message.user.name
        msg.reply "Yes sir " + name + ", right away!"
        names = robot.brain.get('name')
        setTimeout ->
            if names != null
                msg.reply 'So here we have ' + names + ' for debate'
            else
                msg.reply 'Are you kidding, there is no one for a debate'
        , 5000

    robot.respond /cancel the debate/i, (msg) ->
        name = msg.message.user.name
        msg.reply "Very sorry to inform you that the debate has been called off"

    robot.respond /i am in/i, (msg) ->
        name = msg.message.user.name
        robot.brain.set('name', name)
        msg.reply "Hi " + name + ", welcome to the debate"

    robot.respond /i am out/i, (msg) ->
        name = msg.message.user.name
        msg.reply "Ok! Sorry to see you go"