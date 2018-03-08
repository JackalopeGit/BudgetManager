import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import "PayPart"
import "TPayPart"
import "StatsPart"

Window {
   id: window

   property int   dpi: Screen.pixelDensity * 25.4

   property int   uiSize:      dpi < 120 ? 48 : 48*(dpi /160);
   property int   uiWidth:     dpi < 120 ? 320 : dpi * 2
   property int   uiLineWidth: 1

   property int   uiFontSizeBig:   dpi < 120 ? 17 : 17 * (dpi /160);
   property int   uiFontSize:      dpi < 120 ? 14 : 14 * (dpi /160);
   property int   uiFontSizeSmall: dpi < 120 ? 11 : 11 * (dpi /160);

   property color uiColor: settings.getColor()
   property color uiLineColor: "#CCCCCC"
   property color uiShadowColor: "#30000000"

   property color uiIncomeColor: "#008000"
   property color uiExpenceColor: "#f4c542"

   property var   currentDate: new Date()

   property real uiButtonMarginsFactor: 0.20 // margins: uiSize * uiButtonMarginsFactor
   property real colorCheckFactor: 2  //color: Qt.lighter( uiColor , colorCheckFactor ) == "#ffffff" ? "black" : "white"

   visible: true
   width: 320
   height: 426
   title: qsTr("Budget manager")
   color: "white"

   function updateLabels(){
      payListLabel.text = lang.label(1)
      periodicPayListLabel.text = lang.label(2)
      payPage.updateLabels()
   }

   Rectangle{
      id: topPanel
      z:2
      anchors { top: parent.top;  left: parent.left; right: parent.right; }
      height: uiSize
      color: uiColor
      state: "usual"
      Item {
         id: payListSelect
         anchors {left: parent.left; top: parent.top; bottom: parent.bottom; }
         width: uiSize / 2 + payListLabel.width
         Text {
            id: payListLabel
            anchors { centerIn: parent }
            text: lang.label(1)
            font.pixelSize: uiFontSizeBig
            font.hintingPreference: font.hintingPreference
            color: Qt.lighter( uiColor , colorCheckFactor ) == "#ffffff" ? "black" : "white"
         }
         MouseArea {
            anchors.fill: parent
            onClicked: topPanel.state = "usual"
         }
      }

      Rectangle {
         id: selectionLine
         anchors { bottom: parent.bottom; }
         height: uiSize / 12
         color: "white"
      }

      Item {
         id: periodicPayListSelect
         anchors { left: payListSelect.right; top: parent.top; bottom: parent.bottom; }
         width: uiSize / 2 + periodicPayListLabel.width
         Text {
            id: periodicPayListLabel
            anchors { centerIn: parent }
            text: lang.label(2)
            font.pixelSize: uiFontSizeBig
            font.hintingPreference: font.hintingPreference
            color: Qt.lighter( uiColor , colorCheckFactor ) == "#ffffff" ? "black" : "white"
         }
         MouseArea {
            anchors.fill: parent
            onClicked: topPanel.state = "periodic"
         }
      }


      Item {
         id: statsSelect
         anchors { left: periodicPayListSelect.right; top: parent.top; bottom: parent.bottom; }
         width: uiSize * 3 / 2
         Image {
            anchors { centerIn: parent }
            width: uiSize * ( 1 -  2 * uiButtonMarginsFactor); height: width;
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/Stats.svg"
         }
         MouseArea {
            anchors.fill: parent
            onClicked: topPanel.state = "stats"
         }
      }

      Item {
         id: settingsButton
         z: 1
         anchors { right: parent.right; }
         width: uiSize; height: width
         Image {
            anchors { fill: parent; margins: uiButtonMarginsFactor * uiSize }
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/Gear.svg"
         }
         MouseArea {
            anchors { right: parent.right; top: parent.top; }
            width: uiSize; height: width;
            onClicked: settingsDrawer.state == "opened" ?
                          settingsDrawer.state = "closed" : settingsDrawer.state = "opened"
         }
      }

      states: [
         State { name: "usual"
            PropertyChanges { target: selectionLine; x: payListSelect.x; width: payListSelect.width }
            PropertyChanges { target: swipeView; currentIndex: 0 }
         },
         State { name: "periodic"
            PropertyChanges { target: selectionLine; x: periodicPayListSelect.x; width: periodicPayListSelect.width }
            PropertyChanges { target: swipeView; currentIndex: 2 }
         },
         State { name: "stats"
            PropertyChanges { target: selectionLine; x: statsSelect.x; width: statsSelect.width }
            PropertyChanges { target: swipeView; currentIndex: 4 }
         }
      ]
      transitions: [
         Transition { from: "*"; to: "*"
            PropertyAnimation { target: selectionLine; properties: "x,width"; duration: 100 }
         }
      ]
   }
   Item{
      id: kludge
      anchors.fill: parent
   }


   LinearGradient {
      anchors { top: topPanel.bottom;  left: topPanel.left; right: topPanel.right; }
      z:3
      height: uiSize / 6
      start: Qt.point( 0, 0)
      end:   Qt.point( 0, height )
      gradient: Gradient {
         GradientStop { position: 0.0; color: uiShadowColor }
         GradientStop { position: 1; color: "transparent" }
      }
   }

   SwipeView {
      id: swipeView
      anchors { top: topPanel.bottom;  left: parent.left; right: parent.right; bottom: parent.bottom; }
      interactive: false

      PayPage {
         id: payPage
         width: uiWidth * 2 < window.width ? uiWidth : window.width
      }

      Rectangle {
         height: swipeView.height
         width: window.width ? uiSize / 12 : 0
         color: Qt.darker( uiColor )
      }

      TPayPage{
         id: tPayPage
         width: uiWidth * 2 < window.width ? uiWidth : window.width
      }

      Rectangle {
         id: borderRec
         height: swipeView.height
         width: window.width ? uiSize / 12 : 0
         color: Qt.darker( uiColor )
      }

      StatsPage {
         id: statsPage
         width: swipeView.currentIndex != 4 && tPayPage.width < window.width ?
                   window.width - tPayPage.width - borderRec.width : window.width
      }
   }

   SettingsPage {
      id: settingsDrawer;
      onStateChanged: windowBlock.state = state
      onLangChanged: updateLabels()
   }

   CategoryManage { id: categoryManage; }

   CurrencyManage { id: currencyManage; }

   Rectangle {
      z: 7
      id: windowBlock
      width: parent.width
      height: parent.height
      state: "closed"
      MouseArea {
         anchors.fill: parent
         propagateComposedEvents: true
         onClicked: settingsDrawer.state = "closed"
      }
      states: [
         State { name: "opened"
            PropertyChanges { target: windowBlock; visible: true; color: "#50000000" }
         },
         State { name: "closed"
            PropertyChanges { target: windowBlock; color: "transparent"; visible: false }
         }
      ]
      transitions: [
         Transition { from: "closed"; to: "opened"
            SequentialAnimation {
               PropertyAnimation { property: "visible"; duration: 0 }
               PropertyAnimation { property: "color"; duration: 200 }
            }
         },
         Transition { from: "opened"; to: "closed";
            SequentialAnimation {
               PropertyAnimation { property: "color"; duration: 200 }
               PropertyAnimation { property: "visible"; duration: 0 }
            }
         }
      ]
   }
}

