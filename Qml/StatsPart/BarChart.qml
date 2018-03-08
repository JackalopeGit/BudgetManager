import QtQuick 2.0
import QtCharts 2.2
import QtGraphicalEffects 1.0

import "qrc:/Qml/Inputs"
import "qrc:/Qml/Buttons"

Item {
   id: area
   readonly property int currencyNo: currencySelect.currentIndex
   onCurrencyNoChanged: chart.updateSeries()
   Connections {
      target: barModel
      onUpdated: chart.updateSeries()
      onListChanged: if (area.currencyNo == currencyNo) chart.updateSeries()
   }

   Flickable {
      clip: true
      height: parent.height - panel.height
      width: parent.width
      contentWidth: chart.width
      contentHeight: chart.height
      boundsBehavior: Flickable.StopAtBounds
      ChartView {
         id: chart
         height: swipeView.height - panel.height
         width: xAxis.count * uiSize * 3 + uiSize * 4
         //legend.alignment: Qt.AlignBottom
         legend.visible: false
         antialiasing: true
         //animationOptions: ChartView.AllAnimations

         BarSeries {
            id: barSeries
            axisX: BarCategoryAxis { id: xAxis }
            BarSet { id: incomeBarSet;  label: lang.label(36); color: uiIncomeColor  }
            BarSet { id: expenceBarSer; label: lang.label(37); color: uiExpenceColor }
         }


         function updateSeries() {
            incomeBarSet.values = barModel.incomeList(currencyNo)
            expenceBarSer.values = barModel.expenceList(currencyNo)
            xAxis.categories = barModel.dateList(currencyNo)
            var maxValue = barModel.maxValue(currencyNo) * 1.1
            barSeries.axisY.max = maxValue - (maxValue % 1)
            barSeries.axisY.min = 0
            barSeries.axisY.minorTickCount = 3
            barSeries.axisY.tickCount = chart.height / (uiSize / 3 * 4 )


         }
      }
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

      property int spacing: width - dateButton.width - currencySelect.width - barTypeSelect.width
      Row {
         id: panelRow
         anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom } height: uiSize
         spacing: parent.spacing / 4
         Item {
            id: dateButton
            z: 3;
            x: uiSize / 3
            width: dateButtonRec.width
            height: uiSize
            Rectangle {
               id: dateButtonRec;
               anchors.centerIn: parent
               width: dateLabel.width + uiSize / 2; height: uiSize / 3 * 2
               border { color: uiColor; width: uiLineWidth }
               radius: height / 2
            }
            Text {
               id: dateLabel
               anchors { centerIn: parent }
               text:          {
                  switch ( settings.getDefDateType() ) {
                  case(0):
                     barModel.setSelection( barTypeSelect.currentIndex,
                                           Qt.formatDateTime(currentDate,"yyyy")*1,
                                           Qt.formatDateTime(currentDate,"M")*1,
                                           Qt.formatDateTime(currentDate,"d")*1,
                                           Qt.formatDateTime(currentDate,"yyyy")*1,
                                           Qt.formatDateTime(currentDate,"M")*1,
                                           Qt.formatDateTime(currentDate,"d")*1);

                     return Qt.formatDateTime(currentDate,"d") + ' ' + lang.label(11+Qt.formatDateTime(currentDate, "M")*1)

                  case (1):
                     barModel.setSelection( barTypeSelect.currentIndex,
                                           Qt.formatDateTime(currentDate,"yyyy")*1,
                                           Qt.formatDateTime(currentDate,"M")*1,
                                           1,
                                           Qt.formatDateTime(currentDate,"yyyy")*1,
                                           Qt.formatDateTime(currentDate,"M")*1,
                                           dateInfo.daysInMonth(Qt.formatDateTime(currentDate,"yyyy")*1,
                                                                Qt.formatDateTime(currentDate,"M")*1) );

                     return lang.label(100) + ", " + lang.label(11+Qt.formatDateTime(currentDate, "MM")*1)

                  case(2):
                     barModel.setSelection( barTypeSelect.currentIndex,
                                           Qt.formatDateTime(currentDate,"yyyy")*1,
                                           1,
                                           1,
                                           Qt.formatDateTime(currentDate,"yyyy")*1,
                                           12,
                                           dateInfo.daysInMonth(Qt.formatDateTime(currentDate,"yyyy")*1,
                                                                Qt.formatDateTime(currentDate,"M")*1) );

                     return lang.label(101) + ", " + Qt.formatDateTime(currentDate, "yyyy")

                  case(3):
                     /*pieData.setPieAllTime()

                     return lang.label(102)*/
                     return "unsupported"
                  }
               }
               font.pixelSize: uiFontSize
            }
            MouseArea {
               anchors.fill: parent
               onClicked: { dateSelect.state = "opened"; blockRectangle.state = "opened"; }
            }
         }

         CustomComboBox {
            id: currencySelect
            modelView: currencyModel
            isLowerOrientation: false
            maximumHeight: area.height;
            //onItemSelected: currencyNo = currentIndex
            Component.onCompleted: setCurrentIndex(settings.getDefCurrency())
         }
         CustomComboBox {
            id: barTypeSelect
            maximumHeight: uiSize * 3.5
            width: uiSize * 2.4
            isLowerOrientation: false
            modelView: ListModel {
               Component.onCompleted: {
                  append({ name: lang.label( 108 ) })
                  append({ name: lang.label( 107 ) })
                  append({ name: lang.label( 106 ) })
                  barTypeSelect.setCurrentIndex( settings.getDefDateType() > 2 ? 2 : settings.getDefDateType() )
               }
            }
            onItemSelected: barModel.setDateMode( barTypeSelect.currentIndex );
         }
      }
   }
   DateSelect {
      id: dateSelect
      onStateChanged: blockRectangle.state = state
      onDateSelected: {
         switch( type ){
         case(0):
            barModel.setSelection( barTypeSelect.currentIndex,
                                  beginYear, beginMonth, beginDay,
                                  endYear, endMonth, endDay );

            dateLabel.text = beginDay + " " + lang.label(11+beginMonth)
                  + ( beginYear === Qt.formatDateTime( currentDate, "yyyy")*1 ? '' : ' ' + beginYear )
                  + " - "
                  + endDay + " " + lang.label(11+endMonth) + " "
                  + ( endYear === Qt.formatDateTime( currentDate, "yyyy")*1 ? '' : ' ' + endYear )

            break;
         case(1):
            barModel.setSelection( barTypeSelect.currentIndex,
                                  beginYear, beginMonth, beginDay,
                                  beginYear, beginMonth, beginDay );

            dateLabel.text = beginDay + " " + lang.label(11+beginMonth) + " "
                  + ( beginYear === Qt.formatDateTime( currentDate, "yyyy")*1 ? '' : ' ' + beginYear )

            break;
         case(2):
            barModel.setSelection( barTypeSelect.currentIndex,
                                  beginYear, beginMonth, 0,
                                  beginYear, beginMonth, dateInfo.daysInMonth(beginYear, beginMonth) );

            dateLabel.text = lang.label(11+beginMonth) + " "
                  + ( beginYear === Qt.formatDateTime( currentDate, "yyyy")*1 ? '' : ' ' + beginYear )

            break;
         case(3):
            barModel.setSelection( barTypeSelect.currentIndex,
                                  beginYear, 1, 0,
                                  beginYear, 12, dateInfo.daysInMonth(beginYear, beginMonth) );

            dateLabel.text = beginYear

            break;
         case(4):
            /*barTypeSelect.setCurrentIndex( 0 )
           barModel.setSelection( barTypeSelect.currentIndex,
                                       beginYear, 1, 0,
                                       beginYear, 12, dateInfo.daysInMonth(beginMonth) );
               dateLabel.text = lang.label(102)*/
            break;
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
