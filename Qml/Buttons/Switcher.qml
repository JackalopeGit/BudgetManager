import QtQuick 2.0

Item {
   height: uiSize
   width: uiSize

   property bool isSelected: false
   Rectangle {
      anchors.centerIn: parent
      height: uiSize / 24 * 7
      width: uiSize / 48 * 28
      radius: height / 2
      color: isSelected ? Qt.lighter( uiColor, 1.5 ) : "#CCCCCC"
      Rectangle {
         height: uiSize / 48 * 18
         width: height
         radius: height / 2
         x: isSelected ? parent.width - parent.radius - radius : y
         y: parent.radius - radius
         color: isSelected ? uiColor : "#4D4D4D"
         Behavior on color { ColorAnimation{ duration: 50; easing.type: Easing.InOutQuad} }
         Behavior on x { NumberAnimation { easing.type: Easing.InCirc; duration: 50; } }
      }
      Behavior on color { ColorAnimation{ duration: 50; easing.type: Easing.InOutQuad} }
   }
   MouseArea {
      anchors.fill: parent
      onClicked: isSelected = !isSelected
   }
}
