#ifndef Date_H
#define Date_H

#include <stdint.h>
#include <QDebug>



class Date : public QObject
{
    Q_OBJECT
public:

    enum {
        YearMin = 0, YearMax = 4095, MonthMin = 1, MonthMax = 12, DayMin = 1,

        DayMaxJan = 31, DayMaxFeb = 28, DayMaxMar = 31, DayMaxApr = 30,
        DayMaxMay = 31, DayMaxJun = 30, DayMaxJul = 31, DayMaxAug = 31,
        DayMaxSep = 30, DayMaxOct = 31, DayMaxNov = 30, DayMaxDec = 31,
        DayMaxFebLeap = 29,

        HourMin = 0, HourMax = 23, MinuteMin = 0, MinuteMax = 59,

        MonthsInYear = 12, DaysInYear    = 365, DaysInLeapYear = 366,
        HoursInDay   = 24, MinutesInHour = 60,  SecondsInMinute = 60,

        DefYear = 0, DefMonth = 1, DefDay = 1, DefHour = 0, DefMinute = 0,

        JAN = 1, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC
    };

    union DateStruct {
        struct {
            quint16 year:12;
            quint16 month:4;
            quint16 day:5;
            quint16 hour:5;
            quint16 minute:6;
        };
        quint32 quint32Convertion;

        DateStruct(const quint32& binaryValue );

        DateStruct(const quint16& year, const quint8& month, const quint8& day,
                     const quint8& hour = DefHour,const quint8& minute = DefMinute );

        DateStruct( const DateStruct& other );
        ~DateStruct() = default;

        enum : quint32 { DefaultBinary = DefYear + (DefMonth<<12) + (DefDay<<16) + (DefHour<<21) + (DefMinute<<26) };
    };

    Date();

    Date(const quint16& year, const quint8& month, const quint8& day,
         const quint8& hour = DefHour,const quint8& minute = DefMinute );

    Date(const Date& other);
    Date(const quint32& binary );
    ~Date() = default;

    quint32 toQuint32() const;

    quint16 year()   const;
    quint8  month()  const;
    quint8  day()    const;
    quint8  hour()   const;
    quint8  minute() const;

    Date& setYear   ( quint16 value = YearMin  );
    Date& setMonth  ( quint8  value = DefMonth );
    Date& setDay    ( quint8  value = DefDay   );
    Date& setHour   ( quint8  value = DefHour  );
    Date& setMinute ( quint8  value = DefMinute);


    Date& addYears  ( quint16 value = DefYear   );
    Date& addMonths ( quint32 value = DefMonth  );
    Date& addDays   ( quint32 value = DefDay    );
    Date& addHour   ( quint32 value = DefHour   );
    Date& addMinute ( quint32 value = DefMinute );
    Date& reduceYears  ( quint16 value = DefYear  );
    Date& reduceMonths ( qint32 value = DefMonth  );
    Date& reduceDays   ( quint32 value = DefDay   );
    Date& reduceHour   ( quint32 value = DefHour  );
    Date& reduceMinute ( quint32 value = DefMinute);


    quint16 toMonths()  const;
    quint32 toDays()    const;
    quint32 toHours()   const;
    quint32 toMinutes() const;
    quint64 toSeconds() const;

    static Date fromMonths ( quint16 value );
    static Date fromDays   ( quint32 value );
    static Date fromHours  ( quint32 value );
    static Date fromMinutes( quint32 value );
    static Date fromSeconds( quint32 value );

    bool isDateEqual( const Date& second ) const;

    Date& operator =( const Date& other );
    Date& operator =(Date&& other );

    Date& operator +=( const Date& other );
    Date&  operator -= ( const Date& other );

    const Date operator + ( const Date& other ) const;
    const Date operator - ( const Date& other ) const;
    static quint8* m_daysMaxInMonth;


    bool  operator == ( const Date& other ) const;
    bool  operator != ( const Date& other ) const;
    bool  operator <  ( const Date& other ) const;
    bool  operator >  ( const Date& other ) const;
    bool  operator <= ( const Date& other ) const;
    bool  operator >= ( const Date& other ) const;


    static bool isLeapYear(quint32 year);
    Q_INVOKABLE static quint8 daysInMonth( quint16 year, quint8 month );


private:
    DateStruct m_dateStruct;

};

#endif // Date_H
