#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import logging
import getpass
from optparse import OptionParser
import datetime, threading, time
from random import randint

import sleekxmpp

# Python versions before 3.0 do not use UTF-8 encoding
# by default. To ensure that Unicode is handled properly
# throughout SleekXMPP, we will set the default encoding
# ourselves to UTF-8.
if sys.version_info < (3, 0):
    from sleekxmpp.util.misc_ops import setdefaultencoding
    setdefaultencoding('utf8')
else:
    raw_input = input


class MUCBot(sleekxmpp.ClientXMPP):

    def __init__(self, jid, password, room, nick):
        sleekxmpp.ClientXMPP.__init__(self, jid, password)

        self.room = room
        self.nick = nick

        self.modes = ["US-DIST-CM", "US-DIST-IN"]
        self.mode = None
        self.unit = None
        self.value = None
        self.decimals = None
        self.minValue = None
        self.maxValue = None

        self.set_mode("US-DIST-CM")

        self.add_event_handler("session_start", self.start)
        self.add_event_handler("groupchat_message", self.muc_message)

    def start(self, event):
        self.get_roster()
        self.send_presence()
        self.plugin['xep_0045'].joinMUC(self.room, self.nick, wait=True)
        self.plugin['xep_0045'].configureRoom(self.room)

        timerThread = threading.Thread(target=self.loop)
        timerThread.daemon = True
        timerThread.start()

    def muc_message(self, msg):
        if msg['mucnick'] != self.nick:
            body = msg['body']
            tokens = body.split()
            cmd = tokens[0] if len(tokens) > 0 else None
            attrib = tokens[1] if len(tokens) > 1 else None
            newValue = tokens[2] if len(tokens) > 2 else None
            if cmd == "get":
                self.handle_get(msg, attrib)
            elif cmd == "set":
                self.handle_set(msg, attrib, newValue)

    def handle_get(self, msg, attrib):
        returnVal = None

        if attrib == "mode":
            returnVal = "mode " + self.mode
        elif attrib == "unit":
            returnVal = "unit " + self.unit
        elif attrib == "value":
            returnVal = "value " + str(self.value)
        elif attrib == "decimals":
            returnVal = "decimals " + str(self.decimals)

        if returnVal:
            self.send_message(mto=msg['from'].bare, mbody=returnVal, mtype='groupchat')

    def handle_set(self, msg, attrib, newValue):
        confirmMsg = None

        if attrib == "mode":
            if self.set_mode(newVal):
                confirmMsg = "mode " + self.mode

        if confirmMsg:
            self.send_message(mto=self.room, mbody=confirmMsg, mtype='groupchat')

    def loop(self):
        next_call = time.time()
        while True:
            self.value = self.gen_value()
            if self.value:
                self.send_message(mto=self.room, mbody="value %d" % self.value, mtype='groupchat')

            next_call = next_call+1;
            time.sleep(next_call - time.time())

    def set_mode(self, mode):
        if mode not in self.modes:
            return False
        self.mode = mode

        if self.mode == "US-DIST-CM":
            self.unit = "cm"
            self.decimals = 1
            self.minValue = 0
            self.maxValue = 2550
        elif self.mode == "US-DIST-IN":
            self.unit = "in"
            self.decimals = 1
            self.minValue = 0
            self.maxValue = 1003

        return True

    def gen_value(self):
        return randint(self.minValue, self.maxValue)


if __name__ == '__main__':
    # Setup the command line arguments.
    optp = OptionParser()

    # Output verbosity options.
    optp.add_option('-q', '--quiet', help='set logging to ERROR',
                    action='store_const', dest='loglevel',
                    const=logging.ERROR, default=logging.INFO)
    optp.add_option('-d', '--debug', help='set logging to DEBUG',
                    action='store_const', dest='loglevel',
                    const=logging.DEBUG, default=logging.INFO)
    optp.add_option('-v', '--verbose', help='set logging to COMM',
                    action='store_const', dest='loglevel',
                    const=5, default=logging.INFO)

    # JID and password options.
    optp.add_option("-j", "--jid", dest="jid",
                    help="JID to use")
    optp.add_option("-p", "--password", dest="password",
                    help="password to use")

    opts, args = optp.parse_args()

    # Setup logging.
    logging.basicConfig(level=opts.loglevel,
                        format='%(levelname)-8s %(message)s')

    if opts.jid is None:
        opts.jid = raw_input("Username: ")
    if opts.password is None:
        opts.password = getpass.getpass("Password: ")

    # Setup the MUCBot and register plugins. Note that while plugins may
    # have interdependencies, the order in which you register them does
    # not matter.
    xmpp = MUCBot(opts.jid, opts.password, "lego-ev3-uart-30@muc.localhost", "device")
    xmpp.register_plugin('xep_0030') # Service Discovery
    xmpp.register_plugin('xep_0045') # Multi-User Chat
    xmpp.register_plugin('xep_0199') # XMPP Ping

    # Connect to the XMPP server and start processing XMPP stanzas.
    if xmpp.connect():
        # If you do not have the dnspython library installed, you will need
        # to manually specify the name of the server if it does not match
        # the one in the JID. For example, to use Google Talk you would
        # need to use:
        #
        # if xmpp.connect(('talk.google.com', 5222)):
        #     ...
        xmpp.process(block=True)
        print("Done")
    else:
        print("Unable to connect.")
        