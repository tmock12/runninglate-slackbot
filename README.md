# RunninglateSlack

A bot that connects to slack and if you type "running late", "time out" or "timeout" in channels this bot is a member of, it will post that message in a seperate room. This is me playing around with Elixir

###Our workflow:

- Taylor posts in Jacksonville channel and says "hey guys I'm running late. be there in 5"
- This bot then posts into our Running Late channel:
`taylor_mock said "hey guys I'm running late. be there in 5` 

### To start bot:
`SLACK_BOT='<your slack bot token>' mix run --no-halt`
