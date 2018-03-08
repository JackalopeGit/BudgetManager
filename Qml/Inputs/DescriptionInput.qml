import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/Qml/Buttons"

Rectangle {
   id: descriptionInput

   anchors.centerIn: parent
   height: uiSize * 4
   width: dpi < 120 ? 320 : dpi * 2;

   enabled: visible
   z: 12

   state: "closed"

   readonly property string description: descriptionTextEdit.text
   signal descriptionEdited()

   function setText( text ){ descriptionTextEdit.text = text }

   onStateChanged: if (state == "opened") Qt.inputMethod.show
   Item {
      id: descriptionInputPanel
      width: parent.width; height: uiSize
      Text {
         anchors.verticalCenter: parent.verticalCenter
         x: uiSize / 3
         text: lang.label( 24 )
         font.pixelSize: uiFontSizeBig
      }
      Image {
         anchors { right: parent.right; top: parent.top; margins: uiSize / 6 }
         height: uiSize / 3 * 2; width: height
         sourceSize { width: parent.width; height: parent.height; } smooth: false
         source: "/Icons/Pencil.svg"
      }
      Rectangle {
         anchors.bottom: parent.bottom
         height: uiLineWidth
         width: parent.width
         color: "#CCCCCC"
      }
   }

   Flickable {
      anchors { fill: parent;
         topMargin: uiSize + uiSize / 8; bottomMargin: uiSize + uiSize / 8;
         leftMargin: uiSize / 8; rightMargin: uiSize / 8
      }
      boundsBehavior: Flickable.StopAtBounds
      contentWidth: descriptionTextEdit.width;
      contentHeight: descriptionTextEdit.height

      clip: true

      TextArea {
         id: descriptionTextEdit
         wrapMode: "WrapAtWordBoundaryOrAnywhere"
         horizontalAlignment:  TextInput.AlignHCenter
         width: descriptionInput.width - uiSize / 4
         height: contentHeight < uiSize + font.pixelSize ? uiSize + font.pixelSize : contentHeight + font.pixelSize
         font.pixelSize: uiFontSize
         color: "black"
         Text {
            anchors { centerIn: parent }
            text: lang.label( 8 )
            color: "#aaa"
            font.pixelSize: parent.font.pixelSize
            visible: !parent.text && !parent.focus
         }
      }
   }

   Rectangle {
      anchors { bottom: parent.bottom; bottomMargin: uiSize-1 }
      height: uiLineWidth; width: parent.width
      color: "#CCCCCC"
   }
   CustomButton2 {
      id: cancelButton
      anchors { bottom: parent.bottom; left: parent.left; }
      width: parent.width / 2
      height: uiSize
      Text {
         anchors { centerIn: parent }
         text: lang.label( 31 )
         font.pixelSize: uiFontSize
      }
      onClicked: {
         Qt.inputMethod.hide();
         parent.state = "closed"
      }
   }

   Rectangle {
      anchors { bottom: parent.bottom; }
      x: parent.width / 2
      height: uiSize
      width: uiLineWidth
      color: "#CCCCCC"
   }


   CustomButton2 {
      id: okButton
      anchors { bottom: parent.bottom; right: parent.right; }
      width: parent.width / 2
      height: uiSize
      Text {
         anchors { centerIn: parent }
         text: lang.label( 9 )
         font.pixelSize: uiFontSize
      }
      onClicked: {
         Qt.inputMethod.hide();
         parent.state = "closed"
         descriptionEdited()
      }
   }
   states: [
      State { name: "opened"
         PropertyChanges { target: descriptionInput; visible: true;  opacity: 1; scale: 1 }
      },
      State { name: "closed"
         PropertyChanges { target: descriptionInput; visible: false; opacity: 0;  scale: 0.8 }
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
