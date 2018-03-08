import QtQuick 2.0
import QtQuick.Window 2.1

import "qrc:/Qml/Buttons"

Rectangle {

   id: sumEditRec
   height: uiSize * 4
   width: dpi < 120 ? 320 : dpi * 2;
   state: "closed"
   enabled: visible

   readonly property string integerInput: sumIntegerInput.text
   readonly property string fractionInput: sumFractionInput.text
   property bool isIncome: true
   readonly property int currencyIndex: currencyCombobox.currentIndex
   signal okClicked

   function setData(integer, fraction, isIncomeSum, currencyNo ){
      sumIntegerInput.text = integer
      sumFractionInput.text = fraction
      isIncome = isIncomeSum
      currencyCombobox.setCurrentIndex( currencyNo )
   }

   Rectangle {
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: uiSize * 3 }
      height: uiLineWidth
      color: "#CCCCCC"
   }

   Rectangle {
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: uiSize }
      height: uiLineWidth
      color: "#CCCCCC"
   }

   CustomButton2 {
      id: signButton
      anchors { bottom: parent.bottom; bottomMargin: uiSize * 3 }
      width: parent.width / 2
      height: uiSize
      Image{
         anchors { left: parent.left; top: parent.top; margins: uiSize / 6 }
         height: uiSize / 3 * 2; width: height
         sourceSize { width: parent.width; height: parent.height; } smooth: false
         source: isIncome ? "/Icons/Income.svg" : "/Icons/Consumption.svg"
      }
      Text {
         y: uiSize / 8
         x: uiSize / 48 * 62
         text: lang.label( 73 )
         font.pixelSize: uiFontSizeSmall
         color: "#808080"
      }
      Text {
         y: uiSize / 8 * 7 - height
         x: uiSize / 48 * 62
         text: isIncome ? lang.label( 44 ) : lang.label( 45 )
         font.pixelSize: uiFontSizeBig
      }
      onClicked: { isIncome = !isIncome; }
   }
   Rectangle {
      anchors { bottom: parent.bottom; bottomMargin: uiSize * 3 }
      x: parent.width / 2
      height: uiSize
      width: uiLineWidth
      color: "#CCCCCC"
   }

   CustomButton2 {
      id: currencyButton
      anchors { bottom: parent.bottom; bottomMargin: uiSize * 3 }
      x: parent.width / 2
      width: parent.width / 2
      height: uiSize
      Image{
         anchors { left: parent.left; top: parent.top; margins: uiSize / 6 }
         height: uiSize / 3 * 2; width: height
         sourceSize { width: parent.width; height: parent.height; } smooth: false
         source: "/Icons/CurrencyGear.svg"
      }
      Text {
         y: uiSize / 8
         x: uiSize / 48 * 62
         text: lang.label( 74 )
         font.pixelSize: uiFontSize
      }
      Text {
         y: uiSize / 8 * 7 - height
         x: uiSize / 48 * 62
         text: lang.label( 75 )
         font.pixelSize: uiFontSize
      }
      onClicked: currencyManage.state = "opened"

   }

   Item {
      id: sumSection
      y: uiSize * 1.5
      height: uiSize
      z: 5
      Text {
         id: signLabel
         anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: uiSize / 6 }
         text: isIncome ? "+" : '-'
         font.pixelSize: uiFontSizeBig
      }
      TextInput {
         id: sumIntegerInput
         anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: uiSize / 2 }
         height: uiSize
         width: font.pixelSize * 7.5
         horizontalAlignment:  TextInput.AlignRight
         verticalAlignment: TextInput.AlignVCenter
         font.pixelSize: uiFontSizeBig
         validator: DoubleValidator {
            top: 92233720368547;
            bottom: 0 ;
            locale: "C";
            decimals: 0;
            notation: DoubleValidator.StandardNotation;
         }
      }
      Rectangle {
         id: sumIntegerRec
         anchors { bottom: parent.bottom; horizontalCenter: sumIntegerInput.horizontalCenter }
         width: sumIntegerInput.width
         height: uiLineWidth
         color: uiColor
      }
      Text {
         id: sumDot
         anchors { left: sumIntegerInput.right; leftMargin: uiSize * 0.1; verticalCenter: parent.verticalCenter; }
         text: ','
         font.pixelSize: uiFontSizeBig
      }
      TextInput {
         id: sumFractionInput
         anchors { left: sumDot.right;  }
         height: uiSize
         width: uiSize
         horizontalAlignment: TextInput.AlignHCenter
         verticalAlignment:   TextInput.AlignVCenter
         font.pixelSize:  uiFontSizeBig
         validator: IntValidator {
            top: 99;
            bottom: 0;
            locale: "C";
         }
      }
      Rectangle {
         id: sumFractionRec
         anchors { bottom: parent.bottom; horizontalCenter: sumFractionInput.horizontalCenter }
         width: uiSize *  0.45
         height: uiLineWidth
         color: uiColor
      }

   }
   CustomComboBox {
      id: currencyCombobox
      anchors { right: parent.right; bottom: parent.bottom; bottomMargin: uiSize * 1.5; rightMargin: uiSize / 6 }
      width: uiSize * 2
      modelView: currencyModel
      maximumHeight: parent.parent.height - parent.y - currencyCombobox.y
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
         sumIntegerInput.text = ""
         sumFractionInput.text = ""
         currencyCombobox.setCurrentIndex(0)
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
         if ( sumIntegerInput.text * 1 != 0 ){
            okClicked()
            sumIntegerInput.text = ""
            sumFractionInput.text = ""
            currencyCombobox.setCurrentIndex(0)
            Qt.inputMethod.hide();
            parent.state = "closed"
         }
      }
   }

   states: [
      State { name: "opened"
         PropertyChanges { target: sumEditRec; visible: true;  opacity: 1; scale: 1 }
      },
      State { name: "closed"
         PropertyChanges { target: sumEditRec; visible: false; opacity: 0; scale: 0.8 }
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
