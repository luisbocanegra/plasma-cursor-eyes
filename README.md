<div align="center">

# Cursor Eyes

![panel](screenshots/panel.png)

Follow mouse widget for the KDE Plasma Desktop inspired by [xfce4-eyes-plugin](https://gitlab.xfce.org/panel-plugins/xfce4-eyes-plugin). A demo of getting KWin Script output from a Plasma Widget using D-Bus and Python

https://github.com/luisbocanegra/plasma-cursor-eyes/assets/15076387/e4e70877-4d5e-4ca6-b09b-1bc4b3c41480

</div>

## TODO

* [ ] Vertical panel
* [ ] Appearance customization maybe?

## Installing

### Requisites

Make sure you have python 3, python-gobject, dbus-python, qt6-tools (for qdbus6) packages installed

~~Install the widget from the KDE Store [Plasma 6 version](https://store.kde.org/p/2145723)~~ TODO

1. ~~**Right click on the Desktop** > **Edit Mode** > **Add Widgets** > **Get New Widgets** > **Download new...**~~ TODO
2. ~~**Search** for "**Cursor Eyes**", install and add it to your Panel/Desktop.~~ TODO

### Manual install

* Install dependencies (please let me know if I missed something)

  ```txt
    cmake extra-cmake-modules plasma-framework
  ```

* Install the plasmoid

  ```sh
  ./install.sh
  ```

## How does it work?

1. A KWin Script that reads the cursor position x times per second (default is 30)
2. Widget starts a D-Bus service (python script) to store and return the cursor position
3. The KWin Script sends the cursor position to the D-Bus service using `callDbus` (or `DBusCall` for the qml version)
4. The widget gets the last saved cursor position from the running D-Bus service
5. When there are multiple instances of the widget only one runs the service

There are two versions of the script, one replaces the other. By default the Javascript version is what is installed and the qml one is provided mostly for demonstration purposes.

## Credits & Resources

* Inspired by [xfce4-eyes-plugin](https://gitlab.xfce.org/panel-plugins/xfce4-eyes-plugin) [xorg/app/xeyes](https://gitlab.freedesktop.org/xorg/app/xeyes)
* Related topic [Determine when monitor is turned on or off via python dbus](https://discuss.kde.org/t/determine-when-monitor-is-turned-on-or-off-via-python-dbus/11980/7)
* [jinliu/kdotool](https://github.com/jinliu/kdotool) for reading KWin script output inspiration
* [c0d3xd3v/qt-tuxeyes](https://github.com/c0d3xd3v/qt-tuxeyes)
