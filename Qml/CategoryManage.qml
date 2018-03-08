import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import "qrc:/Qml/Buttons"


Rectangle {
   id: editableList

   z: 10

   state: "closed"
   enabled: visible

   anchors.fill: parent

   property int maxNameLength: 36
   property int spacing: uiSize * 0.3

   Item {
      id: labelRow
      anchors { top: parent.top; left: parent.left; right: parent.right; }
      height: uiSize

      Image {
         id: canselButton
         anchors { top: parent.top; left: parent.left; bottom: parent.bottom; margins: uiSize / 4 }
         width: height; sourceSize { width: parent.width; height: parent.height; } smooth: false
         source: "/Icons/Back.svg"
      }
      MouseArea {
         anchors { top: parent.top; left: parent.left; bottom: parent.bottom; }
         width: height
         onClicked: {
            editableList.state = "closed"
         }
      }
      Text {
         id: labelText
         anchors.centerIn: parent
         text: lang.label( 92 )
         font.pixelSize: uiFontSize
      }
      Image {
         id: addButton
         anchors { top: parent.top; right: parent.right;  margins: uiSize / 4 }
         height: uiSize / 2; width: height;
         sourceSize { width: parent.width; height: parent.height; } smooth: false
         source: "/Icons/Plus.svg"
      }
      MouseArea {
         anchors { top: parent.top; right: parent.right; bottom: parent.bottom; }
         width: height
         onClicked: {
            stringCreator.index = categoryModel.rowCount()
            newStringInput.focus = true
            Qt.inputMethod.show();
            stringCreator.state = "opened"
         }
      }
   }
   Rectangle {
      anchors { left: parent.left; right: parent.right; bottom: labelRow.bottom }
      height: uiLineWidth
      color: "#CCCCCC"
   }

   LinearGradient {
      anchors { top: labelRow.bottom;  left: parent.left; right: parent.right; }
      z:4
      height: uiSize * 0.1
      start: Qt.point(0, 0)
      end:  Qt.point(0, uiSize * 0.1)
      gradient: Gradient {
         GradientStop { position: 0.0; color: "#aaaaaa" }
         GradientStop { position: 1; color: "transparent" }
      }
   }



   Flickable {
      anchors { top: labelRow.bottom;  left: parent.left; right: parent.right; bottom: parent.bottom; }
      contentWidth: parent.width;
      contentHeight: list.height
      clip: true
      boundsBehavior: Flickable.StopAtBounds

      Item {
         id: list
         width: parent.width
         height: listView.height < parent.parent.parent.parent.height ? parent.parent.parent.parent.height - uiSize : listView.height

         ListView {
            id: listView
            anchors { top: parent.top; left: parent.left; right: parent.right; }
            clip: true
            focus: true
            height: contentHeight

            ScrollBar.vertical: ScrollBar{ size: 1 }

            boundsBehavior: Flickable.StopAtBounds
            model: categoryModel
            delegate: Component {
               CustomButton2 {
                  id: itemComponent
                  implicitWidth: listView.width
                  height: index == 0 ? 0 : uiSize
                  clip: true
                  color: categoryColor
                  Text {

                     anchors { verticalCenter: parent.verticalCenter; left: parent.left; right: parent.right; margins: spacing }
                     text: name
                     horizontalAlignment: TextInput.AlignLeft
                     clip: true
                     font.pixelSize: uiFontSize
                     color: Qt.lighter( parent.color , colorCheckFactor ) == "#ffffff" ? "black" : "white"
                  }
                  Rectangle {
                     id: borderLine
                     anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; }
                     color: uiLineColor
                     implicitWidth: parent.width;
                     implicitHeight: uiLineWidth
                  }
                  onClicked: {
                     stringEdit.name = name
                     stringEdit.index = index
                     stringEdit.state = "opened"
                     textInput.focus = true
                     Qt.inputMethod.show();
                  }
               }
            }
            remove: Transition {
               ParallelAnimation {
                  NumberAnimation { property: "opacity"; to: 0; duration: 100 }
                  NumberAnimation { properties: "x"; to: 100; duration: 100 }
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

   Rectangle {
      id: stringCreator
      anchors.centerIn: parent
      width: dpi < 120 ? 320 : dpi * 2;
      height: uiSize * 3.6
      state: "closed"
      onStateChanged: block.state = state
      z: 12
      property int index: categoryModel.rowCount()
      Text {
         anchors.horizontalCenter: parent.horizontalCenter
         y: uiSize / 4
         text: lang.label( 96 )
         font.pixelSize: uiFontSizeBig
      }
      Rectangle {
         y: uiSize
         height: uiLineWidth
         width: parent.width
         color: "#CCCCCC"
      }

      TextInput {
         id: newStringInput
         anchors { centerIn: parent }
         horizontalAlignment: TextInput.AlignHCenter
         verticalAlignment: TextInput.AlignVCenter
         height: uiSize
         width: parent.width - uiSize / 4
         clip: true
         maximumLength: maxNameLength
         font.pixelSize: uiFontSizeBig
         wrapMode: TextInput.WrapAtWordBoundaryOrAnywhere
      }
      Rectangle {
         anchors { left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: uiSize }
         height: uiLineWidth
         color: "#CCCCCC"
      }
      CustomButton2 {
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
         anchors { bottom: parent.bottom; right: parent.right; }
         width: parent.width / 2
         height: uiSize
         Text {
            anchors { centerIn: parent }
            text: lang.label( 30 )
            font.pixelSize: uiFontSize
         }
         onClicked: {
            if ( newStringInput.text.length ){
               categoryModel.addCategory( newStringInput.text, Qt.rgba(Math.random(),Math.random(),Math.random(),1) )
               parent.state = "closed"
               Qt.inputMethod.hide();
               newStringInput.text = ""
            } else {
               newStringInput.text = lang.label( 11 ) + stringCreator.index
            }
         }
      }

      states: [
         State { name: "opened"
            PropertyChanges { target: stringCreator; visible: true;  opacity: 1; scale: 1 }
         },
         State { name: "closed"
            PropertyChanges { target: stringCreator; visible: false; opacity: 0;  scale: 0.8 }
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
   Rectangle {
      id: stringEdit
      anchors.centerIn: parent
      width: dpi < 120 ? 320 : dpi * 2;
      height: uiSize * 3.6
      state: "closed"
      onStateChanged: block.state = state
      z: 12
      property string name: ""
      property int index
      Text {
         x: uiSize / 3
         y: uiSize / 4
         text: stringEdit.name
         font.pixelSize: uiFontSizeBig
      }
      CustomButton2 {
         anchors { right: parent.right; top: parent.top; }
         height: uiSize; width: height
         Image {
            anchors { fill: parent; margins: uiSize / 6 }
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/Trash.svg"
         }
         onClicked: {
            stringEdit.state = "closed"
            Qt.inputMethod.hide();
            categoryModel.removeCategory( stringEdit.index )
         }
      }
      Rectangle {
         anchors { right: parent.right; margins: uiSize - uiLineWidth }
         height: uiSize
         width: uiLineWidth
         color: "#CCCCCC"
      }
      Rectangle {
         y: uiSize
         height: uiLineWidth
         width: parent.width
         color: "#CCCCCC"
      }

      TextInput {
         id: textInput

         anchors { centerIn: parent }
         horizontalAlignment: TextInput.AlignHCenter
         verticalAlignment: TextInput.AlignVCenter
         height: uiSize
         width: parent.width - uiSize / 4
         text: stringEdit.name
         clip: true
         maximumLength: maxNameLength
         font.pixelSize: uiFontSizeBig
         wrapMode: TextInput.WrapAtWordBoundaryOrAnywhere
      }

      Rectangle {
         anchors { left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: uiSize }
         height: uiLineWidth
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
            parent.state = "closed"
            Qt.inputMethod.hide();
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
         id: renameButton
         anchors { bottom: parent.bottom; right: parent.right; }
         width: parent.width / 2
         height: uiSize
         Text {
            anchors { centerIn: parent }
            text: lang.label( 94 )
            font.pixelSize: uiFontSize
         }
         onClicked: {
            if ( textInput.text.length ){
               categoryModel.set(stringEdit.index, textInput.text, Qt.rgba(Math.random(),Math.random(),Math.random(),1))
               parent.state = "closed"
               Qt.inputMethod.hide();
            } else {
               textInput.text = lang.label( 11 ) + stringEdit.index
            }
         }
      }

      states: [
         State { name: "opened"
            PropertyChanges { target: stringEdit; visible: true;  opacity: 1; scale: 1 }
         },
         State { name: "closed"
            PropertyChanges { target: stringEdit; visible: false; opacity: 0;  scale: 0.8 }
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

   Rectangle {
      z: 7
      id: block
      width: parent.width
      height: parent.height
      state: "closed"
      MouseArea {
         anchors.fill: parent
         propagateComposedEvents: true
         onClicked: mouse.acepted = true
      }
      states: [
         State { name: "opened"
            PropertyChanges { target: block; visible: true; color: "#50000000" }
         },
         State { name: "closed"
            PropertyChanges { target: block; color: "transparent"; visible: false }
         }
      ]
      transitions: [
         Transition { from: "closed"; to: "opened"
            SequentialAnimation {
               PropertyAnimation { property: "visible"; duration: 0 }
               PropertyAnimation { property: "color";   duration: 200 }
            }
         },
         Transition { from: "opened"; to: "closed";
            SequentialAnimation {
               PropertyAnimation { property: "color";   duration: 200 }
               PropertyAnimation { property: "visible"; duration: 0 }
            }
         }
      ]
   }

   MouseArea { z: -1;  anchors.fill: parent; onClicked: mouse.accepted = true }

   states: [
      State {
         name: "closed"
         PropertyChanges {
            target: editableList
            opacity: 0
            visible: false
         }
      },
      State { name: "opened"
         PropertyChanges {
            target: editableList
            opacity: 1
            visible: true
         }
      }
   ]
   transitions: [
      Transition { from: "closed"; to: "opened"
         SequentialAnimation {
            PropertyAnimation { properties: "visible"; duration: 0 }
            PropertyAnimation { properties: "opacity"; duration: 100 }
         }
      },
      Transition { from: "opened"; to: "closed"
         SequentialAnimation {
            PropertyAnimation { properties: "opacity"; duration: 100 }
            PropertyAnimation { properties: "visible"; duration: 0 }
         }
      }
   ]
}


