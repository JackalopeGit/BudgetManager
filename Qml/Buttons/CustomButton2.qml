import QtQuick 2.0

Rectangle {
   id: button

   property bool isEnabled: true
   property int radius: 0
   signal clicked

   color: "transparent"
   clip: true
   Rectangle {
      id: rectangle
      anchors.fill: parent
      opacity: 0
      radius: button.radius
      color: "#20000000"
   }
   SequentialAnimation { id: hoverAnimation;
      PropertyAnimation { target: rectangle; property: "opacity"; easing.type: Easing.OutExpo; to: 1; duration: 1000 }
      PropertyAnimation { target: rectangle; property: "opacity"; to: 0; duration: 300 * opacity }
   }
   Rectangle {
      id: round
      width: 0
      height: width
      radius: width / 2
      color: "#20000000"
   }

   SequentialAnimation {
      id: clickedAnimation;
      PropertyAnimation {  target: round; property: "opacity"; to: 1; duration: 0; }
      PropertyAnimation {  target: round; property: "width"; to: 0; duration: 0 }
      ParallelAnimation {
         PropertyAnimation {  target: round; property: "width"; easing.type: Easing.Linear; from: 0;       to: uiSize * 4 ; duration: 4 * 48 }
         PropertyAnimation {  target: round; property: "x";     easing.type: Easing.Linear; from: round.x; to: round.x - uiSize * 2; duration: 4 * 48 }
         PropertyAnimation {  target: round; property: "y";     easing.type: Easing.Linear; from: round.y; to: round.y - uiSize * 2; duration: 4 * 48 }
         PropertyAnimation {  target: round; property: "opacity"; easing.type: Easing.InCubic; to: 0; duration: 4 * 48 ; }
      }
      PropertyAnimation {  target: round; property: "width"; to: 0;           duration: 0 }
   }
   PropertyAnimation { id: afterHoverAnimation;  target: rectangle; property: "opacity"; to: 0; duration: 300 * opacity }

   MouseArea {
      propagateComposedEvents: !parent.isEnabled
      anchors.fill: button
      hoverEnabled: true
      onClicked:  if ( isEnabled ) {
                     button.clicked();
                     clickedAnimation.stop();
                     round.x = mouseX;
                     round.y = mouseY;
                     clickedAnimation.start();
                  }
                  else mouse.accepted = false
      onPressed:  if ( isEnabled ) { hoverAnimation.start();   }
      onExited:   if ( isEnabled ) {
                     if ( !clickedAnimation.running && rectangle.opacity ) {
                        round.x = mouseX; round.y = mouseY;
                        clickedAnimation.start();
                     }
                     hoverAnimation.stop();
                     afterHoverAnimation.start() }
      onReleased: if ( isEnabled ) {
                     hoverAnimation.stop();
                     afterHoverAnimation.start()
                  }
   }
}
