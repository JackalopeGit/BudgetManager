import QtQuick 2.9
import QtQuick.Window 2.1
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import "qrc:/Qml"
import "qrc:/Qml/Inputs"
import "qrc:/Qml/Buttons"

Item {
   id: payPage

   property int resetButtonMargins: uiSize / 6

   function updateLabels(){
      filterDrawer.updateLabels()
   }

   CustomButton {
      id: dateResetButton

      anchors.bottom: listLift.top
      x: filterDrawer.x + filterDrawer.width
      z: 9
      height: uiSize
      width: height
      visible: isEnabled
      isEnabled: false
      Image {
         anchors { fill: parent; margins: resetButtonMargins }
         sourceSize { width: parent.width; height: parent.height; } smooth: false
         source: "/Icons/RingedArrowDate.svg"
      }
      onClicked: {
         if ( settings.getDefDateType() === 0 ){
            dateLabel.text = Qt.formatDateTime(currentDate,"d") + ' '
            dateLabel.text+= lang.label(11+Qt.formatDateTime(currentDate, "M")*1)
            payModel.selectDay( Qt.formatDateTime(currentDate, "yyyy")*1,
                               Qt.formatDateTime(currentDate, "M")*1,
                               Qt.formatDateTime(currentDate, "d")*1 )
         } else if ( settings.getDefDateType() === 1 ) {
            dateLabel.text = lang.label(100) + ", " + lang.label(11+Qt.formatDateTime(currentDate, "MM")*1)
            payModel.selectMonth( Qt.formatDateTime(currentDate, "yyyy")*1,
                               Qt.formatDateTime(currentDate, "M")*1 )
         } else if ( settings.getDefDateType() === 2 ) {
            dateLabel.text = lang.label(101) + ", " + Qt.formatDateTime(currentDate, "yyyy")
            payModel.selectDay( Qt.formatDateTime(currentDate, "yyyy")*1 )
         } else if ( settings.getDefDateType() === 3 ) {
            payModel.selectionDateReset()
            dateLabel.text = lang.label(102)
         }
         isEnabled = false
      }
   }


   PayCreation { id: payCreationWindow  }


   FilterDrawer { id: filterDrawer; z:8 }

   LinearGradient {
      anchors { bottom: listLift.top;  left: listLift.left; right: listLift.right; }
      z:3
      height: uiSize / 6
      start: Qt.point( 0, height)
      end:   Qt.point( 0, 0 )
      gradient: Gradient {
         GradientStop { position: 0.0; color: uiShadowColor }
         GradientStop { position: 1; color: "transparent" }
      }
   }
   Rectangle {
      id: listLift

      z:2
      anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
      height: uiSize
      color: uiColor

      Behavior on color { ColorAnimation{ duration: 200; easing.type: Easing.InOutQuad} }

      Item {
         id: filterDrawerButton
         z: 3
         width: uiSize; height: uiSize
         anchors { top: parent.top; left: parent.left; }
         Image {
            anchors { fill: parent; margins: uiSize * uiButtonMarginsFactor }
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/MenuList.svg"
         }
         MouseArea{
            anchors.fill: parent
            onClicked: { filterDrawer.state = "opened"; blockRectangle.state = "opened" }
         }
      }

      Item {
         z: 3
         anchors.centerIn: parent
         width: dateLabel.width + uiSize/2
         height: uiSize
         Rectangle {
            anchors { fill: parent; topMargin: uiSize * uiButtonMarginsFactor; bottomMargin: uiSize * uiButtonMarginsFactor }
            radius: height * 0.5
         }
         Text {
            id: dateLabel
            anchors { centerIn: parent }
            text: {
               if ( settings.getDefDateType() === 0 ){
                  text = Qt.formatDateTime(currentDate,"d") + ' ' + lang.label(11+Qt.formatDateTime(currentDate, "M")*1)
                  payModel.selectDay( Qt.formatDateTime(currentDate,"yyyy")*1,
                                     Qt.formatDateTime(currentDate,"M")*1,
                                     Qt.formatDateTime(currentDate,"d")*1 )
               } else if ( settings.getDefDateType() === 1 ) {
                  text = lang.label(100) + ", " + lang.label(11+Qt.formatDateTime(currentDate, "MM")*1)
                  payModel.selectMonth( Qt.formatDateTime(currentDate,"yyyy")*1,
                                       Qt.formatDateTime(currentDate,"M")*1 )
               } else if ( settings.getDefDateType() === 2 ) {
                  text = lang.label(101) + ", " + Qt.formatDateTime(currentDate, "yyyy")
                  payModel.selectYear( Qt.formatDateTime(currentDate,"yyyy")*1 )
               } else if ( settings.getDefDateType() === 3 ) {
                  payModel.selectAllTime()
                  text = lang.label(102)
               }
            }
            font.pixelSize: uiFontSizeBig
            onTextChanged: {
               font.pixelSize = uiFontSizeBig
               while ( payPage.width - uiSize * 2 > 0 && payPage.width - uiSize * 2 < width ) font.pixelSize--
            }
         }
         MouseArea {
            anchors.fill: parent
            onClicked: { dateSelect.state = "opened"; blockRectangle.state = "opened"; }
         }
      }

      CustomButton {
         id: addButton
         z: 4
         anchors { right: parent.right }
         height: uiSize; width: height
         Rectangle {
            anchors { fill: parent; margins: uiButtonMarginsFactor * parent.width }
            color: "white"
            radius: width * 0.5
            Image{
               fillMode: Image.PreserveAspectFit
               anchors { fill: parent; margins: uiSize / 12 }
               sourceSize { width: parent.width; height: parent.height; }
               source: "/Icons/Plus.svg"
            }
         }
         onClicked: {
            payCreationWindow.state = "opened"
         }
      }
   }

   Loader {
      id: listViewLoader
      anchors { top: parent.top; left: listLift.left; right: listLift.right; bottom: listLift.top }
      z:2
      asynchronous: true
      sourceComponent: PayList{}
   }

   DateSelect {
      id: dateSelect
      onStateChanged: blockRectangle.state = state
      onDateSelected: {
         if ( type == 0 ){
            payModel.selectDateRange( beginYear, beginMonth, beginDay, endYear, endMonth, endDay )
            dateLabel.text = beginDay + " " + lang.label(11+beginMonth)
                  + ( beginYear === Qt.formatDateTime( currentDate, "yyyy")*1 ? '' : ' ' + beginYear )
                  + " - "
                  + endDay + " " + lang.label(11+endMonth) + " "
                  + ( endYear === Qt.formatDateTime( currentDate, "yyyy")*1 ? '' : ' ' + endYear )
         } else {
            if ( type == 1 ){
               payModel.selectDay( beginYear, beginMonth, beginDay )
               dateLabel.text = beginDay + " " + lang.label(11+beginMonth) + " "
                     + ( beginYear === Qt.formatDateTime( currentDate, "yyyy")*1 ? '' : ' ' + beginYear )
            } else if ( type == 2 ){
               payModel.selectMonth( beginYear, beginMonth )
               dateLabel.text = lang.label(11+beginMonth) + " "
                     + ( beginYear === Qt.formatDateTime( currentDate, "yyyy")*1 ? '' : ' ' + beginYear )
            } else if ( type == 3 ){
               payModel.selectYear( beginYear )
               dateLabel.text = beginYear
            } else if ( type == 4 ){
               payModel.selectionDateReset()
               dateLabel.text = lang.label(102)
            }
         }
         dateResetButton.isEnabled = true
      }
   }

   Rectangle {
      z: 7
      id: blockRectangle
      anchors { fill:parent }
      state: "closed"
      MouseArea {
         anchors.fill: parent
         propagateComposedEvents: true
         onClicked: { filterDrawer.state = "closed"; blockRectangle.state = "closed"; dateSelect.state = "closed" }
      }
      states: [
         State { name: "opened"
            PropertyChanges { target: blockRectangle; visible: true; color: "#80000000" }
         },
         State { name: "closed"
            PropertyChanges { target: blockRectangle; color: "transparent"; visible: false }
         }
      ]
      transitions: [
         Transition { from: "closed"; to: "opened"
            SequentialAnimation {
               PropertyAnimation { target: blockRectangle; property: "visible"; duration: 0 }
               PropertyAnimation { target: blockRectangle; property: "color"; duration: 100 }
            }
         },
         Transition { from: "opened"; to: "closed";
            SequentialAnimation {
               PropertyAnimation { target: blockRectangle; property: "color"; duration: 100 }
               PropertyAnimation { target: blockRectangle; property: "visible"; duration: 0 }
            }
         }
      ]
   }
}
