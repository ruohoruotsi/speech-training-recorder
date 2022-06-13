import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtMultimedia 5.8

Window {
    id: root
    visible: true
    width: 1200; height: 800
    color: "#aaa"
    title: qsTr("Recorder")

    property bool recording: false
    property string promptsName: ''
    property string scriptText: ''
    property string scriptFilename: ''
    property string saveDir: '.'

    Component.onCompleted: initTimer.start()
    Timer {
        id: initTimer
        interval: 0
        onTriggered: recorder.init(scriptModel)
    }

    onRecordingChanged: recorder.toggleRecording(recording)
    onScriptFilenameChanged: scriptModel.get(scriptListView.currentIndex).filename = scriptFilename

    function appendScript(data) {
        scriptModel.append(data)
    }

    function gotoNextScript() {
        scriptListView.incrementCurrentIndex();
        scriptListView.positionViewAtIndex(scriptListView.currentIndex, ListView.Center);
    }

    ListModel {
        id: scriptModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 6

        Frame {
            Layout.fillHeight: true
            Layout.fillWidth: true
            focus: true

            ListView {
                id: scriptListView
                model: scriptModel
                anchors.fill: parent
                focus: true
                clip: true
                ScrollBar.vertical: ScrollBar { active: true; policy: ScrollBar.AlwaysOn }
                highlight: Rectangle { color: "lightsteelblue"; radius: 5 }

                onCurrentItemChanged: {
                    scriptText = model.get(currentIndex).script;
                    scriptFilename = model.get(currentIndex).filename;
                    console.log('selected: "' + scriptText + '", ' + scriptFilename);
                }

                delegate: Item {
                    width: parent.width - 20
                    height: 50
                    Column {
                        Text {
                            text: script
                            font.pointSize: 18
                        }
                        Text {
                            text: 'Filename: ' + filename
                            font.pointSize: 16
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: scriptListView.currentIndex = index
                    }
                }
            }
        }

        CheckBox {
            Layout.fillWidth: true
            font.pointSize: 18
            text: 'Filter all punctuation (only speak normal words!)'
            checked: true
            enabled: false
        }

        TextArea {
            Layout.fillWidth: true
            font.pointSize: 24
            wrapMode: TextEdit.Wrap
            readOnly: true
            text: scriptText
            background: Rectangle {
                border.width: 5
                border.color: recording ? "#2b2" : "#b22"
            }
        }

        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            font.pointSize: 18
            highlighted: recording
            text: recording ? "Stop" : "Start"
            onClicked: {
                recording = !recording;
                if (recording) {
                    recorder.startRecording();
                } else {
                    recorder.finishRecording();
                    gotoNextScript();
                }
            }
        }

        RowLayout {
            Button {
                Layout.fillWidth: true
                font.pointSize: 18
                text: "Play"
                enabled: scriptFilename
                highlighted: playFile.playbackState == playFile.PlayingState
                // onClicked: recorder.playFile(scriptFilename)
                onClicked: {
                    playFile.source = scriptFilename
                    playFile.play()
                }
                Audio {
                    id: playFile
                    source: ''
                }
            }

            Button {
                Layout.fillWidth: true
                font.pointSize: 18
                text: "Delete"
                enabled: scriptFilename
                onClicked: recorder.deleteFile(scriptFilename)
            }

            Button {
                Layout.fillWidth: true
                font.pointSize: 18
                text: recording ? "Cancel" : "Next"
                onClicked: {
                    if (recording) {
                        recording = !recording;
                    } else {
                        gotoNextScript()
                    }
                }
            }
        }
    }

}
