#include "Settings.h"


#define P_C_STR(a) reinterpret_cast< char* >(&(a)), sizeof(a)
#define C_STR(a) reinterpret_cast< const char* >(&(a)), sizeof(a)

Settings::Settings()
{
    m_fileName = "settings";
    std::fstream file( m_fileName, std::ios_base::in | std::ios_base::binary );
    if ( file.is_open() ){
        file.read( P_C_STR( m_lang ) );
        file.read( P_C_STR( m_lastTNo ) );
        quint32 argb;
        file.read( P_C_STR( argb ) );
        m_color.setARGB(argb);
        file.read( P_C_STR( m_defCategory ) );
        file.read( P_C_STR( m_defCurrency ) );
        file.read( P_C_STR( m_defDateType ) );
        file.close();
    } else {
        m_lang = 0;
        m_lastTNo = 0;
        m_color = QString("#408000");
        m_defCategory = 0;
        m_defCurrency = 0;
        m_defDateType = 1;
    }
}

QString Settings::getColor()
{
    return m_color.toString();
}

void Settings::setColor(QString colorQml)
{
    m_color = colorQml;
    this->saveFile();
}



quint16 Settings::getLastTNo() const
{
    return m_lastTNo;
}

void Settings::setLastTNo(const quint16& lastTNo)
{
    m_lastTNo = lastTNo;
    this->saveFile();
}

quint8 Settings::getLang() const
{
    return m_lang;
}

void Settings::setLang(const quint8& lang)
{
    m_lang = lang;
    this->saveFile();
}

void Settings::saveFile() const
{
    std::fstream file( m_fileName, std::ios_base::out | std::ios_base::binary );
    file.write( C_STR( m_lang ) );
    file.write( C_STR( m_lastTNo) );
    quint32 color = m_color.argb();
    file.write( C_STR( color ) );
    file.write( C_STR( m_defCategory ) );
    file.write( C_STR( m_defCurrency ) );
    file.write( C_STR( m_defDateType ) );
}

quint8 Settings::getDefCategory() const
{
    return m_defCategory;
}

void Settings::setDefCategory(const quint8& defCategory)
{
    m_defCategory = defCategory;
    this->saveFile();
}

quint8 Settings::getDefCurrency() const
{
    return m_defCurrency;
}

void Settings::setDefCurrency(const quint8& defCurrency)
{
    m_defCurrency = defCurrency;
    this->saveFile();
}

quint8 Settings::getDefDateType() const
{
    return m_defDateType;
}

void Settings::setDefDateType(const quint8& defDateType)
{
    m_defDateType = defDateType;
    this->saveFile();
}

QString Settings::prepareSum( quint64 sum) const
{
    auto sumStr = QString::number( sum );
    for ( qint8 i = sumStr.length()-3; i >0; i-=3)
    {
        sumStr.insert( i, ' ' );
    }
    return sumStr;
}
