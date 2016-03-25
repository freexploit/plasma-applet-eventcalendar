import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.calendar 2.0 as PlasmaCalendar

import org.kde.kquickcontrolsaddons 2.0 // KCMShell

Item {
    id: root

    width: units.gridUnit * 10
    height: units.gridUnit * 4

    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

    Plasmoid.toolTipMainText: Qt.formatTime(dataSource.data["Local"]["DateTime"])
    Plasmoid.toolTipSubText: Qt.formatDate(dataSource.data["Local"]["DateTime"], Qt.locale().dateFormat(Locale.LongFormat))

    PlasmaCore.DataSource {
        id: dataSource
        engine: "time"
        connectedSources: ["Local"]
        interval: plasmoid.configuration.clock_show_seconds ? 1000 : 60000
        intervalAlignment: plasmoid.configuration.clock_show_seconds ? PlasmaCore.Types.NoAlignment : PlasmaCore.Types.AlignToMinute
    }
    
    FontLoader {
        source: "../fonts/weathericons-regular-webfont.ttf"
    }

    // org.kde.plasma.mediacontrollercompact
    PlasmaCore.DataSource {
        id: executeSource
        engine: "executable"
        connectedSources: []
        onNewData: {
            //we get new data when the process finished, so we can remove it
            disconnectSource(sourceName)
        }
    }
    function exec(cmd) {
        //Note: we assume that 'cmd' is executed quickly so that a previous call
        //with the same 'cmd' has already finished (otherwise no new cmd will be
        //added because it is already in the list)
        executeSource.connectSource(cmd)
    }

    Plasmoid.compactRepresentation: ClockView {
        id: clock

        cfg_clock_24h: plasmoid.configuration.clock_24h
        cfg_clock_timeformat: plasmoid.configuration.clock_timeformat

        // org.kde.plasma.volume
        MouseArea {
            id: mouseArea
            anchors.fill: parent

            property int wheelDelta: 0

            onClicked: {
                if (mouse.button == Qt.LeftButton) {
                    plasmoid.expanded = !plasmoid.expanded;
                }
            }

            // http://dev.man-online.org/man1/xdotool/
            // xmodmap -pke
            // keycode 122 = XF86AudioLowerVolume NoSymbol XF86AudioLowerVolume
            // keycode 123 = XF86AudioRaiseVolume NoSymbol XF86AudioRaiseVolume
            onWheel: {
                var delta = wheel.angleDelta.y || wheel.angleDelta.x;
                wheelDelta += delta;
                // Magic number 120 for common "one click"
                // See: http://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
                while (wheelDelta >= 120) {
                    wheelDelta -= 120;
                    root.exec(plasmoid.configuration.clock_mousewheel_up)
                }
                while (wheelDelta <= -120) {
                    wheelDelta += 120;
                    root.exec(plasmoid.configuration.clock_mousewheel_down)
                }
            }
        }
    }

    Plasmoid.fullRepresentation: PopupView {
        id: popup
        today: dataSource.data["Local"]["DateTime"]
        config: plasmoid.configuration
        cfg_widget_show_spacer: plasmoid.configuration.widget_show_spacer
        cfg_widget_show_timer: plasmoid.configuration.widget_show_timer

        property bool isExpanded: plasmoid.expanded
        onIsExpandedChanged: {
            console.log('isExpanded', isExpanded);
            if (isExpanded) {
                monthViewDate = today
                selectedDate = today
                // update();
            }
        }

        Component.onCompleted: {
            agendaView.cfg_clock_24h = plasmoid.configuration.clock_24h
        }

        Connections {
            target: plasmoid.configuration
            onClock_24hChanged: { updateUI() }
            onCalendar_id_listChanged: { updateEvents() }
            onAccess_tokenChanged: { updateEvents() }
            onWeather_app_idChanged: { updateWeather(true) }
            onWeather_city_idChanged: { updateWeather(true) }
            onWidget_show_spacerChanged: { updateHeight() }
            onWidget_show_timerChanged: { updateHeight() }
        }

    }
    function action_KCMClock() {
        KCMShell.open("clock");
    }

    function action_KCMFormats() {
        KCMShell.open("formats");
    }

    Component.onCompleted: {
        plasmoid.setAction("KCMClock", i18n("Adjust Date and Time..."), "preferences-system-time");
        plasmoid.setAction("KCMFormats", i18n("Set Time Format..."));
    }
}
