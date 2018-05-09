QT += quick widgets svg charts
CONFIG += c++17 thread

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += C++/main.cpp \
    C++/Tools/lang.cpp \
    C++/Tools/date.cpp \
    C++/Storage/pay.cpp\
    C++/Storage/paylist.cpp \
    C++/Tools/Strings.cpp \
    C++/Tools/Settings.cpp \
    C++/Storage/tpay.cpp \
    C++/Storage/tpaylist.cpp \
    C++/Storage/LineSeries/line.cpp \
    C++/Storage/LineSeries/lineseriesmodel.cpp \
    C++/Storage/PieSeries/pieslice.cpp \
    C++/Storage/PieSeries/pieseries.cpp \
    C++/Storage/PieSeries/piemodel.cpp \
    C++/Tools/Color/color.cpp \
    C++/Storage/Category/categorymodel.cpp \
    C++/Storage/Category/category.cpp

RESOURCES += Resources.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    C++/Tools/lang.h \
    C++/Tools/date.h \
    C++/Storage/pay.h \
    C++/Storage/paylist.h \
    C++/Tools/Strings.h \
    C++/Tools/Settings.h \
    C++/Storage/tpay.h \
    C++/Storage/tpaylist.h \
    C++/Storage/LineSeries/line.h \
    C++/Storage/LineSeries/lineseriesmodel.h \
    C++/Storage/PieSeries/pieslice.h \
    C++/Storage/PieSeries/pieseries.h \
    C++/Storage/PieSeries/piemodel.h \
    C++/Tools/Color/color.h \
    C++/Tools/Color/colordata.h \
    C++/Storage/Category/categorymodel.h \
    C++/Storage/Category/category.h

DISTFILES += \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
