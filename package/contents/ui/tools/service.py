#!/usr/bin/env python
"""
D-Bus service to keep track of the last cursor position from KWin Script,
which is sent using callDBus (js) or DBusCall (qml)
"""

import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib
import json

DBusGMainLoop(set_as_default=True)
bus = dbus.SessionBus()

SERVICE_NAME = "luisbocanegra.cursor.eyes"
PATH = "/cursor"


class Service(dbus.service.Object):
    def __init__(self):
        self._loop = GLib.MainLoop()
        self._cursor_pos = ""
        self._active_window = {"resourceName": "", "caption": ""}

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
            # print(f"New cursor position: '{m}'")
            self._cursor_pos = m

    @dbus.service.method(SERVICE_NAME, in_signature="s")
    def save_active_window(self, m):
        res = {}
        try:
            res = json.loads(m)
        except json.JSONDecodeError:
            pass
        if res["resourceName"] != self._active_window["resourceName"]:
            self._active_window = res

    @dbus.service.method(SERVICE_NAME, in_signature="", out_signature="s")
    def get_position(self):
        return self._cursor_pos

    @dbus.service.method(SERVICE_NAME, in_signature="", out_signature="s")
    def get_active_window(self):
        return json.dumps(self._active_window)

    @dbus.service.method(SERVICE_NAME, in_signature="", out_signature="")
    def quit(self):
        print("Shutting down")
        self._loop.quit()


if __name__ == "__main__":
    # Keep a single instance of the service
    try:
        bus.get_object(SERVICE_NAME, PATH)
        print("Service is already running")
    except dbus.exceptions.DBusException:
        Service().run()
