import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import "qrc:/Qml/Inputs"
import "qrc:/Qml/Buttons"

Rectangle {
   id: tPayCreator

   z: 10

   property int spacing: uiSize * 0.3

   state: "closed"
   enabled: visible

   anchors.fill: parent

   property string integerInput: ""
   property string fractionInput: ""
   property bool   isIncome: true
   property int currencyIndex: settings.getDefCurrency()
   property int categoryIndex: settings.getDefCategory()
   property int yearFrom:   0
   property int monthFrom:  1
   property int dayFrom:    1
   property int hourFrom:   0
   property int minuteFrom: 0
   property int period: 0
   property int periodType: periodTypeSelect.currentIndex
   property int maxRepeat: 0
   property string autoDescription: ""

   function resetDate(){
      yearFrom   = Qt.formatDateTime( currentDate, "yyyy")*1
      monthFrom  = Qt.formatDateTime( currentDate, "MM")*1
      dayFrom    = Qt.formatDateTime( currentDate, "dd")*1
      hourFrom   = Qt.formatDateTime( currentDate, "hh")*1
      minuteFrom = Qt.formatDateTime( currentDate, "mm")*1
   }

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
   }
   function currencyRemoved(index){
      if ( currencyIndex === index ){
         currencyIndex = 0
      }
      if ( currencyIndex > index){
         currencyIndex--
      }
   }

   function reset(){}

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
            tPayCreator.state = "closed"
            tPayCreator.reset()
         }
      }
      Text {
         id: labelText
         anchors.centerIn: parent
         text: lang.label( 65 )
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
         property bool isOk: true
         onClicked: {
            isOk = true
            if ( integerInput != "" && period != 0 && currencyIndex >= 0 && categoryIndex >= 0 ) {
               if ( dateTimeFrom.state == "disabled" ){
                  yearFrom    = Qt.formatDateTime( currentDate, "yyyy")*1
                  monthFrom   = Qt.formatDateTime( currentDate, "MM")*1
                  dayFrom     = Qt.formatDateTime( currentDate, "dd")*1
                  hourFrom    = Qt.formatDateTime( currentDate, "hh")*1
                  minuteFrom  = Qt.formatDateTime( currentDate, "mm")*1
               }
               tPayModel.createTPay( isIncome, integerInput, fractionInput,
                                     yearFrom, monthFrom, dayFrom, hourFrom, minuteFrom,
                                     periodType, period, currencyIndex, categoryIndex,
                                     maxRepeat,
                                     powerSwitcher.isSelected, borderSwitcher.isSelected,
                                     autoDescription )
               tPayCreator.state = "closed"
               tPayCreator.reset()
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
         GradientStop { position: 0.0; color: "#aaaaaa" }
         GradientStop { position: 1; color: "transparent" }
      }

   }


   Flickable {
      anchors { top: labelRow.bottom;  left: parent.left; right: parent.right; bottom: parent.bottom; }
      contentWidth: parent.width;
      contentHeight: uiSize * 7
      clip: true

      boundsBehavior: Flickable.StopAtBounds

      Column {
          Repeater {
             model: 7
             Item {
                height: uiSize; width: tPayCreationWindow.width
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
               sumEdit.setData( tPayCreator.integerInput, tPayCreator.fractionInput, tPayCreator.isIncome, tPayCreator.currencyIndex )
            }
            sumEdit.state = "opened"
         }
      }

      CustomButton2 {
         id: periodSection
         y: uiSize
         width: parent.width
         height: uiSize
         Image{
            anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/DateTimePeriod.svg"
         }
         Text {
            id: periodSectionLabel
            anchors { verticalCenter: parent.verticalCenter }
            x: uiSize / 48 * 52
            text: lang.label( 7 )
            font.pixelSize: uiFontSize
            color: "#808080"
         }
         onClicked: {
            periodInput.state = "opened"

         }
      }

      CustomButton2 {
         id: categorySection
         y: uiSize * 2
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
         id: autoDescriptionSection
         y: uiSize * 3
         width: parent.width
         height: uiSize
         Image{
            anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/Pencil.svg"
         }
         Text {
            id: autoDescriptionLabel
            anchors { verticalCenter: parent.verticalCenter }
            x: uiSize / 48 * 52
            text: lang.label( 69 )
            font.pixelSize: uiFontSize
            color: "#808080"
         }
         onClicked: descriptionInput.state = "opened"
      }

      Item {
         id: dateTimeFrom
         width: parent.width
         height: uiSize
         y: uiSize * 4
         state: "disabled"
         Image{
            anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/DateFrom.svg"
         }
         CustomButton2 {
            width: parent.width
            height: uiSize
            Text {
               id: dateFromDefaultLabel
               anchors { verticalCenter: parent.verticalCenter }
               x: uiSize / 48 * 52
               text: lang.label( 76 )
               font.pixelSize: uiFontSize
            }
            onClicked: dateTimeAlert.state = "opened"
         }

         CustomButton2 {
            id: dateFromSection
            x: parent.width
            width: parent.width / 2
            height: uiSize
            onWidthChanged: dateFromLabel.updateWidth()
            Image{
               anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
               height: uiSize / 3 * 2; width: height
               sourceSize { width: parent.width; height: parent.height; } smooth: false
               source: "/Icons/DateFrom.svg"
            }
            Text {
               id: dateFromLabel
               anchors { verticalCenter: parent.verticalCenter }
               x: uiSize / 48 * 52
               font.pixelSize: uiFontSize
               text: dayFrom + ' ' + lang.label( 11 + monthFrom ) + ' ' + yearFrom
               onTextChanged: {
                  updateWidth()
               }
               Component.onCompleted: updateWidth()
               function updateWidth(){
                  font.pixelSize = uiFontSize
                  while (parent.width - x > 0 && parent.width - x < width ) font.pixelSize--
               }
            }
            onClicked: dateInput.state = "opened"
         }
         Rectangle {
            x: dateFromSection.x + dateFromSection.width
            height: uiSize
            width: uiLineWidth
            color: "#CCCCCC"
         }
         CustomButton2 {
            id: timeFromSection
            x: dateFromSection.x + dateFromSection.width
            width: parent.width / 2 - uiSize
            height: uiSize
            Image{
               anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
               height: uiSize / 3 * 2; width: height
               sourceSize { width: parent.width; height: parent.height; } smooth: false
               source: "/Icons/TimeFrom.svg"
            }
            Text {
               id: timeFromLabel
               anchors { verticalCenter: parent.verticalCenter }
               x: uiSize / 48 * 52
               text: ( hourFrom < 10 ? '0' + hourFrom : hourFrom ) + ":"
                   + ( minuteFrom < 10 ? '0' + minuteFrom : minuteFrom )
               font.pixelSize: uiFontSize
            }
            onClicked: timeInput.state = "opened"
         }
         Rectangle {
            x: timeFromSection.x + timeFromSection.width
            height: uiSize
            width: uiLineWidth
            color: "#CCCCCC"
         }
         CustomButton2 {
            id: dateTimeFromHelpSection
            x: timeFromSection.x + timeFromSection.width
            height: uiSize
            width: height
            Image{
               anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
               height: uiSize / 3 * 2; width: height
               sourceSize { width: parent.width; height: parent.height; } smooth: false
               source:   "/Icons/RingedArrowDate.svg"
            }
            onClicked: dateTimeFrom.state = "disabled"
         }
         states: [
            State { name: "enabled"
               PropertyChanges { target: dateTimeFrom; x: -width }
            },
            State { name: "disabled"
               PropertyChanges { target: dateTimeFrom; x: 0 }
            }
         ]
         transitions: [
            Transition {
               PropertyAnimation { property: "x"; duration: 100 }
            }
         ]
      }

      CustomButton2 {
         id: enableSection
         y: uiSize * 5
         width: parent.width
         height: uiSize
         Image{
            anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/Power.svg"
         }
         Text {
            anchors { verticalCenter: parent.verticalCenter }
            x: uiSize / 48 * 52
            text: lang.label( 70 )
            font.pixelSize: uiFontSize
         }
         Switcher {
            id: powerSwitcher
            isSelected: true
            anchors { right: parent.right; }
         }
         onClicked: powerSwitcher.isSelected = !powerSwitcher.isSelected
      }

      CustomButton2 {
         id: presentBorderSection
         y: uiSize * 6
         width: parent.width
         height: uiSize
         Image{
            anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/Time.svg"
         }
         Text {
            anchors { verticalCenter: parent.verticalCenter }
            x: uiSize / 48 * 52
            text: lang.label( 98 )
            font.pixelSize: uiFontSize
         }
         Switcher {
            id: borderSwitcher
            isSelected: true
            anchors { right: parent.right; }
         }
         onClicked: borderSwitcher.isSelected = !borderSwitcher.isSelected
      }
   }

   SumEdit {
      anchors { horizontalCenter: parent.horizontalCenter; }
      id: sumEdit
      z:8
      y: uiSize * 2
      onStateChanged: tPayCreatonBlock.state = state
      onOkClicked: {
         tPayCreator.integerInput  = sumEdit.integerInput
         tPayCreator.fractionInput = sumEdit.fractionInput
         tPayCreator.isIncome      = sumEdit.isIncome
         tPayCreator.currencyIndex = sumEdit.currencyIndex
         sumLabel.text = ( isIncome ? "+ " : "- " )
               + tPayCreator.integerInput
               + ( tPayCreator.fractionInput*1 > 0 ? "." + tPayCreator.fractionInput + " " : " " )
               + currencyModel.getName( tPayCreator.currencyIndex )
         sumLabel.color = "black"
         sumLabel.font.pixelSize = uiFontSizeBig
         sumImage.source = tPayCreator.isIncome ? "/Icons/Income.svg" : "/Icons/Consumption.svg"
      }
   }

   Rectangle {
      id: dateTimeAlert
      anchors.centerIn: parent
      width: uiSize * 6
      height: uiSize * 3.6
      state: "closed"
      onStateChanged: tPayCreatonBlock.state = state
      z: 12
      Text {
         x: uiSize / 3
         y: uiSize / 4
         text: lang.label(77)
         font.pixelSize: uiFontSizeBig
      }
      Image {
         anchors { right: parent.right; top: parent.top; margins: uiSize / 6 }
         height: uiSize / 3 * 2; width: height
         sourceSize { width: parent.width; height: parent.height; } smooth: false
         source: "/Icons/DateFrom.svg"
      }
      Rectangle {
         y: uiSize
         height: uiLineWidth
         width: parent.width
         color: "#CCCCCC"
      }
      Text {
         anchors { fill: parent; bottomMargin: uiSize * 1; topMargin: uiSize * 1.3; leftMargin: uiSize / 6; rightMargin: uiSize / 6 }
         clip: true
         wrapMode: Text.Wrap
         text: lang.label(78)
         font.pixelSize: uiFontSize
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
            parent.state = "closed"
            resetDate()
            dateTimeFrom.state = "enabled"
         }
      }

      states: [
         State { name: "opened"
            PropertyChanges { target: dateTimeAlert; visible: true;  opacity: 1; scale: 1 }
         },
         State { name: "closed"
            PropertyChanges { target: dateTimeAlert; visible: false; opacity: 0;  scale: 0.8 }
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
      id: periodInput
      anchors.centerIn: parent
      width: dpi < 120 ? 320 : dpi * 2;
      height: uiSize * 4
      state: "closed"
      onStateChanged: {
         tPayCreatonBlock.state = state
         if ( state == "opened" ) {
            periodTypeSelect.setCurrentIndex( periodType )
            periodNumberInput.text  = period > 0 ? period : ''
            maxRepeatPeriodInput.text     = maxRepeat
         }
      }
      z: 12
      Item {
         id: periodInputPanel
         width: parent.width; height: uiSize
         Text {
            anchors.verticalCenter: parent.verticalCenter
            x: uiSize / 3
            text: lang.label(79)
            font.pixelSize: uiFontSizeBig
         }
         Image {
            anchors { top: parent.top; right: parent.right; margins: uiSize / 6 }
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/DateTimePeriod.svg"
         }
         Rectangle {
            anchors.bottom: parent.bottom
            height: uiLineWidth
            width: parent.width
            color: "#CCCCCC"
         }
      }
      Text {
         id: periodLabel
         anchors { top: parent.top; left: parent.left; topMargin: uiSize * 1.3; leftMargin: uiSize / 2; }
         text: lang.label(87)
         font.pixelSize: uiFontSize
      }

      TextInput {
         id: periodNumberInput
         anchors { verticalCenter: periodLabel.verticalCenter; }
         x: uiSize * 2.5
         width: uiSize; height: uiSize
         horizontalAlignment:  TextInput.AlignHCenter; verticalAlignment: TextInput.AlignVCenter
         font.pixelSize:  uiFontSizeBig
         text: "1"
         validator: IntValidator {
            id: periodValidator
            top: ('9').repeat( periodTypeSelect.currentIndex + 1 )*1
            bottom: 0;
            locale: "C";
         } maximumLength: 4
         Text {
            anchors { centerIn: parent }
            text: '0'
            color: "#aaa"
            font.pixelSize: parent.font.pixelSize
            visible: !parent.text && !parent.focus
         }
         Rectangle {
             anchors { horizontalCenter: parent.horizontalCenter }
             y: uiSize * 3 / 4
             width: uiSize; height: uiLineWidth
             color: uiColor
         }
      }
      CustomComboBox {
         id: periodTypeSelect
         y: periodNumberInput.y; x: periodNumberInput.x + uiSize * 1.2
         maximumHeight: uiSize * 3.5
         width: uiSize * 2.4
         modelView: ListModel {
            Component.onCompleted: {
               append({ name: lang.label( 81 ) })
               append({ name: lang.label( 82 ) })
               append({ name: lang.label( 83 ) })
               append({ name: lang.label( 84 ) })
               periodTypeSelect.setCurrentIndex(1)
            }
        }
         onCurrentIndexChanged: {
            var maxNumber = ('9').repeat( periodTypeSelect.currentIndex + 1 )*1
            periodValidator.top = maxNumber
            if ( periodNumberInput.text*1 > maxNumber ) {
               periodNumberInput.text = maxNumber
            }
            maxRepeatValidator.top = maxNumber
            if ( maxRepeatPeriodInput.text*1 > maxNumber ){
               maxRepeatPeriodInput.text = maxNumber
            }
         }
      }
      Text {
         id: maxRepeatsLabel
         y: periodLabel.y + uiSize
         x: periodLabel.x
         text: lang.label(88)
         font.pixelSize: uiFontSize
      }

      TextInput {
         id: maxRepeatPeriodInput
         y: periodNumberInput.y + uiSize; x: periodNumberInput.x
         width: uiSize; height: uiSize
         horizontalAlignment:  TextInput.AlignHCenter; verticalAlignment: TextInput.AlignVCenter
         font.pixelSize:  uiFontSizeBig
         validator: IntValidator {
            id: maxRepeatValidator
            top: ('9').repeat( periodTypeSelect.currentIndex + 1 )*1
            bottom: 0;
            locale: "C";
         } maximumLength: 4
         onTextChanged: if ( text*1 == 0 ) text = ''
         Text {
            anchors { centerIn: parent }
            text: '∞'
            font.pixelSize: parent.font.pixelSize
            visible: !parent.text
         }
         Rectangle {
             anchors { horizontalCenter: parent.horizontalCenter }
             y: uiSize * 3 / 4
             width: uiSize; height: uiLineWidth
             color: uiColor
         }
      }
      Text {
         id: periodAlertLabel
         y: uiSize * 1.8; x: uiSize
         visible: false
         text: lang.label( 89 )
         font.pixelSize: uiFontSizeSmall
         color: "red"
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
            text: lang.label( 9 )
            font.pixelSize: uiFontSize
         }
         onClicked: {
            if  ( periodNumberInput.text*1 != 0 )
            {
               periodAlertLabel.visible = false
               period    = periodNumberInput.text*1
               periodType = periodTypeSelect.currentIndex
               maxRepeat = maxRepeatPeriodInput.text*1
               periodSectionLabel.text = periodTypeSelect.currentText + ": "
                     + period + ', '+lang.label( 86 )+ ": "
                     + ( maxRepeat > 0 ? maxRepeat : '∞' )
               periodSectionLabel.color = "black"
               Qt.inputMethod.hide();
               parent.state = "closed"
            } else {
               periodAlertLabel.visible = true
            }
         }
      }

      states: [
         State { name: "opened"
            PropertyChanges { target: periodInput; visible: true;  opacity: 1; scale: 1 }
         },
         State { name: "closed"
            PropertyChanges { target: periodInput; visible: false; opacity: 0;  scale: 0.8 }
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

   CategoryInput {
      id: categoryInput
      onStateChanged: tPayCreatonBlock.state = state
      onCategorySelected: categoryIndex = index
   }

   DescriptionInput {
      id: descriptionInput
      onStateChanged: {
         tPayCreatonBlock.state = state
         if ( state == "opened" && autoDescriptionLabel.color == "000" ){
            descriptionInput.setText( autoDescriptionLabel.text )
         }
      }
      onDescriptionEdited: {
         if ( description ){
            autoDescriptionLabel.text = description
            autoDescriptionLabel.color = "black"
         } else {
            autoDescriptionLabel.text = lang.label( 69 )
            autoDescriptionLabel.color = "#808080"
         }
         autoDescription = description
      }
   }

   DateInput {
      id: dateInput
      onStateChanged: tPayCreatonBlock.state = state
      width: tPayCreationWindow.width
      onDateSelected:{
         dayFrom = day
         monthFrom = month
         yearFrom = year
      }
   }
   TimeInput{
      id: timeInput
      onStateChanged: tPayCreatonBlock.state = state
      onTimeSelected: {
         hourFrom = selectedHour * 1
         minuteFrom = selectedMinute * 1
      }
   }
   Rectangle {
      z: 7
      id: tPayCreatonBlock
      width: parent.width
      height: parent.height
      state: "closed"
      MouseArea {
         anchors.fill: parent
         propagateComposedEvents: true
         onClicked: categoryInput.state = "closed"
      }
      states: [
         State { name: "opened"
            PropertyChanges { target: tPayCreatonBlock; visible: true; color: "#50000000" }
         },
         State { name: "closed"
            PropertyChanges { target: tPayCreatonBlock; color: "transparent"; visible: false }
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
            target: tPayCreator
            opacity: 0
            visible: false
         }
      },
      State { name: "opened"
         PropertyChanges {
            target: tPayCreator
            opacity: 1
            visible: true
         }
      }
   ]
   transitions: [
      Transition { from: "closed"; to: "opened"
         SequentialAnimation {
            PropertyAnimation { target: tPayCreator; properties: "visible"; duration: 0 }
            PropertyAnimation { target: tPayCreator; properties: "opacity"; duration: 100 }
         }
      },
      Transition { from: "opened"; to: "closed"
         SequentialAnimation {
            PropertyAnimation { target: tPayCreator; properties: "opacity"; duration: 100 }
            PropertyAnimation { target: tPayCreator; properties: "visible"; duration: 0 }
         }
      }
   ]
}

