import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import "Inputs"
import "Buttons"

Rectangle {
   id: settingsWindow
   z: 11

   y: uiSize / 8 * 9
   width: uiWidth / 3 * 2 < window.width ? uiWidth / 3 * 2 : window.width
   height: column.height
   color: "white"
   state: "closed"
   border { width: uiLineWidth; color: uiLineColor }

   onStateChanged: {
      colorInputLabel.focus = false
      Qt.inputMethod.hide()
   }

   signal langChanged()

   Column {
      Repeater {
         model: 5
         Item {
            height: index == 2 ? uiSize / 2 : uiSize; width: settingsWindow.width
            Rectangle {
               anchors { left: parent.left; right: parent.right; }
               y: parent.height - 1;
               height: uiLineWidth
               color: "#CCCCCC"
            }
         }
      }
   }

   function updateSettLabels(){
      langLabel.text = lang.label(0)
      colorLabel.text = lang.label(6)
      categoryModel.setName( 0, lang.label(43) )
      langChanged()
   }

   Column {
      id: column
      width: parent.width
      CustomButton2 {
         id: langSelection
         width: parent.width; height: uiSize
         Image{
            id: langImage
            anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/Swap.svg"
         }
         Text {
            id: langLabel
            anchors { verticalCenter: parent.verticalCenter }
            x: uiSize / 48 * 52
            text: lang.label( 0 )
            font.pixelSize: uiFontSize
         }
         onClicked: {
            lang.loadLang( !lang.currentLang() )
            updateSettLabels()
         }
      }

      CustomButton2 {
         id: colorSelection
         width: parent.width; height: uiSize;
         Image{
            id: colorImage
            anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/Pencil.svg"
         }
         Text{
            id: colorLabel
            anchors { verticalCenter: parent.verticalCenter }
            x: uiSize / 12 * 13
            text: lang.label(6);
            font.pixelSize: uiFontSize
         }

         Row {
            id: colorInput
            anchors { verticalCenter: parent.verticalCenter; left: colorLabel.right; leftMargin: uiSize / 12 }
            Text {
               text: "#";
               font.weight: Font.DemiBold
               font.pixelSize: uiFontSize
            }
            TextInput {
               id: colorInputLabel
               text: settings.getColor().substring(3,9)
               font.weight: Font.DemiBold
               font.pixelSize: uiFontSize
               maximumLength: 6
               onEditingFinished:
                   if (text.length == 6) {
                      settings.setColor("#" + text)
                      uiColor = settings.getColor()
                      Qt.inputMethod.hide();
                      focus = false
                   }
               validator: RegExpValidator { regExp: /[0-9A-Fa-f]+/ }
            }
         }
         onClicked: {
            Qt.inputMethod.show();
            colorInputLabel.focus = true
         }
      }

      Item {
         id: defaultSelection
         width: parent.width; height: uiSize / 2
         Text {
            id: defaultLabel
            anchors { verticalCenter: parent.verticalCenter }
            x: uiSize / 6
            text: lang.label( 47 ) + ':'
            font.pixelSize: uiFontSize
         }

      }

      Item {
         id: defaultCategorySection
         width: parent.width; height: uiSize
         z: 2
         Image{
            id: categoryImage
            anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/Category.svg"
         }
         CustomComboBox {
            id: categoryLabel
            anchors { verticalCenter: parent.verticalCenter }
            width: uiSize * 3
            x: uiSize / 48 * 52
            modelView: categoryModel
            onItemSelected: settings.setDefCategory(currentIndex)
            Component.onCompleted: setCurrentIndex(settings.getDefCategory())
            maximumHeight: window.height - (settingsWindow.y + defaultCategorySection.y)
         }
      }

      Item {
         id: defaultCurrencySection
         width: parent.width; height: uiSize
         z: 1
         Image{
            id: currencyImage
            anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/Currency.svg"
         }
         CustomComboBox {
            id: cyrrencyLabel
            anchors { verticalCenter: parent.verticalCenter }
            x: uiSize / 48 * 52
            modelView: currencyModel
            onItemSelected: settings.setDefCurrency(currentIndex)
            Component.onCompleted: setCurrentIndex(settings.getDefCurrency())
            maximumHeight: window.height - (settingsWindow.y + defaultCurrencySection.y)
         }
      }
      Item {
         id: defaultDateSection
         width: parent.width; height: uiSize
         Image{
            id: dateImage
            anchors { verticalCenter: parent.verticalCenter } x: uiSize / 6
            height: uiSize / 3 * 2; width: height
            sourceSize { width: parent.width; height: parent.height; } smooth: false
            source: "/Icons/Date.svg"
         }
         CustomComboBox {
            id: dateCombobox
            anchors { verticalCenter: parent.verticalCenter }
            x: uiSize / 48 * 52; width: uiSize * 3
            modelView: ListModel {
               Component.onCompleted: {
                  append({ name: lang.label( 99 ) })
                  append({ name: lang.label( 100 ) })
                  append({ name: lang.label( 101 ) })
                  append({ name: lang.label( 102 ) })
                  dateCombobox.setCurrentIndex( settings.getDefDateType() )
               }
            }
            onItemSelected: settings.setDefDateType(currentIndex)
            maximumHeight: window.height - (settingsWindow.y + defaultDateSection.y)
         }
      }
   }
   
   MouseArea { z: -1;  anchors.fill: parent; onClicked: mouse.accepted = true }

   states: [
      State { name: "opened"
         PropertyChanges { target: settingsWindow; x: window.width - width }
      },
      State { name: "closed"
         PropertyChanges { target: settingsWindow; x: window.width; }
      }
   ]
   transitions: [
      Transition { from: "opened"; to: "closed"
         PropertyAnimation { target: settingsWindow; property: "x"; duration: 100 }
      },
      Transition { from: "closed"; to: "opened"
         PropertyAnimation { target: settingsWindow; property: "x"; duration: 100 }
      }
   ]
}
