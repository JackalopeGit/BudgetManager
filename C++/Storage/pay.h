#ifndef PAY_H
#define PAY_H

#include <QString>
#include "C++/Tools/date.h"

union PayFlags {
    struct {
        quint8 isNotDeleted :1;
        quint8 isEnabled    :1;
        quint8 periodType   :2;
        quint8 presentBound :1;
    };
    quint8 quint8Convertion;

    enum {
        Deleted    = 0b00000000,
        NotDeleted = 0b00000001,
        FromTPay   = 0b00000010, Enabled = 0b00000010,
        PeriodShift = 2,
        PresendBound = 0b00010000
    };
    enum PeriodType { YEAR = 0, MONTH, DAY, HOUR };

    PayFlags( PayFlags const &other ){
        quint8Convertion = other.quint8Convertion;
    }
    PayFlags( quint8 value ){
        quint8Convertion = value;
    }
};

class Pay
{
public:
    Pay();

    Pay(
            const qint64& sum,
            const Date& date,
            const quint8& currency,
            const quint8& category,
            const quint16& tNo,
            const QString& description,
            const PayFlags& flags

            );

    Pay( const Pay& other );
    Pay& operator =(const Pay& other);
    virtual ~Pay() = default ;

    qint64  getSum()         const;
    Date    getDate()        const;
    quint8  getCurrency()    const;
    quint8  getCategory()    const;
    QString getDescription() const;

    const Date& date() const;

    bool isFromTPay()     const;

    void setSum        ( const qint64&  sum );
    void setDate       ( const Date&    date );
    void setCurrency   ( const quint8&  currency );
    void setCategory   ( const quint8&  category );
    void setDescription( const QString& description );
    void setIsFromTPay  ( bool isFromTPay );

    enum { EMPTY };

    quint8 getFlags() const;
    void setFlags( quint8 boolField);

    quint16 getTNo() const;
    void setTNo(const quint16& tNo);



protected:

    qint64  m_sum;
    Date    m_date;
    quint16 m_tNo;
    quint8  m_currency,
            m_category;

    PayFlags m_flags;


    QString m_description;
};

#endif // PAY_H
