# Adding new themes

Themes go inside `package/contents/ui/themes/`

Theme file structure:

```sh
ThemeNameExampleDir/
├── config
├── Example-eye.png
└── Example-pupil.png
```

Theme `config` file must have the names of eye and pupil images:

```ini
# config file
eye-pixmap = "example-eye.png"
pupil-pixmap = "example-pupil.png"
```

After adding a new theme run `./gen_themes_index` from the project directory, this will update `package/contents/ui/themes/index.json` with the new theme(s).

## AUTHORS

Eye files came from (ThemeName from/by project/user name):

- [gnome-applets/geyes](https://gitlab.gnome.org/GNOME/gnome-applets/-/tree/master/gnome-applets/geyes) and its derived [mate-applets/geyes](https://github.com/mate-desktop/mate-applets/tree/master/geyes)
  - Bizarre
  - Bloodshot
  - Brown-EyedGirl
  - Default
  - Default-tiny
  - Digital
  - EyelashLarge
  - Green-EyedGirl
  - Horrid
  - Pink-EyedGirl
  - PumpkinMonster
  - Tango
- Crystal theme from [lxqt-panel/plugin-qeyes](https://github.com/lxqt/lxqt-panel/tree/master/plugin-qeyes/)
