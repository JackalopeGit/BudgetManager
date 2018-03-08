import QtQuick 2.9
import QtGraphicalEffects 1.0

import "qrc:/Qml/Buttons"

Rectangle {
   id: tPayPage
   color: "white"

   TPayCreation { id: tPayCreationWindow  }

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

      state: "all"

      Behavior on color { ColorAnimation{ duration: 200; easing.type: Easing.InOutQuad} }

      readonly property int freeSpace: width
                                       - allSelect.width - incomeSelect.width - consumptionSelect.width
                                       - addPositiveButton.width

      Item {
         id: allSelect
         anchors {
            top: parent.top; left: parent.left; bottom: parent.bottom;
            bottomMargin: uiSize * 0.25;
            leftMargin: listLift.freeSpace / 4
         }
         width: allText.width + uiSize * 0.25 > uiSize ? allText.width + uiSize * 0.25 : uiSize
         property bool isEnabled
         property color current: uiColor
         Rectangle {
            id: allRec
            anchors { fill: parent }
            height: uiSize * 0.75
            color: parent.isEnabled ? parent.current : "white"
            radius: uiSize * 0.25
            border { color: !parent.isEnabled ? uiColor : "white"; width: uiLineWidth }
            Behavior on color { ColorAnimation{ duration: 100; easing.type: Easing.InOutQuad} }
         }
         Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right; }
            height: uiSize * 0.5
            color: !parent.isEnabled ? uiColor : "white"
            Rectangle {
               anchors { fill: parent; leftMargin: uiLineWidth; rightMargin: uiLineWidth }
               height: uiSize * 0.5
               color: parent.parent.isEnabled ?  parent.parent.current : "white"
               Behavior on color { ColorAnimation{ duration: 100; easing.type: Easing.InOutQuad} }
            }
         }
         Text {
            id: allText
            anchors { centerIn: parent }
            text: lang.label( 38 )
            color: Qt.lighter( allRec.color, colorCheckFactor ) == "#ffffff" ? "black" : "white"
            font.pixelSize: uiFontSizeBig
         }
      }
      MouseArea {
         anchors { top: parent.top;  left: allSelect.left; right: allSelect.right; bottom: parent.bottom; }
         hoverEnabled: true
         onEntered: if ( allSelect.isEnabled ) allSelect.current = Qt.lighter( uiColor )
         onExited: allSelect.current = uiColor
         onClicked: {
            tPayModel.selectSumSignReset()
            listLift.state = "all"
         }
      }

      Item {
         id: incomeSelect
         anchors {
            top: parent.top; left: allSelect.right; bottom: parent.bottom;
            bottomMargin: uiSize * 0.25; leftMargin: listLift.freeSpace / 4
         }
         width: incomeText.width + uiSize * 0.25
         property bool isEnabled
         property color current: uiColor
         Rectangle {
            id: incomeRec
            anchors { fill: parent }
            height: uiSize * 0.75
            color: parent.isEnabled ? parent.current : "white"
            radius: uiSize * 0.25
            border { color: !parent.isEnabled ? uiColor : "white"; width: uiLineWidth }
            Behavior on color { ColorAnimation{ duration: 100; easing.type: Easing.InOutQuad} }
         }
         Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right; }
            height: uiSize * 0.5
            color: !parent.isEnabled ? uiColor : "white"
            Rectangle {
               anchors { fill: parent; leftMargin: uiLineWidth; rightMargin: uiLineWidth }
               height: uiSize * 0.5
               color: parent.parent.isEnabled ?  parent.parent.current : "white"
               Behavior on color { ColorAnimation{ duration: 100; easing.type: Easing.InOutQuad} }
            }
         }
         Text {
            id: incomeText
            anchors { centerIn: parent }
            text: lang.label( 36 )
            color: Qt.lighter( incomeRec.color, colorCheckFactor ) == "#ffffff" ? "black" : "white"
            font.pixelSize: uiFontSizeBig
         }
      }
      MouseArea {
         anchors { top: parent.top;  left: incomeSelect.left; right: incomeSelect.right; bottom: parent.bottom; }
         hoverEnabled: true
         onEntered: if ( incomeSelect.isEnabled ) incomeSelect.current = Qt.lighter( uiColor )
         onExited: incomeSelect.current = uiColor
         onClicked: {
            tPayModel.selectSumSign( true )
            listLift.state = "income"
         }
      }

      Item {
         id: consumptionSelect
         anchors {
            top: parent.top; left: incomeSelect.right; bottom: parent.bottom;
            bottomMargin: uiSize * 0.25; leftMargin: listLift.freeSpace / 4
         }
         width: consumptionText.width + uiSize * 0.25
         property bool isEnabled
         property color current: uiColor
         Rectangle {
            id: consumptionRec
            anchors { fill: parent }
            height: uiSize * 0.75
            color: parent.isEnabled ? parent.current : "white"
            radius: uiSize * 0.25
            border { color: !parent.isEnabled ? uiColor : "white"; width: uiLineWidth }
            Behavior on color { ColorAnimation{ duration: 100; easing.type: Easing.InOutQuad} }
         }
         Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right; }
            height: uiSize * 0.5
            color: !parent.isEnabled ? uiColor : "white"
            Rectangle {
               anchors { fill: parent; leftMargin: uiLineWidth; rightMargin: uiLineWidth }
               height: uiSize * 0.5
               color: parent.parent.isEnabled ?  parent.parent.current : "white"
               Behavior on color { ColorAnimation{ duration: 100; easing.type: Easing.InOutQuad} }
            }
         }
         Text {
            id: consumptionText
            anchors { centerIn: parent }
            text: lang.label( 37 )
            color: Qt.lighter( consumptionRec.color, colorCheckFactor ) == "#ffffff" ? "black" : "white"
            font.pixelSize: uiFontSizeBig
         }
      }
      MouseArea {
         anchors { top: parent.top;  left: consumptionSelect.left; right: consumptionSelect.right; bottom: parent.bottom; }
         hoverEnabled: true
         onEntered: if ( consumptionSelect.isEnabled ) consumptionSelect.current = Qt.lighter( uiColor )
         onExited: consumptionSelect.current = uiColor
         onClicked: {
            tPayModel.selectSumSign( false )
            listLift.state = "consumption"
         }
      }

      states: [
         State { name: "all"
            PropertyChanges { target: allSelect;         isEnabled: false }
            PropertyChanges { target: incomeSelect;      isEnabled: true }
            PropertyChanges { target: consumptionSelect; isEnabled: true }
         },
         State { name: "income"
            PropertyChanges { target: allSelect;         isEnabled: true }
            PropertyChanges { target: incomeSelect;      isEnabled: false }
            PropertyChanges { target: consumptionSelect; isEnabled: true }
         },
         State { name: "consumption"
            PropertyChanges { target: allSelect;         isEnabled: true }
            PropertyChanges { target: incomeSelect;      isEnabled: true }
            PropertyChanges { target: consumptionSelect; isEnabled: false }
         }
      ]

      CustomButton {
         id: addPositiveButton
         z: 4
         anchors { right: parent.right; }
         height: uiSize
         width: height
         Rectangle {
            anchors { fill: parent; margins: uiButtonMarginsFactor * parent.width }
            color: "white"
            radius: width * 0.5
            Image{
               anchors { fill: parent; margins: uiSize / 12 }
               width: height; sourceSize { width: parent.width; height: parent.height; } smooth: false
               source: "/Icons/Plus.svg"
            }
         }
         onClicked: {
            tPayCreationWindow.state = "opened"
         }
      }
   }


   LinearGradient {
      anchors { top: listLift.bottom;  left: listLift.left; right: listLift.right; }
      z:3
      height: uiSize * 0.1
      start: Qt.point(0, 0)
      end:  Qt.point(0, uiSize * 0.1)
      gradient: Gradient {
         GradientStop { position: 0.0; color: "#C6C6C6" }
         GradientStop { position: 1; color: "transparent" }
      }
   }

   Loader {
      id: listViewLoader
      anchors { top: parent.top; left: listLift.left; right: listLift.right; bottom: listLift.top }
      z:2
      asynchronous: true
      sourceComponent: TPayList{}
   }

   Rectangle {
      z: 7
      id: blockRectangle
      width: window.width
      height: window.height
      state: "closed"
      MouseArea {
         anchors.fill: parent
         propagateComposedEvents: true
         onClicked: { blockRectangle.state = "closed"; }
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
