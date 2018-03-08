#ifndef TPAY_H
#define TPAY_H

#include "pay.h"


class TPay : public Pay
{
public:
    TPay();

   explicit TPay(

         qint64 sum,
         quint8 currency,
         quint8 category,
         quint16 tNo,
         const Date& startDate,
         const Date& lastT,
         quint16 period,
         quint16 maxRepeat,
         quint16 nRepeat,
         PayFlags flags,
         QString description

         );

   TPay( const TPay& other );
   virtual ~TPay() = default;

   TPay& operator =(const TPay& other );

   quint16 getMaxRepeat() const;
   void setMaxRepeat(const quint16& maxRepeat);

   quint16 getNRepeat() const;
   void setNRepeat(const quint16& nRepeat);

   quint16 isEnabled() const;
   void setEnabled( bool isEnabled );

   quint16 isNotify() const;
   void setNotifyEnabled( bool isEnabled );

   quint16 isAsk() const;
   void setAskEnabled( bool isEnabled );

   quint16 getPeriod() const;
   void setPeriod(const quint16 &value);

   quint8 getPeriodType() const;
   void setPeriodType( PayFlags::PeriodType type );

   Date getLastTDate() const;
   void setLastTDate(const Date& lastT);

   bool isPresentBound() const;
   void setPresentBound(bool isEnabled );

   TPay& operator++();

private:
   quint16 m_period;
   quint16 m_nRepeat;
   quint16 m_maxRepeat;

   Date m_lastTDate;
};

#endif // TPAY_H
