import QtQuick 2.9
import QtGraphicalEffects 1.0

import "StatsPart"
import "qrc:/Qml/Inputs"
import "qrc:/Qml/Buttons"
Item {
   id: area

   onWidthChanged: {
      ratioChartPage.kludgeUpdateRatioRec(width)
   }

   Flickable {
      anchors { fill: parent }

      contentHeight: pieChart.height + ratioChartPage.height + barChart.height
      contentWidth: pieChart.width//lineChart.width

      boundsBehavior: Flickable.StopAtBounds


      PieChart {
         id: pieChart
         z: 2
         width: area.width
         height: swipeView.height
      }

      RatioChart {
         id: ratioChartPage
         y: pieChart.height
         width: pieChart.width
      }

      BarChart {
         id: barChart
         y: pieChart.height + ratioChartPage.height
         width: pieChart.width
         height: swipeView.height
      }
   }

}
