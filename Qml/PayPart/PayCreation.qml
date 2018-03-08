import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import "qrc:/Qml/Inputs"
import "qrc:/Qml/Buttons"

Rectangle {
   id: payCreator

   z: 10

   property int spacing: uiSize * 0.3

   state: "closed"
   enabled: visible

   onStateChanged: if ( state == "opened" ) reset()

   anchors.fill: parent

   property string integerInput: ""
   property string fractionInput: ""
   property bool   isIncome: true
   property int currencyIndex: settings.getDefCurrency()
   property int categoryIndex: settings.getDefCategory()

   Connections {
      target: categoryModel
      onRemoved: categoryRemoved(index)
   }
   Connections {
      target: currencyModel
      onRemoved: currencyRemoved(index)
   }
   function categoryRemoved(index){
      if ( categoryIndex === index ){
         categoryIndex = 0
      }
      if ( categoryIndex > index){
         categoryIndex--
      }
      if ( settings.getDefCategory() === index ){
         settings.setDefCategory( 0 )
      }
      if ( settings.getDefCategory() > index ){
         settings.setDefCategory( settings.getDefCategory()-1 )
      }
   }
   function currencyRemoved(index){
      if ( currencyIndex === index ){
         currencyIndex = 0
      }
      if ( currencyIndex > index){
         currencyIndex--
      }
      if ( settings.getDefCurrency() === index ){
         settings.setDefCurrency( 0 )
      }
      if ( settings.getDefCurrency() > index ){
         settings.setDefCurrency( settings.getDefCurrency()-1 )
      }
   }

   property int year:   Qt.formatDateTime( currentDate, "yyyy")*1
   property int month:  Qt.formatDateTime( currentDate, "MM")*1
   property int day:    Qt.formatDateTime( currentDate, "dd")*1
   property int hour:   Qt.formatDateTime( currentDate, "hh")*1
   property int minute: Qt.formatDateTime( currentDate, "mm")*1
   property string description: ""

   function reset(){
      year   = Qt.formatDateTime( currentDate, "yyyy")*1
      month  = Qt.formatDateTime( currentDate, "MM")*1
      day    = Qt.formatDateTime( currentDate, "dd")*1
      hour   = Qt.formatDateTime( currentDate, "hh")*1
      minute = Qt.formatDateTime( currentDate, "mm")*1
      description = ""
   }


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
            payCreator.state = "closed"
         }
      }
      Text {
         id: labelText
         anchors.centerIn: parent
         text: lang.label( 25 )
         font.pixelSize: uiFontSize
      }
      Image {
         id: addButton
         anchors { top: parent.top; right: parent.right;  margins: uiSize / 4 }
         height: uiSize / 2; width: height;
         sourceSize { width: parent.width; height: parent.height; } smooth: false
         source: "/Icons/CheckMark.svg"
      }
      MouseArea {
         anchors { top: parent.top; right: parent.right; bottom: parent.bottom; }
         width: height
         onClicked: {
            if ( integerInput != "" && currencyIndex >= 0 && categoryIndex >= 0 ) {
               payModel.createPay( isIncome,
                                  integerInput, fractionInput,
                                  year, month, day, hour, minute,
                                  currencyIndex, categoryIndex,
                                  description )
               payCreator.state = "closed"
            }
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
         GradientStop { position: 0.0; color: "#C6C6C6" }
         GradientStop { position: 1; color: "transparent" }
      }
   }

   Flickable {
      anchors { top: labelRow.bottom;  left: parent.left; right: parent.right; bottom: parent.bottom; }

      contentWidth: parent.width; contentHeight: uiSize * 5

      clip: true

      boundsBehavior: Flickable.StopAtBounds

      Column {
          Repeater {
             model: 5
             Item {
                height: uiSize; width: payCreationWindow.width
                Rectangle {
                   anchors { left: parent.left; right: parent.right; }
                   y: uiSize - 1;
                   height: uiLineWidth
                   color: "#CCCCCC"
                }

             }

          }
      }

      CustomButton2 {
         id: sumSection
         width: parent.width
         height: uiSize
         Image{
            id: sumImage
            anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/Money.svg"
         }
         Text {
            id: sumLabel
            anchors { verticalCenter: parent.verticalCenter }
            x: uiSize / 48 * 52
            text: lang.label( 66 )
            font.pixelSize: uiFontSize
            color: "#808080"
         }
         onClicked: {
            if ( sumLabel.text*1 != 0 ){
               sumEdit.setData(
                        payCreator.integerInput,
                        payCreator.fractionInput,
                        payCreator.isIncome,
                        payCreator.currencyIndex
                        )
            }
            sumEdit.state = "opened"
         }
      }

      CustomButton2 {
         id: categorySection
         y: uiSize
         width: parent.width
         height: uiSize
         Image{
            anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/Category.svg"
         }
         Rectangle {
            anchors { verticalCenter: parent.verticalCenter }
            x: uiSize / 48 * 52
            width: categorySectionLabel.width + uiSize / 2;  height: uiSize / 3 * 2
            color: categoryModel.getColor( categoryIndex )
            radius: height / 3
            Text {
               id: categorySectionLabel
               anchors.centerIn: parent
               text: categoryModel.getName(categoryIndex)
               font.pixelSize: uiFontSize
               color: Qt.lighter( parent.color , colorCheckFactor ) == "#ffffff" ? "black" : "white"
            }
         }
         onClicked: categoryInput.state = "opened"
      }

      CustomButton2 {
         id: dateSection
         y: uiSize * 2; width: parent.width; height: uiSize
         Image{
            anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/DateFrom.svg"
         }
         Text {
            id: dateLabel
            anchors { verticalCenter: parent.verticalCenter }
            x: uiSize / 48 * 52
            text: day + ' ' + lang.label ( 11 + month ) + ' ' + year
            font.pixelSize: uiFontSize
         }
         onClicked: dateInput.state = "opened"
      }
      Rectangle {
         x: dateSection.x + dateSection.width; height: uiSize
         width: uiLineWidth
         color: "#CCCCCC"
      }

      CustomButton2 {
         id: timeSection
         y: uiSize * 3; width: parent.width; height: uiSize
         Image{
            anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/TimeFrom.svg"
         }
         Text {
            id: timeLabel
            anchors { verticalCenter: parent.verticalCenter }
            x: uiSize / 48 * 52
            text: ( hour < 10 ? '0' + hour : hour ) + ":"
                + ( minute < 10 ? '0' + minute : minute )
            font.pixelSize: uiFontSize
         }
         onClicked: timeInput.state = "opened"
      }


      CustomButton2 {
         id: descriptionSection
         y: uiSize * 4
         width: parent.width
         height: uiSize
         Image{
            anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/Pencil.svg"
         }
         Text {
            id: descriptionLabel
            anchors { verticalCenter: parent.verticalCenter }
            x: uiSize / 48 * 52
            text: lang.label( 24 )
            font.pixelSize: uiFontSize
            color: "#808080"
         }
         onClicked: descriptionInput.state = "opened"
      }

   }

   SumEdit {
      anchors { horizontalCenter: parent.horizontalCenter; }
      id: sumEdit
      z:8
      y: uiSize * 2
      onStateChanged: payCreatonBlock.state = state
      onOkClicked: {
         payCreator.integerInput  = sumEdit.integerInput
         payCreator.fractionInput = sumEdit.fractionInput
         payCreator.isIncome      = sumEdit.isIncome
         payCreator.currencyIndex = sumEdit.currencyIndex
         sumLabel.text = ( isIncome ? "+ " : "- " )
               + payCreator.integerInput
               + ( payCreator.fractionInput*1 > 0 ?
                     "." + payCreator.fractionInput + " " : " " )
               + currencyModel.getName( payCreator.currencyIndex )
         sumLabel.color = "black"
         sumLabel.font.pixelSize = uiFontSizeBig
         sumImage.source = payCreator.isIncome ? "/Icons/Income.svg" : "/Icons/Consumption.svg"
      }
   }

   CategoryInput {
      id: categoryInput
      onStateChanged: payCreatonBlock.state = state
      onCategorySelected: categoryIndex = index
   }

   DateInput {
      id: dateInput
      onStateChanged: payCreatonBlock.state = state
      width: payCreationWindow.width
      onDateSelected:{
         payCreator.day = day
         payCreator.month = month
         payCreator.year = year
      }
   }
   TimeInput{
      id: timeInput
      onStateChanged: payCreatonBlock.state = state
      onTimeSelected: {
         hour   = selectedHour * 1
         minute = selectedMinute * 1
      }
   }

   DescriptionInput {
      id: descriptionInput
      onStateChanged: {
         payCreatonBlock.state = state
         if ( state == "opened" && descriptionLabel.color == "000" ){
            descriptionInput.setText( descriptionLabel.text )
         }
      }
      onDescriptionEdited: {
         if ( description ){
            descriptionLabel.text  = description
            descriptionLabel.color = "black"
         } else {
            descriptionLabel.text  = lang.label( 24 )
            descriptionLabel.color = "#808080"
         }
         payCreator.description = description
      }
   }

   Rectangle {
      id: payCreatonBlock
      z: 7
      width: parent.width; height: parent.height
      state: "closed"
      MouseArea {
         anchors.fill: parent
         propagateComposedEvents: true
         onClicked: categoryInput.state = "closed"
      }
      states: [
         State { name: "opened"
            PropertyChanges { target: payCreatonBlock; visible: true; color: "#50000000" }
         },
         State { name: "closed"
            PropertyChanges { target: payCreatonBlock; color: "transparent"; visible: false }
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


   MouseArea { z: -1;  anchors.fill: parent; onClicked: mouse.accepted = true }

   states: [
      State {
         name: "closed"
         PropertyChanges {
            target: payCreator
            opacity: 0
            visible: false
         }
      },
      State { name: "opened"
         PropertyChanges {
            target: payCreator
            opacity: 1
            visible: true
         }
      }
   ]
   transitions: [
      Transition { from: "closed"; to: "opened"
         SequentialAnimation {
            PropertyAnimation { target: payCreator; properties: "visible"; duration: 0 }
            PropertyAnimation { target: payCreator; properties: "opacity"; duration: 100 }
         }
      },
      Transition { from: "opened"; to: "closed"
         SequentialAnimation {
            PropertyAnimation { target: payCreator; properties: "opacity"; duration: 100 }
            PropertyAnimation { target: payCreator; properties: "visible"; duration: 0 }
         }
      }
   ]
}
