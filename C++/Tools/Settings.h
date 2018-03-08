#ifndef Settings_H
#define Settings_H

#include <fstream>
#include <QObject>

#include "Color/color.h"

class Settings : public QObject
{
   Q_OBJECT
public:
   Settings();
   Q_INVOKABLE QString getColor();
   Q_INVOKABLE void setColor(QString colorQml );

   quint16 getLastTNo() const;
   void setLastTNo(const quint16& lastTNo);

   quint8 getLang() const;
public slots:
   void setLang(const quint8& lang);

public:
   void saveFile() const;

   Q_INVOKABLE quint8 getDefCategory() const;
   Q_INVOKABLE void setDefCategory(const quint8& defCategory);

   Q_INVOKABLE quint8 getDefCurrency() const;
   Q_INVOKABLE void setDefCurrency(const quint8& defCurrency);

   Q_INVOKABLE quint8 getDefDateType() const;
   Q_INVOKABLE void setDefDateType(const quint8& defDateType);

   Q_INVOKABLE QString prepareSum( quint64 sum ) const;

   enum DefaultDateType : quint8 { CurrentDay = 0, CurrentMonth = 1, CurrentYear = 2, AllTime = 3 };
private:
   std::string m_fileName;
   
   quint8 m_lang;
   
   quint8 m_defCategory, m_defCurrency;
   
   Color m_color;

   quint16 m_lastTNo;
   
   quint8 m_defDateType; 

};

#endif // Settings_H
