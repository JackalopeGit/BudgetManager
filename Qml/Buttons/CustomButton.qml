import QtQuick 2.0
import QtQuick.Controls 2.2

Item {
   id: button

   property bool isEnabled: true
   signal clicked

   enabled: isEnabled
   scale: state === "Pressed" ? 0.90 : 1.0
   Behavior on scale { NumberAnimation{ duration: 100; easing.type: Easing.InOutQuad} }

   MouseArea {
      propagateComposedEvents: !parent.isEnabled
      anchors.fill: button
      hoverEnabled: true
      onClicked:  if ( isEnabled ) button.clicked()
                  else mouse.accepted = false
      onPressed:  if ( isEnabled ) button.state = "Pressed"
      onExited:   if ( isEnabled ) button.state = "";
      onReleased: if (isEnabled ) button.state = "";
   }
}
