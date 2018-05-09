#include <QtWidgets/QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "Storage/paylist.h"
#include "Storage/tpaylist.h"
#include "Storage/Category/categorymodel.h"
#include "Storage/LineSeries/lineseriesmodel.h"
#include "Storage/PieSeries/piemodel.h"
#include "Tools/lang.h"
#include "Tools/Settings.h"
#include "Tools/Strings.h"

int main(int argc, char *argv[])
{
   QApplication app(argc, argv);


   CategoryModel categoryModel{"category"};
   Strings       currencyModel{"currency"};

   Settings settings;

   Lang lang( LangMode(settings.getLang()) );

   QObject::connect( &lang, SIGNAL( changed(quint8) ), &settings, SLOT( setLang(quint8) ) );

   if ( !categoryModel.rowCount() ){
       categoryModel.addCategory( lang.label(43), "#cccccc" );
   }

   PayList  payModel{ &categoryModel, &currencyModel };

   QObject::connect( &categoryModel, SIGNAL( removed(quint8) ), &payModel, SLOT( categoryRemoved(quint8) ) );
   QObject::connect( &categoryModel, SIGNAL( changed(quint8) ), &payModel, SLOT( categoryChanged(quint8) ) );

   QObject::connect( &currencyModel, SIGNAL( removed(quint8) ), &payModel, SLOT( currencyRemoved(quint8) ) );
   QObject::connect( &currencyModel, SIGNAL( renamed(quint8) ), &payModel, SLOT( currencyRenamed(quint8) ) );


   LineSeriesModel barModel{ &payModel, &currencyModel, &lang };

   QObject::connect( &payModel, SIGNAL( payAdded(const Pay*) ),   &barModel, SLOT( payAdded(const Pay*) ) );
   QObject::connect( &payModel, SIGNAL( payRemoved(const Pay*) ), &barModel, SLOT( payRemoved(const Pay*) ) );

   QObject::connect( &currencyModel, SIGNAL( removed(quint8) ), &barModel, SLOT( currencyRemoved(quint8) ) );
   QObject::connect( &currencyModel, SIGNAL( added(quint8) ),   &barModel, SLOT( currencyAdded(quint8) ) );


   PieModel pieModel{ &payModel, &categoryModel, &currencyModel };

   QObject::connect( &payModel, SIGNAL( payAdded(const Pay*) ),   &pieModel, SLOT( payAdded(const Pay*) ) );
   QObject::connect( &payModel, SIGNAL( payRemoved(const Pay*) ), &pieModel, SLOT( payRemoved(const Pay*) ) );

   QObject::connect( &categoryModel, SIGNAL( removed(quint8) ), &pieModel, SLOT( categoryRemoved(quint8) ) );
   QObject::connect( &categoryModel, SIGNAL( added(quint8) ), &pieModel, SLOT( categoryAdded(quint8) ) );

   QObject::connect( &currencyModel, SIGNAL( removed(quint8) ), &pieModel, SLOT( currencyRemoved(quint8) ) );
   QObject::connect( &currencyModel, SIGNAL( added(quint8) ),   &pieModel, SLOT( currencyAdded(quint8) ) );


   TPayList tPayModel( &payModel, &categoryModel, &currencyModel, &settings );

   QObject::connect( &tPayModel, SIGNAL( tRemoved(quint16) ), &payModel, SLOT( tRemoved(quint16) ) );
   QObject::connect( &categoryModel, SIGNAL( removed(quint8) ), &tPayModel, SLOT( categoryRemoved(quint8) ) );
   QObject::connect( &categoryModel, SIGNAL( changed(quint8) ), &tPayModel, SLOT( categoryChanged(quint8) ) );

   QObject::connect( &currencyModel, SIGNAL( removed(quint8) ), &tPayModel, SLOT( currencyRemoved(quint8) ) );
   QObject::connect( &currencyModel, SIGNAL( renamed(quint8) ), &tPayModel, SLOT( currencyRenamed(quint8) ) );


   QQmlApplicationEngine engine;
   QQmlContext *ctxt = engine.rootContext();


   ctxt->setContextProperty( "categoryModel", QVariant::fromValue( &categoryModel ) );
   ctxt->setContextProperty( "currencyModel", QVariant::fromValue( &currencyModel ) );

   ctxt->setContextProperty( "lang", QVariant::fromValue( &lang ));
   ctxt->setContextProperty( "settings", QVariant::fromValue( &settings ) );
   Date dateInfo;

   ctxt->setContextProperty( "dateInfo", QVariant::fromValue( &dateInfo ) );

   ctxt->setContextProperty( "payModel",   QVariant::fromValue( &payModel) );
   ctxt->setContextProperty( "tPayModel",  QVariant::fromValue( &tPayModel ) );

   ctxt->setContextProperty( "barModel", QVariant::fromValue( &barModel ) );
   ctxt->setContextProperty( "pieData",    QVariant::fromValue( &pieModel   ) );

   engine.load(QUrl(QStringLiteral("qrc:/Qml/main.qml")));
   if ( engine.rootObjects().isEmpty() ) {
       return -1;
   }
   return app.exec();
}
