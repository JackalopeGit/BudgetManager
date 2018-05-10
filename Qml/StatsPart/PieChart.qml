import QtQuick 2.9
import QtCharts 2.2
import QtGraphicalEffects 1.0

import "qrc:/Qml/Inputs"
import "qrc:/Qml/Buttons"

Item {
   id: area

   property int currentCurrency: settings.getDefCurrency()

   onCurrentCurrencyChanged: chartView.createPie()

   ListView {
      id: customLegend
      z: 2
      width: isVertical ? uiSize * 3 : parent.width
      height: isVertical ? parent.height : uiSize
      model: categoryModel
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      orientation: isVertical ? Qt.Vertical : Qt.Horizontal

      property bool isVertical: area.width > area.height

      onMovementStarted: {
         currentItem.reset()
      }

      delegate: Item {
         width: categoryItem.width + uiSize / 8; height: uiSize

         function reset(){
            mouseArea.reset()
         }

         Rectangle {
            id: categoryItem
            anchors.centerIn: parent
            width: legendText.width + uiSize / 2 > uiSize * 3 - uiSize / 8 ?
                      (uiSize * 3 - uiSize / 8)
                    : (legendText.width + uiSize / 2)
            height: uiSize / 3 * 2
            color: categoryColor
            radius: height / 2
            clip: true
            Text {
               id: legendText
               anchors {
                  verticalCenter: parent.verticalCenter;
                  left: parent.left;
                  margins: uiSize / 4
               }
               text: name
               color: Qt.lighter( parent.color , colorCheckFactor ) == "#ffffff" ? "black" : "white"
               font.pixelSize: uiFontSizeSmall
            }
            Behavior on color { ColorAnimation{ duration: 200; easing.type: Easing.InOutQuad} }
         }
         MouseArea{
            id: mouseArea
            anchors.fill: parent
            onEntered: {
               customLegend.currentIndex = index
               categoryItem.color = Qt.lighter(categoryColor)
               if ( pieSeries.at( index ).percentage ){
                  sumLabel.text = pieSeries.at( index ).value / 100
                        + (pieSeries.at( index ).value % 100 > 0 ?',' + pieSeries.at( index ).value % 100 + ' ' : ' ' )
                        + currencyModel.getName( currentCurrency )
                  pieSeries.at( index ).explodeDistanceFactor = 0.08
                  pieSeries.at( index ).labelArmLengthFactor = 0.11
                  pieSeries.at( index ).label = (pieSeries.at( index ).percentage * 100 +" ").substring(0, 5) + "%"
                  pieSeries.at( index ).labelFont = Qt.font({ pixelSize: uiFontSize, bold: true })

                  pieSeries.at( index ).exploded = true
                  pieSeries.at( index ).labelVisible = true
               } else {
                  sumLabel.text = 0 + ' ' + currencyModel.getName( currentCurrency )
               }
            }
            onReleased: reset()
            function reset(){
               sumLabel.text = lang.label(4) + ' '
                     + pieSeries.sum / 100
                     + (pieSeries.sum % 100 > 0 ?',' + pieSeries.sum % 100 + ' ' : ' ' )
                     + currencyModel.getName( currentCurrency )
               categoryItem.color = categoryColor
               pieSeries.at( index ).labelVisible = false
               pieSeries.at( index ).exploded = false
            }
         }
      }
   }

   ChartView {
      id: chartView
      anchors.centerIn: parent
      width: parent.width; height: parent.height
      antialiasing: false
      legend.visible: false
      backgroundColor: "transparent"
      backgroundRoundness : 0

      /*Connections {
         target: currencyModel
         onRemoved:          {
            if ( currentCurrency === index ){
               currentCurrency = 0
            }
            if ( currentCurrency > index){
               currentCurrency--
            }}
      }*/
      Connections {
               target: categoryModel
               onChanged: pieSeries.at( index ).color = categoryModel.getColor(index)
      }

      property bool isIncome


      onIsIncomeChanged: createPie()

      Connections {
         target: pieData
         onIncomeValueChanged:
            if ( currentCurrency == currencyNo && chartView.isIncome  ){
                  pieSeries.at( categoryNo ).value = pieData.incomeValue( currencyNo, categoryNo )
               }
         onExpenceValueChanged:
             if ( currentCurrency == currencyNo && !chartView.isIncome  ){
                   pieSeries.at( categoryNo ).value = pieData.consumptionValue( currencyNo, categoryNo )
                }

         //onSerieAdded:( quint8 currencyNo );
         //onSerieRemoved:( quint8 currencyNo );
         onSliceAdded: chartView.createPie()
         onSliceRemoved: pieSeries.remove( categoryNo )
         onPieChanged: chartView.createPie()
      }

      PieSeries {
         id: pieSeries
         size: 0.5
         holeSize: 0.3

         onHovered: {
            if ( state == true){
               if (slice.percentage > 0){
                  sumLabel.text = settings.prepareSum(slice.value / 100)
                        + (slice.value % 100 > 0 ?',' + slice.value % 100 + ' ' : ' ' )
                        + currencyModel.getName( currentCurrency )
                  slice.explodeDistanceFactor = 0.08
                  slice.labelArmLengthFactor = 0.11
                  slice.label = (slice.percentage * 100 +" ").substring(0, 5) + "%"
                  slice.labelFont = Qt.font({ pixelSize: uiFontSize, bold: true })

                  slice.exploded = true
                  slice.labelVisible = true
               }
            } else {
               sumLabel.text = lang.label(4) + ' '
                     + settings.prepareSum( pieSeries.sum / 100 )
                     + (pieSeries.sum % 100 > 0 ?',' + pieSeries.sum % 100 + ' ' : ' ' )
                     + currencyModel.getName( currentCurrency )
               slice.labelVisible = false
               slice.exploded = false
            }
         }

      }
      property color tempColor

      Component.onCompleted: createPie()
      function createPie(){
         //chartView.animationOptions = ChartView.NoAnimation
         pieSeries.clear()
         var pointsCount = pieData.sliceCount()
         for( var j = 0; j < pointsCount; j++ )
         {
            if ( isIncome ){
               pieSeries.append( categoryModel.getName(j), pieData.incomeValue( currentCurrency, j ) );
               pieSeries.at( pieSeries.count - 1 ).color = categoryModel.getColor(j)
            }
            else {
               pieSeries.append( categoryModel.getName(j), pieData.consumptionValue( currentCurrency, j ) );
               pieSeries.at( pieSeries.count - 1 ).color = categoryModel.getColor(j)
            }
         }
         sumLabel.text = pieSeries.sum ?
                  lang.label(4) + ' '
                  + settings.prepareSum( pieSeries.sum / 100 )
                  + (pieSeries.sum % 100 > 0 ?',' + pieSeries.sum % 100 + ' ' : ' ' )
                  + currencyModel.getName( currentCurrency )
                : lang.label(10)
         //chartView.animationOptions = ChartView.SeriesAnimations
      }
   }
   Item {
      id: dateButtom
      z: 3;
      x: uiSize / 3
      anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: customLegend.isVertical ? 0 : uiSize }
      width: dateLabel.width + uiSize / 2
      height: uiSize
      Rectangle {
         id: dateButtonRec;
         anchors.centerIn: parent
         width: parent.width; height: parent.height / 3 * 2
         border { color: uiColor; width: uiLineWidth }
         radius: height / 2
      }
      Text {
         id: dateLabel
         anchors { centerIn: parent }
         text: {
            switch ( settings.getDefDateType() ) {
            case(0):
               pieData.setDay( Qt.formatDateTime(currentDate,"yyyy")*1,
                                     Qt.formatDateTime(currentDate,"M")*1,
                                     Qt.formatDateTime(currentDate,"d")*1 )

               return Qt.formatDateTime(currentDate,"d") + ' ' + lang.label(11+Qt.formatDateTime(currentDate, "M")*1)

            case (1):
               pieData.setMonth( Qt.formatDateTime(currentDate,"yyyy")*1,
                                       Qt.formatDateTime(currentDate,"M")*1 )

               return lang.label(100) + ", " + lang.label(11+Qt.formatDateTime(currentDate, "MM")*1)

            case(2):
               pieData.setYear( Qt.formatDateTime(currentDate,"yyyy")*1 )

               return lang.label(101) + ", " + Qt.formatDateTime(currentDate, "yyyy")

            case(3):
               pieData.setAllTime()

               return lang.label(102)
            }
            //chartView.createPie()
         }
         font.pixelSize: uiFontSize
      }
      MouseArea {
         anchors.fill: parent
         onClicked: { dateSelect.state = "opened"; blockRectangle.state = "opened"; }
      }
   }
   Text {
      id: sumLabel
      anchors {
         horizontalCenter: parent.horizontalCenter;
         bottom: parent.bottom; margins: uiSize
      }
      text: {
         if (pieSeries.sum){
            lang.label(4) + ' '
                  + settings.prepareSum( pieSeries.sum / 100 )
                  + (pieSeries.sum % 100 > 0 ?',' + pieSeries.sum % 100 + ' ' : ' ' )
                  + currencyModel.getName( currentCurrency )
         } else {
            lang.label(10)
         }
      }
      font { pixelSize: uiFontSizeBig; bold: true}
   }

   LinearGradient {
      anchors { bottom: panel.top;  left: panel.left; right: panel.right; }
      z:3
      height: uiSize / 6
      start: Qt.point( 0, height)
      end:   Qt.point( 0, 0 )
      gradient: Gradient {
         GradientStop { position: 0.0; color: uiShadowColor }
         GradientStop { position: 1; color: "transparent" }
      }
   }


   Rectangle{
      id: panel
      z: 4
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
      height: uiSize * 2 / 3
      color: uiColor
      state: "consumption"

      readonly property int spacing: (width - incomeSelect.width - consumptionSelect.width - currencySelect.width) / 4

      CustomComboBox {
         id: currencySelect
         anchors {
            bottom: parent.bottom; left: parent.left
            leftMargin: panel.spacing
         }
         modelView: currencyModel
         isLowerOrientation: false
         maximumHeight: area.height;
         onItemSelected: currentCurrency = currentIndex
         Component.onCompleted: setCurrentIndex(settings.getDefCurrency())
      }

      Item {
         id: incomeSelect
         anchors {
            left: currencySelect.right; bottom: parent.bottom;
            leftMargin: panel.spacing
         }
         width: incomeRec.width; height: uiSize
         property bool isEnabled
         property color current: uiColor
         Rectangle {
            id: incomeRec
            anchors { centerIn: parent }
            width: incomeText.width + uiSize / 2
            height: uiSize / 3 * 2
            radius: height / 2
            color: parent.isEnabled ? parent.current : "white"
            border { color: !parent.isEnabled ? uiColor : "white"; width: uiLineWidth }
            Behavior on color { ColorAnimation{ duration: 100; easing.type: Easing.InOutQuad} }
            Text {
               id: incomeText
               anchors { centerIn: parent }
               text: lang.label( 36 )
               color: Qt.lighter( incomeRec.color, colorCheckFactor ) == "#ffffff" ? "black" : "white"
               font.pixelSize: uiFontSizeBig
            }
         }
         MouseArea {
            anchors { fill: parent }
            hoverEnabled: true
            onEntered: if ( incomeSelect.isEnabled ) incomeSelect.current = Qt.lighter( uiColor )
            onExited: incomeSelect.current = uiColor
            onClicked: {
               panel.state = "income"
            }
         }
      }

      Item {
         id: consumptionSelect
         anchors {
            left: incomeSelect.right; bottom: parent.bottom;
            leftMargin: panel.spacing
         }
         width: consumptionRec.width; height: uiSize
         property bool isEnabled
         property color current: uiColor
         Rectangle {
            id: consumptionRec
            anchors { centerIn: parent }
            width: consumptionText.width + uiSize / 2; height: uiSize / 3 * 2
            radius: height / 2
            color: parent.isEnabled ? parent.current : "white"
            border { color: !parent.isEnabled ? uiColor : "white"; width: uiLineWidth }
            Behavior on color { ColorAnimation{ duration: 100; easing.type: Easing.InOutQuad} }
            Text {
               id: consumptionText
               anchors { centerIn: parent }
               text: lang.label( 37 )
               color: Qt.lighter( consumptionRec.color, colorCheckFactor ) == "#ffffff" ? "black" : "white"
               font.pixelSize: uiFontSizeBig
            }
         }
         MouseArea {
            anchors { fill: parent }
            hoverEnabled: true
            onEntered: if ( consumptionSelect.isEnabled ) consumptionSelect.current = Qt.lighter( uiColor )
            onExited: consumptionSelect.current = uiColor
            onClicked: {
               panel.state = "consumption"
            }
         }
      }

      states: [
         State { name: "income"
            PropertyChanges { target: incomeSelect;      isEnabled: false }
            PropertyChanges { target: consumptionSelect; isEnabled: true }

            PropertyChanges { target: chartView; isIncome: true }
         },
         State { name: "consumption"
            PropertyChanges { target: incomeSelect;      isEnabled: true }
            PropertyChanges { target: consumptionSelect; isEnabled: false }

            PropertyChanges { target: chartView; isIncome: false }
         }
      ]
   }
   DateSelect {
      id: dateSelect
      onStateChanged: blockRectangle.state = state
      onDateSelected: {
         if ( type == 0 ){
            dateLabel.text = beginDay + " " + lang.label(11+beginMonth)
                  + ( beginYear === Qt.formatDateTime( currentDate, "yyyy")*1 ? '' : ' ' + beginYear )
                  + " - "
                  + endDay + " " + lang.label(11+endMonth) + " "
                  + ( endYear === Qt.formatDateTime( currentDate, "yyyy")*1 ? '' : ' ' + endYear )
            pieData.setDateRange( beginYear, beginMonth, beginDay, endYear, endMonth, endDay )
         } else {
            if ( type == 1 ){
               dateLabel.text = beginDay + " " + lang.label(11+beginMonth) + " "
                     + ( beginYear === Qt.formatDateTime( currentDate, "yyyy")*1 ? '' : ' ' + beginYear )
               pieData.setDay( beginYear, beginMonth, beginDay )
            } else if ( type == 2 ){
               dateLabel.text = lang.label(11+beginMonth) + " "
                     + ( beginYear === Qt.formatDateTime( currentDate, "yyyy")*1 ? '' : ' ' + beginYear )
               pieData.setMonth( beginYear, beginMonth )
            } else if ( type == 3 ){
               pieData.setYear( beginYear )
               dateLabel.text = beginYear
            } else if ( type == 4 ){
               pieData.setAllTime()
               dateLabel.text = lang.label(102)
            }
         }
      }
   }

   Rectangle {
      z: 7
      id: blockRectangle
      anchors { fill:parent }
      state: "closed"
      MouseArea {
         anchors.fill: parent
         propagateComposedEvents: true
         onClicked: { blockRectangle.state = "closed"; dateSelect.state = "closed" }
      }
      states: [
         State { name: "opened"
            PropertyChanges { target: blockRectangle; visible: true; color: "#80000000" }
         },
         State { name: "closed"
            PropertyChanges { target: blockRectangle; color: "transparent"; visible: false }
         }
      ]
      transitions: [
         Transition { from: "closed"; to: "opened"
            SequentialAnimation {
               PropertyAnimation { target: blockRectangle; property: "visible"; duration: 0 }
               PropertyAnimation { target: blockRectangle; property: "color"; duration: 100 }
            }
         },
         Transition { from: "opened"; to: "closed";
            SequentialAnimation {
               PropertyAnimation { target: blockRectangle; property: "color"; duration: 100 }
               PropertyAnimation { target: blockRectangle; property: "visible"; duration: 0 }
            }
         }
      ]
   }

}
