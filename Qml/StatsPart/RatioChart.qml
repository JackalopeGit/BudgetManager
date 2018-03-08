import QtQuick 2.0

Rectangle {
   id: ratioChartPage
   height: uiSize / 2 * 7
   width: parent.width;

   readonly property int currencyNo: pieChart.currentCurrency

   onCurrencyNoChanged: updateRatios()

   Component.onCompleted: updateRatios()

   Connections {
      target: pieData
      onIncomeRatioChanged: updateRatios()
   }

   function kludgeUpdateRatioRec(newWidth) {
      totalRatio.progressWidth = newWidth - uiSize * 4 / 3
      incomeRatioRec.width = pieData.incomeRatioCurrency( currencyNo ) < 1 ?
               totalRatio.progressWidth : totalRatio.progressWidth / pieData.incomeRatioCurrency( currencyNo )

      expenceRatioRec.width = pieData.incomeRatioCurrency( currencyNo ) < 1 ?
               totalRatio.progressWidth * pieData.incomeRatioCurrency( currencyNo ) : totalRatio.progressWidth
   }

   function updateRatioRec() {
      incomeRatioRec.width = pieData.incomeRatioCurrency( currencyNo ) < 1 ?
               totalRatio.progressWidth : totalRatio.progressWidth / pieData.incomeRatioCurrency( currencyNo )

      expenceRatioRec.width = pieData.incomeRatioCurrency( currencyNo ) < 1 ?
               totalRatio.progressWidth * pieData.incomeRatioCurrency( currencyNo ) : totalRatio.progressWidth
   }

   function updateRatios(){
      updateRatioRec()
      totalRatioRec.color = balanceRec.color =Qt.rgba( pieData.incomeRatioCurrency( currencyNo ),
                                                 1 - pieData.incomeRatioCurrency( currencyNo )/2, 0, 1 )

      totalRatioLabel.text = Math.round(pieData.incomeRatioCurrency( currencyNo )*10000)/100 + '%'

      totalExpenceLabel.text = "- " + settings.prepareSum( pieData.expenceSumCurrency( currencyNo )/100 )
            + ' ' + currencyModel.getName( currencyNo )

      totalIncomeLabel.text = settings.prepareSum( pieData.incomeSumCurrency( currencyNo )/100 )
            + ' ' + currencyModel.getName( currencyNo )

      var balance = ( pieData.incomeSumCurrency( currencyNo )
                     - pieData.expenceSumCurrency( currencyNo ) ) / 100

      balanceLabel.text = (balance >= 0 ? settings.prepareSum( balance ) : "- " + settings.prepareSum( -balance ))
            + ' ' + currencyModel.getName( currencyNo )
   }

   Rectangle {
      id: expenceLabelRec
      anchors { left: ratioRow.left; verticalCenter: ratioRow.verticalCenter; leftMargin: -ratioRow.spacing }
      width: totalRatioRec.x + radius + totalRatioRec.radius + ratioRow.spacing
      height: uiSize / 5 * 3
      radius: height / 4
      color: uiExpenceColor
   }
   Rectangle {
      anchors { right: ratioRow.right; verticalCenter: ratioRow.verticalCenter; rightMargin: -ratioRow.spacing }
      width: ratioRow.width - expenceLabelRec.width + radius + totalRatioRec.radius + ratioRow.spacing
      height: uiSize / 5 * 3
      radius: height / 4
      color: uiIncomeColor
   }

   Row {
      id: ratioRow
      y: uiSize / 8
      anchors { horizontalCenter: parent.horizontalCenter }
      spacing: uiSize / 4
      Text {
         anchors { verticalCenter: parent.verticalCenter }
         text: lang.label(103)
         font.pixelSize: uiFontSize
         color: Qt.lighter( uiExpenceColor , colorCheckFactor ) == "#ffffff" ? "black" : "white"
      }
      Rectangle{
         id: totalRatioRec
         width: totalRatioLabel.width + uiSize/6
         height: uiSize / 5 * 4
         radius: height / 4
         Text{
            id: totalRatioLabel
            anchors.centerIn: parent
            font { pixelSize: uiFontSizeBig; bold: true }
            color: Qt.lighter( parent.color , colorCheckFactor ) == "#ffffff" ? "black" : "white"
         }

      }

      Text{
         anchors { verticalCenter: parent.verticalCenter }
         text: lang.label(104)
         font.pixelSize: uiFontSize
         color: Qt.lighter( uiIncomeColor , colorCheckFactor ) == "#ffffff" ? "black" : "white"
      }
   }

   Rectangle {
      id: totalRatio
      y: uiSize / 3 * 4; x: uiSize / 2
      width: parent.width - uiSize
      height: uiSize
      color: "transparent"
      border { color: uiColor; width: uiSize / 12 }
      property int progressWidth: width - uiSize / 3
      Rectangle {
         id: incomeRatioRec
         z: width == totalRatio.progressWidth ? 0 : 1
         anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: uiSize / 6 }
         color: uiIncomeColor
      }
      Rectangle {
         id: expenceRatioRec
         z: width == totalRatio.progressWidth ? 0 : 1
         color: uiExpenceColor
         anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: uiSize / 6 }
      }
   }

   Rectangle {
      width: totalExpenceLabel.width + uiSize / 2
      x: if ( (uiSize / 2 + expenceRatioRec.width - width / 2) + width + uiSize / 8 <= parent.width )
         {
            if ( (uiSize / 2 + expenceRatioRec.width - width / 2) >= uiSize / 8 )
            {
               return (uiSize / 2 + expenceRatioRec.width - width / 2)
            } else return uiSize / 8
         } else return parent.width - width - uiSize / 8
      y: uiSize / 3 * 3
      height: uiSize / 3 * 2
      radius: height / 4
      color: uiExpenceColor
      border { color: "white"; width: uiLineWidth }
      Text {
         id: totalExpenceLabel
         anchors.centerIn: parent
         y: uiSize * 2
         color: Qt.lighter( parent.color , colorCheckFactor ) == "#ffffff" ? "black" : "white"
      }
   }
   Rectangle {
      width: totalIncomeLabel.width + uiSize / 2
      y: uiSize / 3 * 6
      x: if ( (uiSize / 2 + incomeRatioRec.width - width / 2) + width + uiSize / 8 <= parent.width )
         {
            if ( (uiSize / 2 + incomeRatioRec.width - width / 2) >= uiSize / 8 )
            {
               return (uiSize / 2 + incomeRatioRec.width - width / 2)
            } else return uiSize / 8
         } else return parent.width - width - uiSize / 8
      height: uiSize / 3 * 2
      radius: height / 4
      color: uiIncomeColor
      border { color: "white"; width: uiLineWidth }
      Text {
         id: totalIncomeLabel
         anchors.centerIn: parent
         y: uiSize * 2
         color: Qt.lighter( parent.color , colorCheckFactor ) == "#ffffff" ? "black" : "white"
      }
   }

   Row {
      anchors { horizontalCenter: parent.horizontalCenter }
      y: uiSize / 3 * 8
      spacing: uiSize / 4
      Text {
         anchors { verticalCenter: balanceRec.verticalCenter; }
         text: lang.label(105) + ':'
         font { pixelSize: uiFontSizeBig; bold: true }
      }
      Rectangle {
         id: balanceRec
         width: balanceLabel.width + uiSize / 2
         height: uiSize / 3 * 2
         radius: height / 4
         Text {
            id: balanceLabel
            anchors.centerIn: parent
            font { pixelSize: uiFontSizeBig; bold: true }
            color: Qt.lighter( parent.color , colorCheckFactor ) == "#ffffff" ? "black" : "white"
         }
      }
   }
}
