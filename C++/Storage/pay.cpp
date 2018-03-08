#include "pay.h"


Pay::Pay()
    : m_sum( EMPTY ),
      m_date(),
      m_currency( EMPTY ),
      m_category( EMPTY ),
      m_flags( PayFlags::NotDeleted ),
      m_description()
{
}


Pay::Pay(

        const qint64& sum,
        const Date& date,
        const quint8& currency,
        const quint8& category,
        const quint16& tNo,
        const QString& description,
        const PayFlags& flags

        )
    : m_sum( sum ),
      m_date( date ),
      m_tNo( tNo ),
      m_currency( currency ),
      m_category( category ),
      m_flags( flags ),
      m_description( description )
{
}


Pay::Pay(const Pay& other)
    : m_sum( other.m_sum ),
    m_date (other.m_date ),
    m_currency( other.m_currency),
    m_category( other.m_category),
    m_flags( other.m_flags ),
    m_description( other.m_description)
{
}

Pay& Pay::operator =(const Pay& other)
{
   m_sum         = other.m_sum;
   m_date        = other.m_date;
   m_currency    = other.m_currency;
   m_category    = other.m_category;
   m_description = other.m_description;
   m_flags       = other.m_flags;
   return *this;
}

qint64 Pay::getSum() const
{
   return m_sum;
}

void Pay::setSum(const qint64& sum)
{
   m_sum = sum;
}

QString Pay::getDescription() const
{
    return m_description;
}

const Date&Pay::date() const
{
    return m_date;
}


bool Pay::isFromTPay() const
{
    return m_flags.isEnabled;
}


void Pay::setDescription(const QString& description)
{
    m_description = description;
}

void Pay::setIsFromTPay(bool isFromTPay)
{
    m_flags.isEnabled = isFromTPay;
}


quint8 Pay::getFlags() const
{
    return m_flags.quint8Convertion;
}

void Pay::setFlags(quint8 boolField)
{
    m_flags.quint8Convertion = boolField;
}

quint16 Pay::getTNo() const
{
    return m_tNo;
}

void Pay::setTNo(const quint16& tNo)
{
    m_tNo = tNo;
}

quint8 Pay::getCurrency() const
{
    return m_currency;
}

void Pay::setCurrency(const quint8& currency)
{
    m_currency = currency;
}

quint8 Pay::getCategory() const
{
   return m_category;
}

void Pay::setCategory(const quint8& category)
{
   m_category = category;
}

Date Pay::getDate() const
{
   return m_date;
}

void Pay::setDate(const Date& date)
{
   m_date = date;
}
