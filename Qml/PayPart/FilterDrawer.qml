import QtQuick 2.9
import QtQuick.Controls 2.2

import "qrc:/Qml/Buttons"

Rectangle {
   id: filterDrawer
   height: window.height
   color: "white"
   width:  uiSize * 3.5

   property alias categoryResetButton: categoryResetButton
   state: "closed"

   function updateLabels(){
      uselessText.text = lang.label( 34 )
      incomeLabel.text = lang.label( 36 )
      consumptionLabel.text = lang.label( 37 )
      categoryFilterLabel.text = lang.label( 40 )
      currencyFilterLabel.text = lang.label( 41 )
      resetText.text = lang.label( 42 )
   }

   Column {
       Repeater {
          model: 5
          Item {
             height: uiSize; width: filterDrawer.width
             Rectangle {
                anchors { left: parent.left; right: parent.right; }
                y: uiSize - 1;
                height: uiLineWidth
                color: "#CCCCCC"
             }

          }

       }
   }

   Item {
      id: uselessRow
      anchors { top:parent.top; left:parent.left; right: parent.right;  }
      height: uiSize
      Text {
         id: uselessText
         anchors.centerIn: parent
         text: lang.label( 34 )
         font.pixelSize: uiFontSize
         font.hintingPreference: font.hintingPreference
      }
   }


   Item {
      id: sumSelectionColumn
      anchors { top: uselessRow.bottom; left: parent.left; right: parent.right; }

      height: incomeSelection.height + consumptionSelection.height

      Item {
         id: incomeSelection

         anchors { top: parent.top; left: parent.left; right: parent.right; }

         width: uiSize * 2.8
         height: uiSize

         Rectangle {
            id: checkBoxIncome
            anchors { top: parent.top; left: parent.left; bottom: parent.bottom; margins: uiSize / 48 * 16  }
            width: height
            border { color: uiColor; width: uiLineWidth }
            Image {
               visible: false
               id: incomeCheckImage
               anchors { fill: parent; margins: parent.width * 0.1 } smooth: false
               source: "/Icons/CheckMark.svg"
            }
         }
         Text {
            id: incomeLabel
            anchors { verticalCenter: parent.verticalCenter; }
            x: uiSize
            text: lang.label( 36 )
            font.pixelSize: uiFontSize
         }
         MouseArea {
            anchors.fill: parent
            onClicked: {
               if ( incomeCheckImage.visible ) {
                          payModel.selectSumSignRemove( true )
                       } else {
                          payModel.selectSumSign( true )
                       }
               incomeCheckImage.visible = !incomeCheckImage.visible
               resetButton.update()
            }
         }

      }

      Item {
         id: consumptionSelection

         anchors { top: incomeSelection.bottom; left: parent.left; right: parent.right; }

         width: uiSize * 2.8
         height: uiSize

         Rectangle {
            id: checkBoxConsumption
            anchors { top: parent.top; left: parent.left; bottom: parent.bottom; margins: uiSize / 3  }
            width: height
            border { color: uiColor; width: uiLineWidth }
            Image {
               id: consumptionCheckImage
               visible: false
               anchors { fill: parent; margins: parent.width * 0.1 } smooth: false
               source: "/Icons/CheckMark.svg"
            }
         }
         Text {
            id: consumptionLabel
            anchors { verticalCenter: parent.verticalCenter; }
            x: uiSize
            text: lang.label( 37 )
            font.pixelSize: uiFontSize
            font.hintingPreference: font.hintingPreference
         }
         MouseArea {
            anchors.fill: parent
            onClicked: {
               if ( consumptionCheckImage.visible ) {
                          payModel.selectSumSignRemove( false )
                       } else {
                          payModel.selectSumSign( false )
                       }
               consumptionCheckImage.visible = !consumptionCheckImage.visible
               resetButton.update()
            }
         }

      }
   }

   CustomButton {
      id: sumSelectionResetButton
      x: parent.width
      y: uiSize * 2
      height: uiSize
      width: height

      isEnabled: incomeCheckImage.visible != consumptionCheckImage.visible
      onClicked: {
         payModel.selectSumSignRemove(incomeCheckImage.visible)
         incomeCheckImage.visible = false
         consumptionCheckImage.visible = false
         resetButton.update()
      }
      Image {
         anchors { fill: parent; margins: resetButtonMargins }
         visible: parent.isEnabled
         sourceSize { width: parent.width; height: parent.height; } smooth: false
         source: "/Icons/RingedArrowMoney.svg"
      }
   }

   Item {
      id: categoryFilter

      anchors { top: sumSelectionColumn.bottom; left: parent.left; right: parent.right; }
      height: uiSize
      state: "closed"

      Image {
         anchors { verticalCenter: parent.verticalCenter; }
         x: uiSize / 24 * 7
         height: uiSize - x*2; width: height;
         sourceSize { width: parent.width; height: parent.height; } smooth: false
         source: "/Icons/Category.svg"
      }
      Text {
         id: categoryFilterLabel
         anchors { left: parent.left; right: categoryArrowImage.left; verticalCenter: parent.verticalCenter; leftMargin: uiSize }
         text: lang.label( 40 )
         font.pixelSize: uiFontSize
      }
      Image {
         id: categoryArrowImage
         anchors { top: parent.top; right: parent.right;  bottom: parent.bottom; margins: uiSize / 48 * 16 }
         width: height; sourceSize { width: parent.width; height: parent.height; } smooth: false
         source: "/Icons/Arrow.svg"
      }
      MouseArea {
         anchors.fill: parent
         onClicked: if ( parent.state == "closed" ) {
                       currencyFilter.state = "closed"
                       parent.state = "opened"
                    } else {
                       parent.state = "closed"
                    }
      }

      states: [
         State {
            name: "opened"
            PropertyChanges { target: categoryListLoader
               sourceComponent: categoryListViewComponent
               height: if ( categoryListLoader.item !== null ){
                          if ( categoryListLoader.item.list.contentHeight > filterDrawer.height ) {
                             filterDrawer.height
                          } else {
                             categoryListLoader.item.list.contentHeight
                          }
                       }
               y: if ( height > ( filterDrawer.height - categoryFilter.y ) ) {
                     filterDrawer.height - height
                  } else {
                     categoryFilter.y
                  }
               width: uiSize * 3.5
            }
            PropertyChanges { target: categoryArrowImage; rotation: 180 + 90 }
         },
         State {
            name: "closed"
            PropertyChanges { target: categoryListLoader
               sourceComponent: undefined
               height: categoryFilter.height
               width: 0
               y: categoryFilter.y
            }
            PropertyChanges { target: categoryArrowImage
               rotation: 90
            }
         }
      ]
      transitions: [
         Transition {
            from: "closed"
            to: "opened"
            ParallelAnimation {
               PropertyAnimation { target: categoryArrowImage; property: "rotation"; easing.type: Easing.InOutQuad; duration: 150 }
               SequentialAnimation {
                  PropertyAnimation { target: categoryListLoader; property: "sourceComponent"; duration: 0 }
                  PropertyAnimation { target: categoryListLoader; property: "width"; duration: 100 }
                  ParallelAnimation {
                     PropertyAnimation { target: categoryListLoader; property: "y"; duration: 100 }
                     PropertyAnimation { target: categoryListLoader; property: "height"; duration: 100 }
                  }
               }
            }
         },
         Transition {
            from: "opened"
            to: "closed"
            ParallelAnimation {
               PropertyAnimation { target: categoryArrowImage; property: "rotation"; easing.type: Easing.InOutQuad; duration: 150 }
               PropertyAnimation { target: categoryListLoader; property: "y"; duration: 100 }
               SequentialAnimation {
                  PropertyAnimation { target: categoryListLoader; property: "height"; duration: 100 }
                  PropertyAnimation { target: categoryListLoader; property: "width"; duration: 100 }
                  PropertyAnimation { target: categoryListLoader; property: "sourceComponent"; duration: 0 }
               }
            }
         }
      ]
   }

   CustomButton {
      id: categoryResetButton
      x: parent.width + categoryListLoader.width
      y: uiSize * 3
      height: uiSize
      width: height

      isEnabled: payModel.isCategorySelected()
      onClicked: {
         categoryFilter.state = "closed"
         payModel.selectionCategoryReset()
         isEnabled = false
         resetButton.update()
      }
      Image {
         anchors { fill: parent; margins: resetButtonMargins }
         visible: parent.isEnabled
         sourceSize { width: parent.width; height: parent.height; } smooth: false
         source: "/Icons/RingedArrowCategory.svg"
      }
   }


   Loader {
      id: categoryListLoader
      anchors { left: parent.right }
      z: 8
   }
   Component {
      id: categoryListViewComponent
      Rectangle {
         anchors.fill: parent

         color: "white"
         border { color: "gray"; width: 1 }
         property alias list: listView

         Rectangle {
            z: 9
            anchors { left: parent.left; }
            y: categoryFilter.y - categoryListLoader.y + 1
            height: uiSize - 2
            width: 1
            color: "white"
         }


         ListView {
            id: listView

            anchors { fill: parent; }
            clip: true
            model: categoryModel
            delegate: Item {
               id: categorySelection

               width: listView.width
               height: categoryFilter.height

               Rectangle {
                  id: categoryCheck
                  anchors { top: parent.top; left: parent.left; bottom: parent.bottom; margins: uiSize / 3  }
                  border { color: uiColor; width: uiLineWidth }
                  width: height
                  Image {
                     id: categoryCheckImage
                     visible: payModel.isCategorySelected( index )
                     anchors { fill: parent; margins: parent.width * 0.1 } smooth: false
                     sourceSize { width: parent.width; height: parent.height; }
                     source: "/Icons/CheckMark.svg"
                  }
               }
               Text {
                  anchors { left: categoryCheck.right; right: parent.right; verticalCenter: parent.verticalCenter; margins: uiSize * 0.1 }
                  clip: true
                  text: name
                  font.pixelSize: uiFontSize
               }
               MouseArea{
                  anchors.fill: parent
                  onClicked: {
                     if ( categoryCheckImage.visible ) {
                        payModel.selectionCategoryRemove( index )
                        categoryResetButton.isEnabled = payModel.isCategorySelected()
                     } else {
                        payModel.selectionCategoryAdd( index )
                        categoryResetButton.isEnabled = true
                     }
                     categoryCheckImage.visible = !categoryCheckImage.visible
                     resetButton.update()
                  }
               }
            }
            ScrollBar.vertical: ScrollBar{ size: 1 }
         }
      }
   }

   Item {
      id: currencyFilter

      anchors { top: categoryFilter.bottom; left: parent.left; right: parent.right; }
      height: uiSize

      state: "closed"
      Image {
         anchors { verticalCenter: parent.verticalCenter; }
         x: uiSize / 24 * 7
         width: uiSize - x*2; height: width;
         sourceSize { width: parent.width; height: parent.height; } smooth: false
         source: "/Icons/Currency.svg"
      }
      Text {
         id: currencyFilterLabel
         anchors.verticalCenter: parent.verticalCenter;
         x: uiSize
         clip: true
         text: lang.label( 41 )
         font.pixelSize: uiFontSize
      }
      Image {
         id: currencyArrowImage
         anchors { top: parent.top; right: parent.right;  bottom: parent.bottom; margins: uiSize / 48 * 16 }
         width: height; sourceSize { width: parent.width; height: parent.height; } smooth: false
         source: "/Icons/Arrow.svg"
      }
      MouseArea{
         anchors.fill: parent
         onClicked: if ( parent.state == "closed" ) {
                       categoryFilter.state = "closed"
                       parent.state = "opened"
                    } else {
                       parent.state = "closed"
                    }
      }
      states: [
         State {
            name: "opened"
            PropertyChanges {
               target: currencyListLoader
               sourceComponent: currencyListViewComponent
               height: if ( currencyListLoader.item !== null ){
                          if ( currencyListLoader.item.list.contentHeight > filterDrawer.height ) {
                             filterDrawer.height
                          } else {
                             currencyListLoader.item.list.contentHeight
                          }
                       }
               y: if ( height > ( filterDrawer.height - currencyFilter.y ) ) {
                     filterDrawer.height - height
                  } else {
                     currencyFilter.y
                  }
               width: filterDrawer.width * 0.7
            }
            PropertyChanges { target: currencyArrowImage; rotation: 180 + 90 }
         },
         State {
            name: "closed"
            PropertyChanges { target: currencyListLoader
               sourceComponent: undefined
               height: currencyFilter.height
               width: 0
               y: currencyFilter.y
            }
            PropertyChanges { target: currencyArrowImage
               rotation: 90
            }
         }
      ]
      transitions: [
         Transition {
            from: "closed"
            to: "opened"
            ParallelAnimation {
               PropertyAnimation { target: currencyArrowImage; property: "rotation"; easing.type: Easing.InOutQuad; duration: 150 }
               SequentialAnimation {
                  PropertyAnimation { target: currencyListLoader; property: "sourceComponent"; duration: 0 }
                  PropertyAnimation { target: currencyListLoader; property: "width"; duration: 100 }
                  ParallelAnimation {
                     PropertyAnimation { target: currencyListLoader; property: "y"; duration: 100 }
                     PropertyAnimation { target: currencyListLoader; property: "height"; duration: 100 }
                  }
               }
            }
         },
         Transition {
            from: "opened"
            to: "closed"
            ParallelAnimation {
               PropertyAnimation { target: currencyArrowImage; property: "rotation"; easing.type: Easing.InOutQuad; duration: 150 }
               PropertyAnimation { target: currencyListLoader; property: "y"; duration: 100 }
               SequentialAnimation {
                  PropertyAnimation { target: currencyListLoader; property: "height"; duration: 100 }
                  PropertyAnimation { target: currencyListLoader; property: "width"; duration: 100 }
                  PropertyAnimation { target: currencyListLoader; property: "sourceComponent"; duration: 0 }
               }
            }
         }
      ]
   }


   CustomButton {
      id: currencyResetButton
      x: parent.width + currencyListLoader.width
      y: uiSize * 4
      height: uiSize
      width: height

      isEnabled: payModel.isCurrencySelected()
      onClicked: {
         currencyFilter.state = "closed"
         payModel.selectionCurrencyReset()
         isEnabled = false
         resetButton.update()
      }
      Image {
         anchors { fill: parent; margins: resetButtonMargins }
         visible: parent.isEnabled
         sourceSize { width: parent.width; height: parent.height; } smooth: false;
         source: "/Icons/RingedArrowCurrency.svg"
      }
   }

   Loader {
      id: currencyListLoader
      anchors { left: currencyFilter.right; }

      z: 10
   }
   Component {
      id: currencyListViewComponent
      Rectangle {
         anchors.fill: parent

         color: "white"
         property alias list: listView

         border { color: "gray"; width: 1 }
         Rectangle {
            z: 11
            anchors { left: parent.left; }
            y: currencyFilter.y - currencyListLoader.y  + 1
            height: uiSize - 2
            width: 1
            color: "white"
         }
         ListView {
            id: listView

            anchors { fill: parent; }
            clip: true
            model: currencyModel
            delegate: Item {
               id: currencySelection

               width: listView.width
               height: currencyFilter.height

               Rectangle {
                  id: currencyCheck
                  anchors { top: parent.top; left: parent.left; bottom: parent.bottom; margins: uiSize / 3 }
                  border.width: uiLineWidth
                  border.color: uiColor
                  width: height
                  Image {
                     id: currencyCheckImage
                     visible: payModel.isCurrencySelected( index )
                     anchors { fill: parent; margins: parent.width * 0.1 }
                     sourceSize { width: parent.width; height: parent.height; } smooth: false
                     source: "/Icons/CheckMark.svg"
                  }
               }
               Text {
                  anchors { left: currencyCheck.right; right: parent.right; verticalCenter: parent.verticalCenter; margins: uiSize * 0.1 }
                  clip: true
                  text: name
                  font.pixelSize: uiFontSize
               }
               MouseArea {
                  anchors.fill: parent
                  onClicked: {
                     if ( currencyCheckImage.visible ) {
                        payModel.selectionCurrencyRemove( index )
                        currencyResetButton.isEnabled = payModel.isCurrencySelected()
                     } else {
                        payModel.selectionCurrencyAdd( index )
                        currencyResetButton.isEnabled = true
                     }
                     currencyCheckImage.visible = !currencyCheckImage.visible
                     resetButton.update()
                  }
               }
            }
            ScrollBar.vertical: ScrollBar{ size: 1 }
         }
      }
   }

   Item {
      id: resetButton
      anchors { top: currencyFilter.bottom; left: parent.left; right: parent.right; }
      height: uiSize
      property bool isEnabled: false
      Text {
         id: resetText
         anchors.centerIn: parent
         text: lang.label( 42 )
         color: resetButton.isEnabled ? "red" : "gray"
         font.pixelSize: uiFontSize
      }
      MouseArea {
         anchors.fill: parent
         onClicked: if ( parent.isEnabled ){
            incomeCheckImage.visible = false
            consumptionCheckImage.visible = false
            categoryFilter.state = "closed"
            currencyFilter.state = "closed"
            categoryResetButton.isEnabled = false
            currencyResetButton.isEnabled = false
            payModel.selectionReset()
            parent.isEnabled = false
         }
      }


      function update(){
         if ( incomeCheckImage.visible != consumptionCheckImage.visible || categoryResetButton.isEnabled || currencyResetButton.isEnabled ){
            resetButton.isEnabled = true
         } else {
            resetButton.isEnabled = false
         }
      }
   }

   MouseArea { z: -1;  anchors.fill: parent; onClicked: mouse.accepted = true }

   states: [
      State { name: "opened"
         PropertyChanges { target: filterDrawer; x: 0 }
      },
      State { name: "closed"
         PropertyChanges { target: filterDrawer;   x: - width }
         PropertyChanges { target: categoryFilter; state: "closed"}
         PropertyChanges { target: currencyFilter; state: "closed"}
      }
   ]
   transitions: [
      Transition { from: "opened"; to: "closed"
         PropertyAnimation { target: filterDrawer; property: "x"; duration: 100 }
      },
      Transition { from: "closed"; to: "opened"
         PropertyAnimation { target: filterDrawer; property: "x"; duration: 100 }
      }
   ]
}
