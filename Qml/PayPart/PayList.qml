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
         ScrollBar.vertical: ScrollBar{}
         cacheBuffer: 20
         property var selectedItem
         onCurrentItemChanged: { // Update the currently-selected item
            selectedItem = payDelegate.items.get(currentIndex).model;
         }

         boundsBehavior: Flickable.StopAtBounds
         model: DelegateModel {
            id: payDelegate
            model: payModel
            delegate: Component {
               id: listItemComponent
               Item {
                  id: itemComponent

                  width: parent.width
                  height: baseView.height + secondViewLoader.height

                  onFocusChanged: if ( !focus ){ secondViewLoader.close() }

                  Item {

                     id: baseView
                     width: parent.width
                     height: uiSize * 5 / 3
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

                     /*Image{
                        id: categoryImage
                        anchors {
                           top: parent.top;
                           left: parent.left;
                           leftMargin: uiSize / 6;
                           topMargin: uiSize / 4
                        }
                        width: uiSize / 48 * 20; height: width
                        sourceSize { width: parent.width; height: parent.height; } smooth: false
                        source: "/Icons/Category.svg"
                     }*/
                     Image{
                        id: dateImage
                        anchors {
                           left: parent.left;
                           leftMargin: uiSize / 6;
                           topMargin: uiSize / 3
                        }
                        y: uiSize
                        width: uiSize / 48 * 20; height: width
                        sourceSize { width: uiSize / 48 * 20; height: uiSize / 48 * 20; } smooth: false
                        source: "/Icons/Date.svg"
                     }
                     Text {
                        id: dateLabel
                        anchors {
                           verticalCenter: dateImage.verticalCenter;
                           left: dateImage.right; margins: uiSize / 6
                        }
                        text: day +  ' ' + lang.label( 11 + month ) + ' ' + year;
                        font.pixelSize: uiFontSize
                     }

                     Image{
                        id: timeImage
                        anchors {
                           top: dateImage.top;
                           left: dateLabel.right ;
                           leftMargin: uiSize / 3;
                        }
                        width: uiSize / 48 * 20; height: width
                        sourceSize { width: uiSize / 48 * 20; height: uiSize / 48 * 20; } smooth: false
                        source: "/Icons/Time.svg"
                     }
                     Text {
                        id: timeLabel
                        anchors {
                           verticalCenter: timeImage.verticalCenter;
                           left: timeImage.right; margins: uiSize / 6
                        }
                        text: (hour < 10 ? '0' + hour : hour ) + ":"
                              + (minute < 10 ? '0' + minute : minute );
                        font.pixelSize: uiFontSize
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
                     Image {
                        id: fromTPayImage
                        anchors.verticalCenter: dateImage.verticalCenter
                        x: parent.width -  uiSize / 12 * 7
                        sourceSize.width: uiSize / 12 * 5; sourceSize.height: uiSize / 12 * 5
                        source: "/Icons/T.svg"
                        visible: isFromTPay ? 1 : 0
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


                  Loader{
                     id: secondViewLoader
                     anchors {
                        top: baseView.bottom;
                        left: parent.left;
                        right: parent.right
                     }
                     state: "closed"
                     sourceComponent: state == "closed" ? undefined : secondView
                     height: (item !== null && typeof(item)!== 'undefined') ?
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
                        id: payView
                        height: 0

                        function open(){
                           state = "opened"
                        }
                        function close(){
                           state = "closed"
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
                           Text {
                              id: descriptionText
                              anchors {
                                 left: parent.left; right: parent.right
                                 leftMargin: uiSize / 8; rightMargin: uiSize / 6;
                                 bottom: parent.bottom;
                                 bottomMargin: payView.height - uiSize / 6 - height
                              }
                              wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                              text: description != "" ? description : lang.label( 46 )
                              color: description != "" ? "black" : "#808080"
                              font.pixelSize: uiFontSize
                           }
                           Image {
                              id: deleteImage
                              anchors {
                                 right: parent.right;
                                 bottom: parent.bottom;
                                 margins: uiSize / 6 }
                              y: descriptionText.height
                              width: uiSize / 3 * 2; height: width
                              sourceSize { width: uiSize / 3 * 2; height: uiSize / 3 * 2; } smooth: false
                              source: "/Icons/Trash.svg"
                              MouseArea {
                                 anchors.fill: parent
                                 onClicked: payModel.erasePay( index )
                              }
                           }
//                           Image {
//                              id: editImage
//                              anchors {
//                                 right: parent.right;
//                                 rightMargin: uiSize * 7 / 6;
//                                 bottom: parent.bottom;
//                                 bottomMargin: uiSize / 6 }
//                              width: uiSize / 3 * 2; height: width
//                              sourceSize { width: uiSize / 3 * 2; height: uiSize / 3 * 2; } smooth: false
//                              source: "/Icons/Pencil.svg"
//                           }
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
                           }
                        }

                        states: [
                           State {
                              name: "opened"
                              PropertyChanges {
                                 target: payView;
                                 height: descriptionText.height + uiSize * 1.3
                              }
                           },
                           State {
                              name: "closed"
                              PropertyChanges {
                                 target: payView;
                                 height: 0
                              }
                              PropertyChanges {
                                 target: secondViewLoader; state: "closed"
                              }
                           }
                        ]
                        transitions: [
                           Transition { to: "opened"
                              PropertyAnimation {
                                 target: payView;
                                 property: "height";
                                 easing.type: Easing.InOutQuint;
                                 duration: 300
                              }
                           },
                           Transition { to: "closed"
                              SequentialAnimation {
                                 PropertyAnimation {
                                    target: payView;
                                    property: "height";
                                    easing.type: Easing.InOutQuint;
                                    duration: 300
                                 }
                                 PropertyAnimation {
                                    target: secondViewLoader;
                                    properties: "state";
                                    duration: 1
                                 }
                              }
                           }
                        ]
                     }
                  }

                  Rectangle {
                     id: borderLine
                     anchors {
                        horizontalCenter: parent.horizontalCenter;
                        bottom: parent.bottom;
                     }
                     width: listView.width;
                     height: uiLineWidth
                     color: Qt.darker( categoryColor )
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
