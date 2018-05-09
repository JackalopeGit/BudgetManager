import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQml.Models 2.3
import QtGraphicalEffects 1.0


Component {
   id: listViewComponent
   Rectangle {
      anchors.fill: parent
      color: "white"
      ListView {
         id: listView
         anchors { fill: parent; }
         clip: true
         focus: true

         cacheBuffer: 20
         property var selectedItem
         onCurrentItemChanged: { // Update the currently-selected item
            selectedItem = payDelegate.items.get(currentIndex).model;
         }
         boundsBehavior: Flickable.StopAtBounds

         ScrollBar.vertical: ScrollBar{ size: 1 }

         model: DelegateModel {
            id: payDelegate
            model: tPayModel
            delegate: Component {
               id: listItemComponent
               Item {
                  width: parent.width
                  height: baseView.height + secondViewLoader.height

                  onFocusChanged: if ( !focus ){ secondViewLoader.close() }

                  Item {
                     id: baseView

                     width: parent.width
                     height: uiSize * 5 / 3

                     clip: true
                     Text {
                        id: dateTimeLabel
                        anchors {
                           left: periodImage.right;
                           leftMargin: uiSize / 6;
                           verticalCenter: periodImage.verticalCenter
                        }
                        text: lang.label( 81 + periodType ) + ": " + period
                        font.pixelSize: uiFontSize
                     }
                     Rectangle {
                        x: uiSize / 6
                        y: uiSize / 6
                        width: categoryLabel.width + uiSize / 2
                        height: uiSize / 3 * 2
                        radius: height / 3
                        color: categoryColor
                        clip: true
                        Text {
                           id: categoryLabel
                           anchors {
                              centerIn: parent
                           }
                           text: category
                           color: Qt.lighter( parent.color , colorCheckFactor ) == "#ffffff" ? "black" : "white"
                           font.pixelSize: uiFontSize
                        }
                     }
                     Rectangle {
                        id: sumRec
                        anchors {
                           top: parent.top; right: parent.right;
                           rightMargin: uiSize / 6; topMargin: uiSize / 6
                        }
                        width: sumRow.width + uiSize / 2
                        height: uiSize * 2 / 3
                        radius: height / 3
                        color: isIncome ? "#008000" : "#f4c542"
                        Row {
                           id: sumRow
                           anchors.centerIn: parent
                           Text {
                              id: itegerLabel
                              text:  sumInteger;
                              font { bold: true; pixelSize: uiFontSizeBig }
                              color: Qt.lighter( sumRec.color, colorCheckFactor ) == "#ffffff" ? "black" : "white"
                           }
                           Text {
                              y: itegerLabel.height - height
                              text: sumFraction;
                              color: Qt.lighter( sumRec.color, colorCheckFactor ) == "#ffffff" ? "black" : "white"
                              font.pixelSize: uiFontSizeSmall
                           }
                           Text {
                              text: currency
                              font { bold: true; pixelSize: uiFontSizeBig }
                              color: Qt.lighter( sumRec.color, colorCheckFactor ) == "#ffffff" ? "black" : "white"
                           }
                        }
                     }
                     Image{
                        id: periodImage
                        anchors { bottom: parent.bottom; bottomMargin: uiSize / 6 }
                        x: uiSize / 6; width: uiSize / 48 * 20; height: width
                        sourceSize { width: uiSize / 48 * 20; height: uiSize / 48 * 20; } smooth: false
                        source: "/Icons/DateTimePeriod.svg"
                     }
                     Text {
                        id: nRepeatLabel
                        anchors { verticalCenter: periodImage.verticalCenter }
                        x: parent.width / 2
                        horizontalAlignment:  TextInput.AlignRight;
                        verticalAlignment: TextInput.AlignTop
                        text: "№ " + nRepeat
                        font.pixelSize: uiFontSize
                     }

                     MouseArea {
                        anchors { fill: parent }
                        onClicked: {
                           if ( secondViewLoader.state == "opened" ) {
                              secondViewLoader.close();
                              listView.currentIndex = index;
                           } else {
                              secondViewLoader.open();
                              listView.currentIndex = index;
                           }
                        }
                     }
                  }
                  Image {
                     id: enabledImage
                     z: 3
                     y: uiSize
                     x: parent.width -  uiSize / 48 * 34
                     sourceSize.width: uiSize / 12 * 5; sourceSize.height: uiSize / 12 * 5
                     source: "/Icons/Power.svg"
                     opacity: secondViewLoader.state == "closed" ? ( isEnabled ? 1 : 0 ) : 1
                     Behavior on opacity { NumberAnimation { duration: 200; } }
                  }

                  Rectangle {
                     id: borderLine
                     anchors {
                        horizontalCenter: parent.horizontalCenter;
                        bottom: parent.bottom;
                     }
                     color: uiColor
                     implicitWidth: listView.width;
                     implicitHeight: uiLineWidth
                  }
                  Loader{
                     id: secondViewLoader
                     anchors {
                        top: baseView.bottom;
                        left: parent.left;
                        right: parent.right
                     }
                     state: "closed"
                     sourceComponent: state == "closed" ? undefined : secondView
                     height: (item !== null && typeof(item)!== 'undefined')?
                                item.height
                              : 0
                     function open(){
                        state = "opened"
                        item.open()
                     }
                     function close(){
                        if ( item != null ) item.close()
                     }
                  }
                  Component {
                     id: secondView
                     Item {
                        id: tPayView
                        height: 0

                        function open(){
                           state = "opened"
                        }
                        function close(){
                           state = "closed"
                        }
                        Text {
                           id: maxRepeatLabel
                           anchors { bottom: parent.top; bottomMargin: uiSize / 6; }
                           x: nRepeatLabel.x + nRepeatLabel.width
                           horizontalAlignment:  TextInput.AlignRight;
                           verticalAlignment: TextInput.AlignTop
                           text: '/ ' + ( maxRepeat > 0 ? maxRepeat : '∞' )
                           font.pixelSize: uiFontSizeBig
                           color: "white"
                        }

                        Item {
                           id: enabledToggle
                           anchors { bottom: parent.top; right: parent.right }
                           width: uiSize
                           height: uiSize
                           opacity: 0
                           z: 2
                           Rectangle {
                              id: enabledRec
                              anchors { horizontalCenter: parent.horizontalCenter; }
                              y: uiSize / 48 * 10
                              width: uiSize / 48 * 32
                              height: width
                              color: isEnabled ? uiColor : "transparent"
                              radius: uiSize / 48 * 9
                              border { color: "black"; width: uiSize / 48 * 3 }
                              Behavior on color { ColorAnimation{ duration: 100; } }
                           }
                           MouseArea {
                              anchors.fill: parent
                              onClicked: {
                                 isEnabled = !isEnabled
                                 enabledRec.color = isEnabled ? uiColor : "transparent"
                              }
                           }
                        }

                        Item {
                           id: bottomPart
                           anchors.fill: parent
                           clip: true

                           LinearGradient {
                              anchors {
                                 top: parent.top;
                                 left: parent.left;
                                 right: parent.right;
                              }
                              height: uiSize / 6
                              start: Qt.point( 0, 0)
                              end:   Qt.point( 0, height )
                              gradient: Gradient {
                                 GradientStop { position: 0.0; color: uiShadowColor }
                                 GradientStop { position: 1; color: "transparent" }
                              }
                           }
                           Image{
                              id: dateFromImage
                              anchors {
                                 left: parent.left; leftMargin: uiSize / 6;
                                 bottom: parent.bottom;
                                 bottomMargin: tPayView.height - uiSize / 3 * 2
                              }
                              width: uiSize / 48 * 20; height: width
                              sourceSize { width: uiSize / 48 * 20; height: uiSize / 48 * 20; } smooth: false
                              source: "/Icons/DateFrom.svg"
                           }
                           Text {
                              id: dateFromLabel
                              anchors {
                                 left: dateFromImage.right;
                                 leftMargin: uiSize / 6;
                                 verticalCenter: dateFromImage.verticalCenter
                              }
                              text: dayFrom + ' '
                                    + lang.label( 11 + monthFrom )
                                    + ' ' + yearFrom
                              font.pixelSize: uiFontSize
                           }
                           Image{
                              id: timeFromImage
                              anchors {
                                 left: dateFromLabel.right; leftMargin: uiSize / 6;
                                 verticalCenter: dateFromImage.verticalCenter
                              }
                              width: uiSize / 48 * 20; height: width
                              sourceSize { width: uiSize / 48 * 20; height: uiSize / 48 * 20; } smooth: false
                              source: "/Icons/TimeFrom.svg"
                           }
                           Text {
                              id: timeFromLabel
                              anchors {
                                 left: timeFromImage.right; leftMargin: uiSize / 6;
                                 verticalCenter: timeFromImage.verticalCenter
                              }
                              text: ( hourFrom < 10 ? '0' + hourFrom : hourFrom ) + ":"
                                    + ( minuteFrom < 10 ? '0' + minuteFrom : minuteFrom )
                              font.pixelSize: uiFontSize
                           }

                           Text {
                              id: descriptionText
                              anchors {
                                 top: dateFromImage.bottom;
                                 left: parent.left; margins: uiSize / 8;
                                 right: parent.right
                              }
                              wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                              text: description != "" ? description : lang.label( 60 )
                              color: description != "" ? "black" : "#808080"
                              font.pixelSize: uiFontSize
                           }
                           Image {
                              id: deleteImage
                              anchors {
                                 right: parent.right;
                                 bottom: parent.bottom;
                                 margins: uiSize / 6 }
                              y: dateFromImage.height + descriptionText.height
                              width: uiSize / 3 * 2; height: width
                              sourceSize { width: uiSize / 3 * 2; height: uiSize / 3 * 2; } smooth: false
                              source: "/Icons/Trash.svg"
                              MouseArea {
                                 anchors.fill: parent
                                 onClicked: tPayModel.eraseTPay( index )
                              }
                           }
/*                           Image {
                              id: editImage
                              anchors {
                                 right: parent.right;
                                 rightMargin: uiSize * 7 / 6;
                                 bottom: parent.bottom;
                                 bottomMargin: uiSize / 6 }
                              width: uiSize / 3 * 2; height: width
                              sourceSize { width: uiSize / 3 * 2; height: uiSize / 3 * 2; } smooth: false
                              source: "/Icons/Pencil.svg"
                           }*//*
                           LinearGradient {
                              anchors {
                                 left: parent.left;
                                 right: parent.right;
                                 bottom: parent.bottom;
                                 bottomMargin: uiLineWidth }
                              height: uiSize * 0.1
                              start: Qt.point(0, uiSize * 0.1)
                              end:  Qt.point(0, 0 )
                              gradient: Gradient {
                                 GradientStop { position: 0.0; color: "#C6C6C6" }
                                 GradientStop { position: 1; color: "transparent" }
                              }
                           }*/
                        }

                        states: [
                           State {
                              name: "opened"
                              PropertyChanges { target: maxRepeatLabel; color: "#808080" }
                              PropertyChanges { target: enabledToggle;      opacity: 1 }
                              PropertyChanges {  target: tPayView;
                                 height: periodImage.height + descriptionText.height + uiSize * 1.3
                              }
                           },
                           State {
                              name: "closed"
                              PropertyChanges { target: maxRepeatLabel;      color: "white" }
                              PropertyChanges { target: tPayView;         height: 0 }
                              PropertyChanges { target: enabledToggle;      opacity: 0 }
                              PropertyChanges { target: secondViewLoader; state: "closed" }
                           }
                        ]
                        transitions: [
                           Transition { to: "opened"
                              ParallelAnimation {
                                 PropertyAnimation { target: maxRepeatLabel;
                                    property: "color"; duration: 150
                                 }
                                 PropertyAnimation { target: enabledToggle;
                                    property: "opacity"; duration: 300
                                 }
                                 PropertyAnimation { target: tPayView;
                                    property: "height";
                                    easing.type: Easing.InOutQuint; duration: 300
                                 }
                              }
                           },
                           Transition { to: "closed"
                              SequentialAnimation {
                                 ParallelAnimation {
                                    PropertyAnimation { target: maxRepeatLabel;
                                       property: "color"; duration: 150
                                    }
                                    PropertyAnimation { target: enabledToggle;
                                       property: "opacity"; duration: 150
                                    }
                                    PropertyAnimation { target: tPayView;
                                       property: "height"; easing.type:
                                           Easing.InOutQuint; duration: 300
                                    }
                                 }
                                 PropertyAnimation { target: secondViewLoader;
                                    properties: "state"; duration: 1
                                 }
                              }

                           }
                        ]
                     }
                  }
               }
            }
         }
         remove: Transition {
            ParallelAnimation {
               NumberAnimation { property: "opacity"; to: 0; duration: 100 }
            }
         }
         removeDisplaced: Transition {
            NumberAnimation { properties: "y"; duration: 150 }
         }
         displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 1000 }
         }
      }
   }
}
