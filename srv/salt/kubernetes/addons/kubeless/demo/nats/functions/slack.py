#!/usr/bin/env python
import slack
import os
import json
import jsonpickle


# map some colors to pod event types
color = { 'DELETED': '#ff0000', 'MODIFIED': 'f0ff00', 'ADDED': '56ff00' }


def slack_message(event, context):
    try:
        slack_token = os.environ.get('SLACK_TOKEN', None)
        slack_channel = os.environ.get('SLACK_CHANNEL', None)
        if None in (slack_token, slack_channel):
            msg = 'Please specify a slack token and slack channel'
            print(msg)
            return msg
        else:
            client = slack.WebClient(slack_token, timeout=30)
            client.chat_postMessage(
                channel=slack_channel,
                attachments=[ 
                    { 
                        "title": event['data']['type']+" Pod event", 
                        "color": color[event['data']['type']], 
                        "fields": [
                            {
                                "title": "Name",
                                "value": event['data']['object']['metadata']['name']
                            },
                            {
                                "title": "Namespace",
                                "value": event['data']['object']['metadata']['namespace']
                            },
                            {
                                "title": "Node",
                                "value": event['data']['object']['spec']['nodeName']
                            },
                        ]
                    } 
                ] 
            )

            print(jsonpickle.encode(event))

    except Exception as inst:
        print(type(inst))
        print(inst)
        print(event.keys())
        print(type(event))
        print(str(event))