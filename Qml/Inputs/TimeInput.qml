import QtQuick 2.7

import "qrc:/Qml/Buttons"

Item {
   id: timeInput

   readonly property string selectedHour: hourInput.text
   readonly property string selectedMinute: minuteInput.text

   function setTime ( hour, minute ){
      hourInput.text = hour
      minuteInput.text = minute
   }
   signal timeSelected


   anchors { centerIn: parent }
   z:12
   height: mainCircle.height + uiSize

   state: "closed"
   enabled: visible

   Rectangle {
      id: leftPanel
      anchors { left: mainCircle.left; bottom: mainCircle.bottom; leftMargin: uiSize / 48 * 18 }
      width: uiSize
      height: uiSize * 2
      radius: uiSize / 4
      color: uiColor
   }

   Rectangle {
      id: rightPanel
      anchors { right: mainCircle.right; bottom: mainCircle.bottom; rightMargin: uiSize / 48 * 18 }
      width: uiSize
      height: uiSize * 2
      radius: uiSize / 4
      color: uiColor
   }

   CustomButton {
      id: canselButton
      anchors { left: leftPanel.left; right: leftPanel.right; bottom: leftPanel.bottom; }
      z: 3
      height: width
      Rectangle {
         anchors { fill: parent; margins: uiSize / 8 }
         color: "white"
         radius: width / 2
         Image {
            anchors.centerIn: parent
            width: uiSize / 2; height: width
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/X.svg"
         }
      }
      onClicked: timeInput.state = "closed"
   }

   CustomButton {
      id: okButton
      anchors { left: rightPanel.left; right: rightPanel.right; bottom: rightPanel.bottom; }
      z: 3
      height: width
      Rectangle {
         anchors { fill: parent; margins: uiSize / 8 }
         color: "white"
         radius: width / 2
         Image {
            anchors.centerIn: parent
            width: uiSize / 2; height: width
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/CheckMark.svg"
         }
      }
      onClicked: {
         timeSelected()
         timeInput.state = "closed"
      }
   }
   Rectangle {
      id: mainCircle
      anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
      width: dpi < 120 ? 308 : dpi * 308 / 160 ;
      height: width
      border { width: uiSize / 6; color: uiColor }
      radius: width / 2

      Rectangle {
         id: innerCircle
         anchors { fill: parent; margins: parent.border.width }
         state: "hour"
         radius: width / 2
         MouseArea {
            id: pressCounter
            property int centre: width / 2
            property int secondWidth: width - uiSize * 2
            property int thirdWidth: width - uiSize * 4
            anchors.fill: parent
            hoverEnabled: true
            function updateHour(){
               if ( pressed ){
                  var power = Math.pow( mouseX - centre, 2) + Math.pow( mouseY - centre, 2)
                  if ( power >= Math.pow( thirdWidth / 2, 2 ) ) {
                     if ( power < Math.pow( secondWidth / 2, 2 ) ){
                        var degree = ((mouseX - centre == 0)
                                      ? ( ( mouseY - centre > 0) ? 180 : 0 )
                                      : ( mouseX - centre > 0 ) ?
                                           (Math.atan( (mouseY - centre) / (mouseX - centre) ) * 180 / Math.PI) + 90
                                         : (Math.atan( (mouseY - centre) / (mouseX - centre) ) * 180 / Math.PI) + 270) + 15
                        hourInput.text = parseInt( degree <= 360 ? degree / 30 + 12 : 12 );
                     } else
                        if ( power < Math.pow( Math.min( width, height ) / 2, 2 ) ){
                           var degree = ((mouseX - centre == 0)
                                         ? ( ( mouseY - centre > 0) ? 180 : 0 )
                                         : ( mouseX - centre > 0 ) ?
                                              (Math.atan( (mouseY - centre) / (mouseX - centre) ) * 180 / Math.PI) + 90
                                            : (Math.atan( (mouseY - centre) / (mouseX - centre) ) * 180 / Math.PI) + 270) + 15
                           hourInput.text = parseInt( degree <= 360 ? degree / 30 : 0 );
                        }
                  }
               }
            }
            function updateMinute(){
               if ( pressed ){
                  var power = Math.pow( mouseX - centre, 2) + Math.pow( mouseY - centre, 2)
                  if ( power >= Math.pow( minutePath.radius - uiSize, 2 ) ) {
                     if ( power <  Math.pow( minutePath.radius + uiSize, 2 ) ) {
                        var degree = ((mouseX - centre == 0)
                                      ? ( ( mouseY - centre > 0) ? 180 : 0 )
                                      : ( mouseX - centre > 0 ) ?
                                           (Math.atan( (mouseY - centre) / (mouseX - centre) ) * 180 / Math.PI) + 90
                                         : (Math.atan( (mouseY - centre) / (mouseX - centre) ) * 180 / Math.PI) + 270) + 3
                        minuteInput.text = parseInt( degree <= 360 ? degree / 6 : 0 );
                     }
                  }
               }
            }
            onReleased: innerCircle.state == "hour" ? innerCircle.state = "minute" : innerCircle.state = "hour";
         }
         PathView {
            id: hourVisualCircle
            anchors { fill: parent; }
            model: 12
            interactive: false
            delegate: Rectangle {
               width: uiSize / 3 * 2
               height: width
               radius: width / 2
               color: Qt.lighter( uiColor )
               Text {
                  anchors.centerIn: parent
                  font.pixelSize: uiFontSizeBig
                  text: index
                  color: Qt.lighter( uiColor, colorCheckFactor ) == "#ffffff" ? "black" : "white"
               }
            }
            path: Path {
               id: hourPath
               property int radius: ( innerCircle.width - uiSize ) / 2;
               startX: innerCircle.width / 2
               startY: uiSize / 2
               PathArc {
                  radiusX: hourPath.radius
                  radiusY: hourPath.radius
                  useLargeArc: false
                  x: hourPath.startX
                  y: innerCircle.width - uiSize / 2
               }
               PathArc {
                  radiusX: hourPath.radius
                  radiusY: hourPath.radius
                  useLargeArc: false
                  x: hourPath.startX
                  y: hourPath.startY
               }
            }
         }
         PathView {
            id: hourSecondVisualCircle
            anchors { fill: parent; }
            model: 12
            interactive: false
            delegate: Rectangle {
               width: uiSize / 3 * 2
               height: width
               radius: width / 2
               color: uiColor
               Text {
                  anchors.centerIn: parent
                  font.pixelSize: uiFontSizeBig
                  text: index + 12
                  color: Qt.lighter( uiColor, colorCheckFactor ) == "#ffffff" ? "black" : "white"
               }
            }
            path: Path {
               id: hourSecondPath
               startX: hourPath.startX
               startY: hourPath.startY + uiSize
               PathArc {
                  radiusX: hourPath.radius - uiSize;
                  radiusY: radiusX
                  useLargeArc: false
                  x: ( innerCircle.width ) / 2
                  y: innerCircle.width - uiSize * 3 / 2
               }
               PathArc {
                  radiusX: hourPath.radius - uiSize;
                  radiusY: radiusX
                  useLargeArc: false
                  x: hourSecondPath.startX
                  y: hourSecondPath.startY
                  //x: innerCircle.width / 2 ;
                  //y: uiSize / 2
               }
            }
         }
         PathView {
            id: minuteVisualCircle
            anchors { fill: parent; }
            model: 12
            interactive: false
            delegate: Rectangle {
               width: uiSize / 3 * 2
               height: width
               radius: width / 2
               color: Qt.lighter( uiColor, 1.15 )
               Text {
                  anchors.centerIn: parent
                  font.pixelSize: uiFontSizeBig
                  text: index * 5
                  color: Qt.lighter( uiColor, colorCheckFactor ) == "#ffffff" ? "black" : "white"
               }
            }
            path: Path {
               id: minutePath
               property int radius: innerCircle.width / 2 - uiSize
               startX: innerCircle.width / 2
               startY: uiSize
               PathArc {
                  radiusX: minutePath.radius
                  radiusY: minutePath.radius
                  useLargeArc: false
                  x: hourPath.startX
                  y: innerCircle.width - uiSize
               }
               PathArc {
                  radiusX: minutePath.radius
                  radiusY: minutePath.radius
                  useLargeArc: false
                  x: minutePath.startX
                  y: minutePath.startY
               }
            }
         }
         Rectangle {
            id: follower
            width: uiSize / 12 * 11
            height: width
            radius: width / 2
            color: "white"
            border { width: uiSize / 12; color: hourInput.text * 1 >= 12 ? Qt.lighter( uiColor ) : uiColor }
            visible: followerText !== ""
            Text {
               id: followerText
               anchors.centerIn: parent
               font.pixelSize: uiFontSizeBig
            }
            x: if ( innerCircle.state == "hour" ) {
                  if ( hourInput.text * 1 >= 12 ) {
                     ( hourPath.radius - uiSize ) * Math.cos(  (  30 * hourInput.text - 90 ) * Math.PI / 180 ) + innerCircle.width / 2 - radius
                  } else {
                     hourPath.radius * Math.cos(  (  30 * hourInput.text - 90 ) * Math.PI / 180 ) + innerCircle.width / 2 - radius
                  }
               } else {
                  minutePath.radius * Math.cos( (  6 * minuteInput.text - 90 ) * Math.PI / 180 ) + innerCircle.width / 2 - follower.radius
               }
            y: if ( innerCircle.state == "hour" ) {
                  if ( hourInput.text * 1 >= 12 ) {
                     ( hourPath.radius - uiSize ) * Math.sin(  (  30 * hourInput.text - 90 ) * Math.PI / 180 ) + innerCircle.width / 2 - radius
                  } else {
                     hourPath.radius * Math.sin(  (  30 * hourInput.text - 90 ) * Math.PI / 180 ) + innerCircle.width / 2 - radius
                  }
               } else {
                  minutePath.radius * Math.sin( (  6 * minuteInput.text - 90 ) * Math.PI / 180 ) + innerCircle.width / 2 - follower.radius
               }
            Behavior on x     { NumberAnimation { duration: 75; } }
            Behavior on y     { NumberAnimation { duration: 75; } }
            Behavior on color { ColorAnimation  { duration: 75; } }
         }
         states: [
            State { name: "hour"
               PropertyChanges { target: followerText;  text: hourInput.text * 1 }
               PropertyChanges { target: pressCounter; onPressed: updateHour(); onPositionChanged: updateHour() }
               PropertyChanges { target: hourVisualCircle;      /* visible: true;*/  opacity: 1; scale: 1 }
               PropertyChanges { target: hourSecondVisualCircle;/* visible: true;*/  opacity: 1; scale: 1 }
               PropertyChanges { target: minuteVisualCircle;     /*visible: false;*/ opacity: 0.2;  scale: 0.4 }
            },
            State { name: "minute"
               PropertyChanges { target: followerText;  text: minuteInput.text * 1 }
               PropertyChanges { target: pressCounter; onPressed: updateMinute(); onPositionChanged: updateMinute() }
               PropertyChanges { target: hourVisualCircle;      /* visible: false;*/ opacity: 0.2;  scale: 0.4 }
               PropertyChanges { target: hourSecondVisualCircle;/* visible: false;*/ opacity: 0.2;  scale: 0.4 }
               PropertyChanges { target: minuteVisualCircle;    /* visible: true; */ opacity: 1;  scale: 1 }
            }
         ]
         transitions: [
            Transition { from: "hour"; to: "minute"
               SequentialAnimation {
                  ParallelAnimation {
                     PropertyAnimation { targets: [ hourVisualCircle, hourSecondVisualCircle, minuteVisualCircle ]; properties: "opacity,scale"; duration: 200 }
                  }
               }
            },
            Transition { from: "minute"; to: "hour"
               SequentialAnimation {
                  ParallelAnimation {
                     PropertyAnimation { targets: [ hourVisualCircle, hourSecondVisualCircle, minuteVisualCircle ]; properties: "opacity,scale"; duration: 200 }
                  }
               }
            }
         ]
      }
   }

   Rectangle {
      id: timeRec
      anchors { bottom: mainCircle.top; horizontalCenter: parent.horizontalCenter; }
      height: uiSize
      width: uiSize * 2
      radius: uiSize / 4
      color: "white"
      Text {
         anchors.centerIn: parent
         text: ":"
         font.pixelSize: uiFontSizeBig
      }

      TextInput {
         id: hourInput
         anchors { verticalCenter: parent.verticalCenter; }
         width: uiSize
         height: uiSize
         horizontalAlignment:  TextInput.AlignHCenter; verticalAlignment: TextInput.AlignVCenter
         font.pixelSize:  uiFontSizeBig
         maximumLength: 2
         text: Qt.formatDateTime( currentDate, "hh")
         validator: IntValidator {
            top: 23;
            bottom: 0;
            locale: "C";
         }
         onFocusChanged: if (focus) selectAll()
         onTextChanged: if (innerCircle.state == "minute") innerCircle.state = "hour"
         onEditingFinished: if ( text.length < 2 ) text = '0' + text
         Text {
            anchors { centerIn: parent }
            text: lang.label( 52 ) + lang.label( 52 )
            color: "#aaa"
            font.pixelSize: parent.font.pixelSize
            visible: !parent.text
         }
      }
      TextInput {
         id: minuteInput
         anchors { verticalCenter: parent.verticalCenter; right: parent.right; }
         width: uiSize
         height: uiSize
         horizontalAlignment: TextInput.AlignHCenter; verticalAlignment: TextInput.AlignVCenter
         font.pixelSize: uiFontSizeBig
         text: Qt.formatDateTime( currentDate, "mm")
         maximumLength: 2
         validator: IntValidator {
            top: 59;
            bottom: 0;
            locale: "C";
         }
         onFocusChanged: if (focus) selectAll()
         onTextChanged: if ( innerCircle.state == "hour") innerCircle.state = "minute"
         onEditingFinished: if ( text.length < 2 ) text = '0' + text
         Text {
            anchors { centerIn:  parent }
            text: lang.label( 53 ) + lang.label( 53 )
            color: "#aaa"
            font.pixelSize: parent.font.pixelSize
            visible: !parent.text
         }
      }
   }

   states: [
      State { name: "opened"
         PropertyChanges { target: timeInput; visible: true;  opacity: 1; scale: 1 }
      },
      State { name: "closed"
         PropertyChanges { target: timeInput; visible: false; opacity: 0;  scale: 0.8 }
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
