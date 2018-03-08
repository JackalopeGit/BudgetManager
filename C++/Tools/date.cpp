#include "date.h"

Date::Date()
    : m_dateStruct( DateStruct::DefaultBinary )
{}

Date::Date(const quint16& year, const quint8& month, const quint8& day,
           const quint8&  hour, const quint8& minute )
    : m_dateStruct( year, month, day, hour, minute )
{}

Date::Date(const Date& other)
    : QObject(),
      m_dateStruct( other.m_dateStruct )
{}


Date::Date(const quint32& binary)
    : m_dateStruct( binary )
{}

quint32 Date::toQuint32() const
{
    return m_dateStruct.quint32Convertion;
}

quint16 Date::year() const
{
    return m_dateStruct.year;
}
quint8 Date::month() const
{
    return m_dateStruct.month;
}
quint8 Date::day() const
{
    return m_dateStruct.day;
}
quint8 Date::hour() const
{
    return m_dateStruct.hour;
}
quint8 Date::minute() const
{
    return m_dateStruct.minute;
}


quint16 Date::toMonths() const
{
    return m_dateStruct.year * MonthMax + m_dateStruct.month;
}

quint32 Date::toDays() const
{
    quint32 dayCount{0};
    for ( quint16 i{0}; i < m_dateStruct.year; i++ ){
        if ( i%4 == 0  && ((i%100 != 0) || (i%400 == 0)) ){
            dayCount += DaysInLeapYear;
        } else {
            dayCount += DaysInYear;
        }
    }

    for ( quint8 i{1}; i < m_dateStruct.month; i++ ){
        dayCount += this->daysInMonth( m_dateStruct.year, i );
    }
    return dayCount + m_dateStruct.day;
}

quint32 Date::toHours() const
{
    return this->toDays() * HoursInDay + m_dateStruct.hour;
}

quint32 Date::toMinutes() const
{
    return ( this->toDays() * HoursInDay + m_dateStruct.hour ) * MinutesInHour;
}

quint64 Date::toSeconds() const
{
    return ( this->toDays() * HoursInDay + m_dateStruct.hour )
            * MinutesInHour * SecondsInMinute;
}

Date Date::fromMonths(quint16 value)
{
    return Date().addMonths( value );
}

Date Date::fromDays(quint32 value)
{
    qint32 year = ( 10000 * value + 14780 ) / 3652425;
    qint32 day = value - ( 365 * year + year / 4 - year / 100 + year / 400);
    if ( day < 0 ) {
        year -= 1;
        day = value - ( 365 * year + year / 4 - year / 100 + year / 400 );
    }
    quint32 temp = (100 * day + 52) / 3060;

    return Date( quint16( year + ( temp + 2 ) / 12 ),
                 (temp + 2) % 12 + 1,
                 quint8 (( temp * 306 + 5 ) / 10 + 1 ) );
}

Date Date::fromHours(quint32 value)
{
    return Date().addHour( value );
}

Date Date::fromMinutes(quint32 value)
{
    return Date().addMinute( value );
}

Date Date::fromSeconds(quint32 value)
{
    return Date().addMinute( value / SecondsInMinute );
}

bool Date::isDateEqual(const Date& second) const
{
    return ( second.day() == m_dateStruct.day
             && second.month() == m_dateStruct.month
             && second.year() == m_dateStruct.year );
}

Date& Date::setYear(quint16 value)
{
    if ( value <= YearMax){
        m_dateStruct.year = value;
    }
    return *this;
}

Date& Date::setMonth(quint8 value)
{
    if ( value <= MonthMax ){
        m_dateStruct.month = value;
    }
    return *this;
}

Date& Date::setDay(quint8 value)
{
    m_dateStruct.day = value;
    return *this;
}

Date& Date::setHour(quint8 value)
{
    if ( value < HourMax ){
        m_dateStruct.hour = value;
    }
    return *this;
}
Date& Date::setMinute(quint8 value)
{
    if ( value < MinuteMax ){
        m_dateStruct.minute = value;
    }
    return *this;
}

Date& Date::addYears( quint16 value )
{
    m_dateStruct.year += value;
    return *this;
}

Date& Date::addMonths(quint32 value)
{
    bool isLastDayInMonth = m_dateStruct.day == daysInMonth(m_dateStruct.year,
                                                            m_dateStruct.month);
    m_dateStruct.year += value / 12;
    if ( value > 0 ){
        m_dateStruct.month += value % 12;
        if ( m_dateStruct.month > 12)
        {
            m_dateStruct.year += 1;
            m_dateStruct.month -= 12;
        }
    }
    if ( isLastDayInMonth ){
        m_dateStruct.day = daysInMonth(m_dateStruct.year,  m_dateStruct.month);
    } else {
        m_dateStruct.day = qMin( static_cast<quint8>(m_dateStruct.day),
                                 daysInMonth( m_dateStruct.year,
                                              m_dateStruct.month ) );
    }
    return *this;
}

Date& Date::addDays(quint32 value)
{
    quint32 days = m_dateStruct.day + value;

    auto maxDay = this->daysInMonth( m_dateStruct.year , m_dateStruct.month );
    while (
           days >
           maxDay
           )
    {
        days -= maxDay;

        ++m_dateStruct.month;

        if ( m_dateStruct.month > 12) {
            m_dateStruct.month = JAN;
            ++m_dateStruct.year;
        }

        maxDay = this->daysInMonth( m_dateStruct.year , m_dateStruct.month );
    }
    m_dateStruct.day = quint8( days );

    return *this;
}

Date &Date::addHour(quint32 value)
{
    value += m_dateStruct.hour;
    if ( value >= HoursInDay ){
        this->addDays( quint16( value / HoursInDay ) );
    }
    m_dateStruct.hour = value % HoursInDay;
    return *this;
}

Date& Date::addMinute(quint32 value)
{
    value += m_dateStruct.minute;
    if ( value >= MinutesInHour ){
        this->addHour( value / MinutesInHour );
    }
    m_dateStruct.minute = value % MinutesInHour;
    return *this;
}

Date& Date::reduceYears(quint16 value)
{
    m_dateStruct.year -= value;
    return *this;
}

Date &Date::reduceMonths(qint32 value)
{
    bool isLastDayInMonth = m_dateStruct.day == daysInMonth(m_dateStruct.year,
                                                            m_dateStruct.month);
    m_dateStruct.year -= value / 12;
    if ( value > 0 ){
        m_dateStruct.month -= value % 12;
        if ( m_dateStruct.month < 1)
        {
            m_dateStruct.year -= 1;
            m_dateStruct.month += 12;
        }
    }
    if ( isLastDayInMonth ){
        m_dateStruct.day = daysInMonth(m_dateStruct.year,  m_dateStruct.month);
    } else {
        m_dateStruct.day = qMin( static_cast<quint8>(m_dateStruct.day),
                                 daysInMonth( m_dateStruct.year,
                                              m_dateStruct.month ) );
    }
    return *this;
}

Date& Date::reduceDays(quint32 value)
{
    if ( value > m_dateStruct.day )
    {
        quint32 days =  value - m_dateStruct.day;

        auto maxDay = this->daysInMonth( m_dateStruct.year , m_dateStruct.month );
        while (
               days >
               maxDay
               )
        {
            days -= maxDay;

            --m_dateStruct.month;

            if ( m_dateStruct.month < 1) {
                m_dateStruct.month = DEC;
                --m_dateStruct.year;
            }

            maxDay = this->daysInMonth( m_dateStruct.year , m_dateStruct.month );
        }
        m_dateStruct.day = quint8( days );
    }
    else
    {
        m_dateStruct.day -= value;
    }
    return *this;
}

Date& Date::reduceHour(quint32 value)
{
    if ( value > m_dateStruct.hour )
    {
        if ( value >= HoursInDay ){
            this->reduceDays( quint16( value / HoursInDay ) );
        }
        m_dateStruct.hour -= value % HoursInDay;
    }
    else
    {
        m_dateStruct.hour -= value;
    }
    return *this;
}

Date& Date::reduceMinute(quint32 value)
{
    if ( value > m_dateStruct.minute )
    {
        if ( value >= MinutesInHour ){
            this->reduceHour( value / MinutesInHour );
        }
        m_dateStruct.minute -= value % MinutesInHour;
    }
    else
    {
        m_dateStruct.minute -= value;
    }
    return *this;
}



Date& Date::operator =(const Date& other)
{
    m_dateStruct.year   = other.m_dateStruct.year;
    m_dateStruct.month  = other.m_dateStruct.month;
    m_dateStruct.day    = other.m_dateStruct.day;

    m_dateStruct.hour   = other.m_dateStruct.hour;
    m_dateStruct.minute = other.m_dateStruct.minute;

    return *this;
}

Date& Date::operator =(Date&& other)
{
    m_dateStruct.year   = other.m_dateStruct.year;
    m_dateStruct.month  = other.m_dateStruct.month;
    m_dateStruct.day    = other.m_dateStruct.day;

    m_dateStruct.hour   = other.m_dateStruct.hour;
    m_dateStruct.minute = other.m_dateStruct.minute;

    return *this;
}

Date& Date::operator +=(const Date& other)
{
    return this->addMinute(other.toMinutes());
}

Date& Date::operator -=(const Date& other)
{

    return this->addMinute( - other.toMinutes() );
}

const Date Date::operator +(const Date& other) const
{
    return Date(*this) += other;

}

const Date Date::operator -(const Date& other) const
{
    return Date(*this) -= other;
}

bool Date::operator ==(const Date& other) const
{
    return ( m_dateStruct.minute  == other.m_dateStruct.minute
             && m_dateStruct.hour == other.m_dateStruct.hour
             && m_dateStruct.year == other.m_dateStruct.year
             && m_dateStruct.day  == other.m_dateStruct.day
             && m_dateStruct.hour == other.m_dateStruct.hour );
}

bool Date::operator !=(const Date& other) const
{
    return ! this->operator==( other );
}

bool Date::operator <(const Date& other) const
{
    if ( m_dateStruct.year < other.m_dateStruct.year )
    {
        return true;
    } else if ( m_dateStruct.year == other.m_dateStruct.year )
    {
        if ( m_dateStruct.month < other.m_dateStruct.month )
        {
            return true;
        } else if ( m_dateStruct.month == other.m_dateStruct.month )
        {
            if ( m_dateStruct.day < other.m_dateStruct.day ){
                return true;
            } else if ( m_dateStruct.day == other.m_dateStruct.day )
            {
                if ( m_dateStruct.hour < other.m_dateStruct.hour )
                {
                    return true;
                } else if ( m_dateStruct.hour == other.m_dateStruct.hour )
                {
                    if ( m_dateStruct.minute < other.m_dateStruct.minute )
                    {
                        return true;
                    }
                }
            }
        }
    }
    return false;
}

bool Date::operator >(const Date& other) const
{
    return !this->operator<=( other );
}

bool Date::operator <=(const Date& other) const
{
    if ( m_dateStruct.year < other.m_dateStruct.year )
    {
        return true;
    } else if ( m_dateStruct.year == other.m_dateStruct.year )
    {
        if ( m_dateStruct.month < other.m_dateStruct.month )
        {
            return true;
        } else if ( m_dateStruct.month == other.m_dateStruct.month )
        {
            if ( m_dateStruct.day < other.m_dateStruct.day ){
                return true;
            } else if ( m_dateStruct.day == other.m_dateStruct.day )
            {
                if ( m_dateStruct.hour < other.m_dateStruct.hour )
                {
                    return true;
                } else if ( m_dateStruct.hour == other.m_dateStruct.hour )
                {
                    if ( m_dateStruct.minute < other.m_dateStruct.minute )
                    {
                        return true;
                    } else if ( other.m_dateStruct.minute == m_dateStruct.minute )
                    {
                        return true;
                    }
                }
            }
        }
    }
    return false;
}


bool Date::operator >=(const Date& other) const
{
    return !this->operator<(other);
}



bool Date::isLeapYear(quint32 year)
{
    if ( year % 4 != 0 ) {
        return false;
    }
    if ( year % 400 == 0 ) {
        return true;
    }
    if ( year % 100 == 0 ) {
        return false;
    }
    return true;
}



quint8 Date::daysInMonth(quint16 year, quint8 month)
{
    static quint8 m_daysMaxInMonth[] = {
        Date::DayMaxJan, Date::DayMaxFeb, Date::DayMaxMar, Date::DayMaxApr,
        Date::DayMaxMay, Date::DayMaxJun, Date::DayMaxJul, Date::DayMaxAug,
        Date::DayMaxSep, Date::DayMaxOct, Date::DayMaxNov, Date::DayMaxDec
    };
    if ( month == FEB ){
        if (year%4 == 0 && ((year%100 != 0) || (year%400 == 0)) ){
            return DayMaxFebLeap;
        } else {
            return DayMaxFeb;
        }
    }
    return m_daysMaxInMonth[ month - 1 ];
}

Date::DateStruct::DateStruct( const quint32& binaryValue )
    : quint32Convertion(binaryValue)
{}

Date::DateStruct::DateStruct( const quint16& year, const quint8& month, const quint8& day,
                              const quint8& hour, const quint8& minute )
    : year(year), month(month), day(day), hour(hour), minute(minute)
{}

Date::DateStruct::DateStruct(const Date::DateStruct& other)
    : quint32Convertion(other.quint32Convertion)
{}
