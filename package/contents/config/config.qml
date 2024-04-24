import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "preferences"
        source: "configGeneral.qml"
    }

    ConfigCategory {
        name: i18n("Troubleshooting")
        icon: "tools-report-bug"
        source: "configDebugging.qml"
    }
}
