import QtQuick 2.0

import "qrc:/Qml/Buttons"

Rectangle {
   id: catgoryInput
   anchors.centerIn: parent
   width: uiSize * 4
   height: categoryView.contentHeight > uiSize * 5.5 ? uiSize * 6.5 : categoryView.contentHeight + uiSize
   state: "closed"
   enabled: visible
   z: 12

   signal categorySelected( var index )

   Item {
      id: panel
      width: parent.width
      height: uiSize
      Text {
         anchors { verticalCenter: parent.verticalCenter }
         x: uiSize / 6
         text: lang.label( 11 )
         font.pixelSize: uiFontSizeBig
      }
      CustomButton2 {
         anchors { right: parent.right; top: parent.top; }
         height: uiSize; width: uiSize * 3 / 2
         Rectangle {
            height: parent.height
            width: uiLineWidth
            color: "#CCCCCC"
         }
         Image {
            anchors.horizontalCenter: parent.horizontalCenter
            y: uiSize / 8
            height: uiSize / 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/CategoryGear.svg"
         }
         Text {
            y: uiSize / 8 * 5
            anchors.horizontalCenter: parent.horizontalCenter
            text: lang.label( 74 )
            font.pixelSize: uiFontSizeSmall
         }
         onClicked: categoryManage.state = "opened"
      }
      Rectangle {
         y: uiSize - uiLineWidth
         height: uiLineWidth
         width: parent.width
         color: "#CCCCCC"
      }
   }

   ListView {
      id: categoryView
      anchors { left: parent.left; right: parent.right; top: panel.bottom; bottom: parent.bottom }
      clip: true
      model: categoryModel

      boundsBehavior: Flickable.StopAtBounds
      delegate: Rectangle {
         id: delegate
         height: uiSize
         width: categoryInput.width
         color: categoryColor
         CustomButton2 {
            anchors.fill: parent
            Text {
               anchors.verticalCenter: parent.verticalCenter
               x: uiSize / 6
               text: name
               color: Qt.lighter( delegate.color , colorCheckFactor ) == "#ffffff" ? "black" : "white"
               font.pixelSize: uiFontSize
            }
            onClicked: { categorySelected(index); categoryInput.state = "closed" }
         }
      }
   }
   MouseArea { z: -1;  anchors.fill: parent; onClicked: mouse.accepted = true }

   states: [
      State { name: "opened"
         PropertyChanges { target: catgoryInput; visible: true;  opacity: 1; scale: 1 }
      },
      State { name: "closed"
         PropertyChanges { target: catgoryInput; visible: false; opacity: 0;  scale: 0.8 }
      }
   ]
   transitions: [
      Transition { from: "closed"; to: "opened"
         SequentialAnimation {
            PropertyAnimation { properties: "visible"; duration: 0 }
            ParallelAnimation {
               PropertyAnimation { property: "opacity"; duration: 50 }
               PropertyAnimation { property: "scale";   duration: 50 }
            }
         }
      },
      Transition { from: "opened"; to: "closed"
         SequentialAnimation {
            ParallelAnimation {
               PropertyAnimation { property: "opacity"; duration: 50 }
               PropertyAnimation { property: "scale";   duration: 50 }
            }
            PropertyAnimation { properties: "visible"; duration: 0 }
         }
      }
   ]
}
