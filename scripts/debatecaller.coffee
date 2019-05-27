#This bot is for calling debates

#This bot will schedule debates and assign teams
#This bot can also be called for cancelling the debate

module.exports = (robot) ->
    robot.respond /call the debate/i, (msg) ->
        name = msg.message.user.name
        msg.reply "Yes sir " + name + ", right away!"

    robot.respond /cancel the debate/i, (msg) ->
        name = msg.message.user.name
        msg.reply "Very sorry to inform you that the debate has been called off"