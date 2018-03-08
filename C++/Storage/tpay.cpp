#include "tpay.h"

TPay::TPay()
    : Pay(),
      m_period   ( 0 ),
      m_nRepeat  ( 0 ),
      m_maxRepeat( 0 )
{}

TPay::TPay( const TPay& other )

   : Pay( other ),
   m_period   ( other.m_period    ),
   m_nRepeat  ( other.m_nRepeat   ),
   m_maxRepeat( other.m_maxRepeat ),
   m_lastTDate( other.m_lastTDate )
{}

TPay::TPay(

        qint64 sum,
        quint8 currency,
        quint8 category,
        quint16 tNo,
        const Date &startDate,
        const Date& lastT,
        quint16 period,
        quint16 maxRepeat,
        quint16 nRepeat,
        PayFlags flags,
        QString description

        )

   : Pay( sum, startDate, currency, category, tNo, description, flags ),
     m_period   ( period    ),
     m_nRepeat  ( nRepeat   ),
     m_maxRepeat( maxRepeat ),
     m_lastTDate( lastT     )
{}

TPay& TPay::operator =( const TPay& other)
{
   m_sum         = other.m_sum;
   m_date        = other.m_date;
   m_currency    = other.m_currency;
   m_category    = other.m_category;
   m_description = other.m_description;
   m_flags       = other.m_flags;
   m_lastTDate   = other.m_lastTDate;
   return *this;
}

quint16 TPay::getMaxRepeat() const
{
    return m_maxRepeat;
}

void TPay::setMaxRepeat(const quint16& maxRepeat)
{
    m_maxRepeat = maxRepeat;
}

quint16 TPay::getNRepeat() const
{
    return m_nRepeat;
}

void TPay::setNRepeat(const quint16& nRepeat)
{
   m_nRepeat = nRepeat;
}

quint16 TPay::isEnabled() const
{
   return m_flags.isEnabled;
}

void TPay::setEnabled(bool isEnabled)
{
   m_flags.isEnabled = isEnabled;
}

quint16 TPay::getPeriod() const
{
    return m_period;
}

void TPay::setPeriod(const quint16 &value)
{
    m_period = value;
}

quint8 TPay::getPeriodType() const
{
    return m_flags.periodType;
}

void TPay::setPeriodType( PayFlags::PeriodType type)
{
    m_flags.periodType = type;
}

Date TPay::getLastTDate() const
{
   return m_lastTDate;
}

void TPay::setLastTDate(const Date& lastT)
{
    m_lastTDate = lastT;
}

bool TPay::isPresentBound() const
{
    return m_flags.presentBound;
}

void TPay::setPresentBound(bool isEnabled)
{
    m_flags.presentBound = isEnabled;
}

TPay& TPay::operator++()
{
    m_nRepeat++;
    return *this;
}
