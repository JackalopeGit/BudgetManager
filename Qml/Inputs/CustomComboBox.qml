import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQml.Models 2.3

Item {

   id: area
   z: 5
   width: uiSize * 2
   height: uiSize
   property var modelView
   readonly property int currentIndex: listView.currentIndex
   readonly property string currentText: listView.currentItem ? listView.currentItem.label : " ";
   property int maximumHeight: uiSize * 3

   property bool isLowerOrientation: true

   function setCurrentIndex(index){
      listView.currentIndex = index
   }
   signal itemSelected()

   state: "closed"

   Rectangle {
      id: customComboBox

      anchors { centerIn: parent}
      width: parent.width
      height: uiSize / 3 * 2
      radius: height / 4

      color: "white"
      border.width: uiLineWidth
      border.color: uiColor


      Text {
         id: selectedNameText

         anchors { left: parent.left; right: arrowSquare.left; verticalCenter: parent.verticalCenter; }

         horizontalAlignment:  TextInput.AlignHCenter;
         clip: true
         text: currentText

         font.pixelSize: uiFontSize
      }


      Rectangle {
         id: arrowSquare
         anchors { top: parent.top; right: parent.right;  bottom: parent.bottom; }
         width: height
         color: "transparent"
         border.width: uiLineWidth
         border.color: uiColor
         radius: height / 4
         Image {
            id: arrowImage
            anchors { fill: parent; margins: uiSize / 6 }
            width: height; sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/Arrow.svg"
            Behavior on rotation { NumberAnimation{ duration: 100; easing.type: Easing.InOutQuad} }
         }
      }


      Rectangle {
         id: listViewArea
         anchors {
            top: area.isLowerOrientation ? parent.bottom : undefined;
            bottom: area.isLowerOrientation ?  undefined : parent.top
            left: parent.left;
            right: parent.right;
            rightMargin: parent.height - 1
         }
         color: "white"
         border.width: uiLineWidth
         border.color: uiColor
         clip: true
         radius: customComboBox.radius

         ListView {
            id: listView
            anchors { fill: parent; }
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            currentIndex: 0
            model: modelView
            delegate: Item {
               id: listDelegate
               width: listView.width
               height: uiSize
               property string label: text.text
               Text {
                  id: text
                  anchors { centerIn: parent }
                  text: name
                  font.pixelSize: uiFontSize
               }
               MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  onEntered: text.color = uiColor
                  onExited: text.color = "black"
                  onClicked: {
                     listView.currentIndex = index
                     selectedNameText.text = name
                     area.state = "closed"
                     itemSelected()
                  }
               }
            }

            ScrollBar.vertical: ScrollBar{}
         }
         Behavior on height { NumberAnimation{ duration: 150; easing.type: Easing.InOutQuad} }
      }
   }
   MouseArea {
      anchors.fill: parent
      onClicked: parent.state == "closed" ? parent.state = "opened" : parent.state = "closed"
   }

   states: [
      State {
         name: "opened"
         PropertyChanges { target: listViewArea
            height: listView.contentHeight + customComboBox.height > maximumHeight ?
                       maximumHeight - customComboBox.height - (uiSize  - customComboBox.height) / 2
                     : listView.contentHeight
         }
         PropertyChanges { target: arrowImage
            rotation: isLowerOrientation ? 0 : 180
         }
      },
      State {
         name: "closed"
         PropertyChanges { target: listViewArea
            height: 0
         }
         PropertyChanges { target: arrowImage
            rotation: isLowerOrientation ? 180 : 0
         }
      }
   ]
}
