"""dbus run command example service
"""

import subprocess
import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib


class Service(dbus.service.Object):
    def __init__(self):
        self._loop = GLib.MainLoop()

    def run(self):
        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
        bus_name = dbus.service.BusName("com.example.runcommand", dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, "/com/example/runcommand")

        print("Service running...")
        self._loop.run()
        print("Service stopped")

    @dbus.service.method("com.example.runcommand", in_signature="s", out_signature="i")
    def run_command(self, m):
        print(f"Running command '{m}'")
        command = m.split()
        result = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            check=True,
        )

        print(f"exit code: '{result.returncode}'")
        print(f"stdout: '{result.stdout.strip()}'")
        return result.returncode

    @dbus.service.method("com.example.runcommand", in_signature="", out_signature="i")
    def notify_send(self):
        command = ["notify-send", "Hello", "World"]
        command_str = " ".join(command)
        print(f"Running command '{command_str}'")
        result = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            check=True,
        )

        print(f"exit code: '{result.returncode}'")
        print(f"stdout: '{result.stdout.strip()}'")
        return result.returncode

    @dbus.service.method("com.example.runcommand", in_signature="", out_signature="")
    def quit(self):
        print("Shutting down")
        self._loop.quit()


if __name__ == "__main__":
    Service().run()
