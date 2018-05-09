import QtQuick 2.9
import QtQml.Models 2.3

import "qrc:/Qml/Buttons"

Rectangle {
   id: dateSelectArea
   anchors { centerIn: parent }
   width: dpi < 120 ? 320 : dpi * 2;
   height: uiSize * 3
   color: "white"
   z: 12
   state: "closed"
   enabled: visible

   property int  beginYear:  Qt.formatDateTime( currentDate, "yyyy")
   property int  beginMonth: Qt.formatDateTime( currentDate, "MM")
   property int  beginDay:   Qt.formatDateTime( currentDate, "dd")
   property int  endYear:  Qt.formatDateTime( currentDate, "yyyy")
   property int  endMonth: Qt.formatDateTime( currentDate, "MM")
   property int  endDay:   Qt.formatDateTime( currentDate, "dd")
   property bool isEndSelecting: false

   property int dateType: 0 // PERIOD = 0; DAY = 1; MONTH = 2; YEAR = 3; AllTime = 4
   property bool isAllTimeAllowed: true;

   signal dateSelected(int type)

   CustomButton2 {
      id: modeSelect
      width: parent.width; height: uiSize
      property bool isPeriod: false
      state: isPeriod ? "period" : "date"
      Text {
         id: dateText
         anchors { verticalCenter: parent.verticalCenter; }
         text: lang.label( 48 )
      }
      Text {
         id: periodText
         anchors { verticalCenter: parent.verticalCenter; }
         text: lang.label( 59 )
      }
      onClicked: isPeriod = !isPeriod
      states: [
         State { name: "date"
            PropertyChanges {target: dateText;x: (parent.width-width)/2; color: "black";font.pixelSize: uiFontSizeBig}
            PropertyChanges{target:periodText;x:parent.width-uiSize/2-width;color:"gray";font.pixelSize:uiFontSizeSmall}
         },
         State { name: "period"
            PropertyChanges {target: dateText; x:  uiSize/2; color: "gray"; font.pixelSize: uiFontSizeSmall}
            PropertyChanges {target: periodText;x: (parent.width-width)/2; color: "black";font.pixelSize: uiFontSizeBig}
         }
      ]
      transitions: [
         Transition {
            PropertyAnimation {targets: [dateText,periodText]; properties: "x,color,font.pixelSize"; duration: 70 }
         }
      ]
   }

   Item {
      id: dateTimeFrom
      width: parent.width
      height: uiSize
      y: uiSize
      clip: true
      CustomButton2 {
         id: dateFromSection
         width: parent.width / 2
         x: modeSelect.isPeriod ? 0 : (parent.width - width) / 2
         height: uiSize
         Image{
            anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/DateFrom.svg"
         }
         Text {
            id: dateFromLabel
            anchors { verticalCenter: parent.verticalCenter }
            text: beginDay + " " + lang.label(11+beginMonth) + " " + beginYear
            font.pixelSize: uiFontSizeBig
            x: uiSize / 48 * 52
            onTextChanged: {
               font.pixelSize = uiFontSizeBig
               while ( parent.width - uiSize/6*7 < width ) font.pixelSize--
            }
            Component.onCompleted: {while ( parent.width - uiSize/6*7 < width ) font.pixelSize--}
         }
         onClicked: {
            dateInput.isFrom = true
            dateInput.state = "opened"
            dateInput.setDate( beginYear, beginMonth, beginDay )
         }
         Behavior on x { NumberAnimation { duration: 70; } }
      }
      Rectangle {
         x: dateToSection.x
         height: uiSize
         width: uiLineWidth
         color: "#CCCCCC"
      }
      CustomButton2 {
         id: dateToSection
         x: modeSelect.isPeriod ? width : width * 2
         width: parent.width / 2; height: uiSize;
         Image{
            anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/DateFrom.svg"
         }
         Text {
            id: dateToLabel
            anchors { verticalCenter: parent.verticalCenter }
            x: uiSize / 48 * 52
            text: endDay + " " + lang.label(11+endMonth) + " " + endYear
            font.pixelSize: uiFontSizeBig
            onTextChanged: {
               font.pixelSize = uiFontSizeBig
               while ( parent.width - uiSize/6*7 < width ) font.pixelSize--
            }
            Component.onCompleted: {while ( parent.width - uiSize/6*7 < width ) font.pixelSize--}
         }
         onClicked: {
            dateInput.isFrom = false
            dateInput.state = "opened"
            dateInput.setDate( endYear, endMonth, endDay )
         }
         Behavior on x { NumberAnimation { duration: 70; } }
      }
   }
   CustomButton2 {
      id: cancelButton
      anchors { bottom: parent.bottom; left: parent.left; }
      width: isAllTimeAllowed ? parent.width / 3 : parent.width / 2
      height: uiSize
      Text {
         anchors { centerIn: parent }
         text: lang.label( 31 )
         font.pixelSize: uiFontSize
      }
      onClicked: {
         dateSelectArea.state = "closed"
      }
   }

   Rectangle {
      anchors { bottom: parent.bottom; }
      x: isAllTimeAllowed ? parent.width / 3 : parent.width / 2
      height: uiSize
      width: uiLineWidth
      color: "#CCCCCC"
   }
   CustomButton2 {
      id: allTimeButton
      anchors { bottom: parent.bottom; left: cancelButton.right; }
      visible: isAllTimeAllowed
      enabled: isAllTimeAllowed
      width: parent.width / 3
      height: uiSize
      Text {
         anchors { centerIn: parent }
         text: lang.label( 102 )
         font.pixelSize: uiFontSize
      }
      onClicked: {
         dateSelected(4)
         dateSelectArea.state = "closed"
      }
   }
   Rectangle {
      anchors { bottom: parent.bottom; }
      x: parent.width / 3 * 2
      visible: isAllTimeAllowed
      enabled: isAllTimeAllowed
      height: uiSize
      width: uiLineWidth
      color: "#CCCCCC"
   }

   CustomButton2 {
      id: okButton
      anchors { bottom: parent.bottom; right: parent.right; }
      width: isAllTimeAllowed ? parent.width / 3 : parent.width / 2
      height: uiSize
      Text {
         anchors { centerIn: parent }
         text: lang.label( 9 )
         font.pixelSize: uiFontSize
      }
      onClicked: { dateSelected( modeSelect.isPeriod ? 0 : 1 ); dateSelectArea.state = "closed" }
   }

   Rectangle {
      anchors { left: parent.left; right: parent.right; }
      y: uiSize - 1;
      height: uiLineWidth
      color: "#CCCCCC"
   }

   Rectangle {
      anchors { left: parent.left; right: parent.right; }
      y: uiSize * 2 - 1;
      height: uiLineWidth
      color: "#CCCCCC"
   }

   DateInput{
      id: dateInput
      property bool isFrom: false
      partialDateAllowed: !modeSelect.isPeriod
      onDateSelected: {
         if (isFrom){
            beginYear = year
            if ( !modeSelect.isPeriod ){
               if ( type == 1 ) beginDay = day;
               if ( type < 3 ) beginMonth = month;
               dateSelectArea.state = "closed"
               dateSelectArea.dateSelected(type)
            } else {
               beginDay = day;
               beginMonth = month;
            }
         } else {
            endDay = day; endMonth = month; endYear = year
         }
         dateType = type
      }
      width: dateSelectArea.parent.width
   }

   MouseArea { z: -1;  anchors.fill: parent; onClicked: mouse.accepted = true }

   states: [
      State {
         name: "closed"
         PropertyChanges { target: dateSelectArea; y: -height; opacity: 0; visible: false }
      },
      State {
         name: "opened"
         PropertyChanges { target: dateSelectArea; y: uiSize * 0.5; opacity: 1; visible: true }
      }
   ]
   transitions: [
      Transition { from: "closed"; to: "opened"
         SequentialAnimation {
            PropertyAnimation { properties: "visible"; duration: 0 }
            ParallelAnimation {
               PropertyAnimation { properties: "opacity,y"; duration: 50 }
            }
         }
      },
      Transition { from: "opened"; to: "closed"
         SequentialAnimation {
            ParallelAnimation {
               PropertyAnimation { properties: "opacity,y"; duration: 50 }
            }
            PropertyAnimation { properties: "visible"; duration: 0 }
         }
      }
   ]
}
