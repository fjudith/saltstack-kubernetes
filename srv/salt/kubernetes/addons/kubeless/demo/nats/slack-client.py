# This script requires the following environment variables
# SLACK_TOKEN: Slack API Bot token
# SLACK_CHANNEL: Slack channel name without the '#'
import slack
import os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-t', '--slack-token', help="Slack API token", default=os.environ.get('SLACK_TOKEN', None))
parser.add_argument('-c', '--slack-channel', help="Slack channel name", default=os.environ.get('SLACK_CHANNEL', None))
parser.add_argument('-m', '--slack-message', help="Message", default='Hello world')
args = parser.parse_args()


def message(token, channel, message):
    if None in (token, channel):
        msg = 'Please specify a slack token and slack channel'
        print(msg)
        return msg
    else:
        client = slack.WebClient(token, timeout=30)
        # client.api_call('chat.postMessage', json={
        #     'channel': channel,
        #     'text': message,
        #     'username': 'Bot',
        #     'icon_emoji': ':robot_face:'
        #     }
        # )

        client.chat_postMessage(
            channel=channel, 
            text=message,
            username='Bot',
            icon_emoji=':robot_face:'
        )

if __name__ == "__main__":
    message(args.slack_token,args.slack_channel, args.slack_message)