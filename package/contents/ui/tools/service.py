#!/usr/bin/env python
"""
Get cursor position by loading a kwin script, then use a python dbus service
to keep/read the last value
"""

import time
import subprocess
import sys
import logging
import threading
import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib

DBusGMainLoop(set_as_default=True)
bus = dbus.SessionBus()

RELOAD_INTERVAL_MS = 16
INTERVAL_S = RELOAD_INTERVAL_MS / 1000
SERVICE_NAME = "luisbocanegra.cursor.eyes"
PATH = "/cursor"

if len(sys.argv) != 4:
    print("Usage: python script.py <SCRIPT_NAME> <SCRIPT_FILE> <QDBUS_EXEC>")
    sys.exit(1)

SCRIPT_NAME = sys.argv[1]
SCRIPT_FILE = sys.argv[2]
QDBUS_EXEC = sys.argv[3]


class Service(dbus.service.Object):
    def __init__(self):
        self._loop = GLib.MainLoop()
        self._cursor_pos = ""

    def run(self):
        DBusGMainLoop(set_as_default=True)
        bus_name = dbus.service.BusName(SERVICE_NAME, dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, PATH)

        print("Service running...")
        self._loop.run()
        print("Service stopped")

    @dbus.service.method(SERVICE_NAME, in_signature="s")
    def save_position(self, m):
        if m != self._cursor_pos:
            print(f"New cursor position: '{m}'")
            self._cursor_pos = m

    @dbus.service.method(SERVICE_NAME, in_signature="", out_signature="s")
    def get_position(self):
        return self._cursor_pos

    @dbus.service.method(SERVICE_NAME, in_signature="", out_signature="")
    def quit(self):
        print("Shutting down")
        self._loop.quit()


def loop_kwin_script():
    while True:
        kwin = bus.get_object("org.kde.KWin", "/Scripting")
        try:
            kwin.unloadScript(SCRIPT_NAME, dbus_interface="org.kde.kwin.Scripting")
        except Exception:
            pass

        # Calling this overloaded method raises TypeError:
        # Fewer items found in D-Bus signature than in Python arguments
        # use subprocess with qdbus instead :(
        try:
            # Construct the command with the necessary arguments
            command = [
                QDBUS_EXEC,
                "org.kde.KWin",
                "/Scripting",
                "org.kde.kwin.Scripting.loadScript",
                SCRIPT_FILE,
                SCRIPT_NAME,
            ]

            # Execute the command and decode the output
            result = subprocess.run(command, capture_output=True, text=True, check=True)
            script_id = result.stdout.strip()

            # Check if the script_id is an integer and convert it
            if not script_id.isdigit():
                raise ValueError(f"Invalid script ID returned: {script_id}")

            script = bus.get_object("org.kde.KWin", "/Scripting/Script" + script_id)
            script = dbus.Interface(script, "org.kde.kwin.Script")
            script.run()
            script.stop()

        except subprocess.CalledProcessError as e:
            logging.exception("An error occurred while loading the script: %s", e)
            raise
        except ValueError as e:
            logging.exception("An error occurred: %s", e)
            raise
        time.sleep(INTERVAL_S)


if __name__ == "__main__":
    try:
        # Keep a single instance of the service
        bus.get_object(SERVICE_NAME, PATH)
        print("Service is already running")
    except dbus.exceptions.DBusException:
        # Service is not running, so we can start it
        threading.Thread(target=loop_kwin_script).start()
        Service().run()
