import QtQuick 2.0

import "qrc:/Qml/Buttons"

Rectangle {
   id: dateSelectArea
   anchors { centerIn: parent }
   height: dayListArea.y + dayListArea.height + canselButton.height
   width: uiSize * 3
   color: uiColor
   z:12
   state: "closed"
   enabled: visible
   clip: true
   readonly property int year:  yearList.currentIndex + 1950
   readonly property int month: monthList.currentIndex + 1
   readonly property int day:   dayList.currentIndex + 1

   property bool partialDateAllowed: false

   signal dateSelected(int type)// DAY = 1; MONTH = 2; YEAR = 3;

   function setDate(year,month,day) {
      yearList.currentIndex = year - 1950
      monthList.currentIndex = month - 1
      dayList.currentIndex = day - 1
   }

   Rectangle {
      id: yearListArea
      anchors { left: parent.left;  right: parent.right; }
      y: uiSize * 0.3
      height: uiSize * 0.8
      color: "white"
      PathView {
         id: yearList

         anchors { fill: parent }
         preferredHighlightBegin: 0.5
         preferredHighlightEnd: 0.5
         currentIndex: Qt.formatDateTime( currentDate, "yyyy") - 1950
         model: 4096 - 1950
         pathItemCount: width / uiSize
         delegate: Item {
            id: yearDelegate
            height: parent.height
            width: uiSize * 1.3
            Text {
               id: yearItemText
               anchors { centerIn: parent }
               text: index + 1950
               font.pixelSize: uiFontSize
            }
            MouseArea {
               anchors.fill: parent
               onClicked: if ( yearList.currentIndex != index ) {
                             yearList.currentIndex = index
                          } else if (partialDateAllowed){
                             dateSelected(3)
                             dateSelectArea.state = "closed"
                          }
            }
         }
         highlight: Rectangle{
            width: uiSize * 1.1 ; height: parent.height +  uiLineWidth * 2
            color: "#20000000";
            radius: 5
            border { color: uiColor; width: uiLineWidth }
         }
         path: Path {
            startX: -uiSize * 0.65
            startY: yearListArea.height / 2
            PathLine { x: yearListArea.width + uiSize * 0.65; y: yearListArea.height / 2 }
         }
      }
   }

   Rectangle {
      id: monthListArea
      anchors { horizontalCenter: parent.horizontalCenter; }
      y: uiSize * 0.4 + yearListArea.height
      width: uiSize * 1.7 * 12 < parent.width ? uiSize * 1.7 * 12 : parent.width
      height: uiSize * 0.8
      color: "white"
      radius: uiSize * 1.7 * 12 < parent.width ? 10 : 0
      PathView {
         id: monthList
         anchors { fill: parent }
         preferredHighlightBegin: 0.5
         preferredHighlightEnd: 0.5
         clip: true
         currentIndex: Qt.formatDateTime( currentDate, "MM") - 1
         model: 12
         pathItemCount: parseInt ( monthListArea.width / uiSize / 1.7 )
         delegate: Item {
            id: monthDelegate
            height: parent.height
            width: uiSize * 1.7
            Text {
               id: monthItemText
               anchors { centerIn: parent }
               text: lang.label( 12 + index )
               font.pixelSize: uiFontSize
            }
            MouseArea{
               anchors.fill: parent
               onClicked: if ( monthList.currentIndex != index ) {
                                monthList.currentIndex = index;
                          } else if (partialDateAllowed) {
                             dateSelected(2)
                             dateSelectArea.state = "closed"
                          }
            }
         }
         highlight: Rectangle{
            width: uiSize * 2.1 ; height: parent.height +  uiLineWidth * 2
            color: "#20000000";
            radius: 5
            border { color: uiColor; width: uiLineWidth }
            y: monthList.currentItem.y
         }
         path: Path {
            startX: -uiSize * 0.85
            startY: monthListArea.height / 2
            PathLine { x: monthListArea.width + uiSize * 0.85; y: monthListArea.height / 2 }
         }
      }
   }

   Rectangle {
      id: dayListArea
      anchors { horizontalCenter: parent.horizontalCenter; }
      width: dayList.count * uiSize * 0.7 < parent.width ? dayList.count * uiSize * 0.7 : parent.width
      y: uiSize * 0.5 + yearListArea.height + monthListArea.height
      height: ( Math.ceil(dayList.count / Math.floor( parent.width / dayList.cellWidth ) ) ) * dayList.cellHeight
      radius: 10
      color: "white"
      GridView {
         id: dayList
         anchors { fill: parent;  }
         cellWidth: uiSize * 0.7; cellHeight: uiSize * 0.7
         boundsBehavior:  Flickable.StopAtBounds
         currentIndex: Qt.formatDateTime( currentDate, "dd") - 1
         model: dateInfo.daysInMonth( yearList.currentIndex + 1, monthList.currentIndex + 1 )
         clip: true
         property bool isModelChanged: false
         delegate: Item {
            id: dayDelegate
            height: uiSize * 0.7
            width: uiSize * 0.7
            Text {
               id: dayItemText
               anchors { centerIn: parent }
               text: index + 1
               font.pixelSize: uiFontSize
            }
            MouseArea {
               anchors.fill: parent
               onClicked: if ( dayList.currentIndex != index ) {
                             dayList.isModelChanged = false
                             dayList.currentIndex = index
                          } else {
                             dateSelected(1)
                             dateSelectArea.state = "closed"
                          }
            }
         }
         highlight: Rectangle{
            id:dayHighlight
            width: dayList.cellWidth; height: dayList.cellHeight
            color: "#20000000";
            radius: 10
            border { color: uiColor; width: uiLineWidth }
            y: dayList.currentItem.y
            x: dayList.currentItem.x
         }
         highlightFollowsCurrentItem: false
         onCountChanged: isModelChanged = true
         onCurrentIndexChanged:
             if ( isModelChanged ) {
                if (day > count ){
                   currentIndex = count - 1
                } else currentIndex = day - 1
                isModelChanged = false
             }
      }
   }
   CustomButton {
      id: canselButton
      anchors { bottom: parent.bottom; left: parent.left; }
      width: uiSize; height: width
      Rectangle {
         anchors { fill: parent; margins: uiSize / 8 }
         color: "white"
         radius: width / 2
         Image {
            anchors.centerIn: parent
            width: uiSize / 2; height: width
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/X.svg"
         }
      }
      onClicked: {
         dateSelectArea.state = "closed"
      }
   }

   CustomButton {
      id: okButton
      anchors { bottom: parent.bottom; right: parent.right; }
      width: uiSize; height: width
      Rectangle {
         anchors { fill: parent; margins: uiSize / 8 }
         color: "white"
         radius: width / 2
         Image {
            anchors.centerIn: parent
            width: uiSize / 2; height: width
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/CheckMark.svg"
         }
      }
      onClicked: {
         dateSelected(1)
         dateSelectArea.state = "closed"
      }
   }

   MouseArea { z: -1;  anchors.fill: parent; onClicked: mouse.accepted = true }

   states: [
      State { name: "opened"
         PropertyChanges { target: dateSelectArea; visible: true;  opacity: 1; scale: 1 }
      },
      State { name: "closed"
         PropertyChanges { target: dateSelectArea; visible: false; opacity: 0;  scale: 0.8 }
      }
   ]
   transitions: [
      Transition { from: "closed"; to: "opened"
         SequentialAnimation {
            PropertyAnimation { target: dateSelectArea; properties: "visible"; duration: 0 }
            ParallelAnimation {
               PropertyAnimation { target: dateSelectArea; property: "opacity"; duration: 50 }
               PropertyAnimation { target: dateSelectArea; property: "scale";   duration: 50 }
            }
         }
      },
      Transition { from: "opened"; to: "closed"
         SequentialAnimation {
            ParallelAnimation {
               PropertyAnimation { target: dateSelectArea; property: "opacity"; duration: 50 }
               PropertyAnimation { target: dateSelectArea; property: "scale";   duration: 50 }
            }
            PropertyAnimation { target: dateSelectArea; properties: "visible"; duration: 0 }
         }
      }
   ]
}
