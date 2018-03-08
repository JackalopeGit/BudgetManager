#ifndef TLINESERIESMODEL_H
#define TLINESERIESMODEL_H

#include "line.h"
#include "C++/Storage/paylist.h"
#include "C++/Tools/lang.h"

class LineSeriesModel : public QObject
{
    Q_OBJECT

public:
    LineSeriesModel(const PayList* payModel, const Strings* currency, const Lang* lang );
    ~LineSeriesModel();



    Q_INVOKABLE int lineCount() const;
    Q_INVOKABLE int lineItemCount() const;

    Q_INVOKABLE void setSelection( quint8 dateMode,
                                   quint16 yearBegin, quint8  monthBegin, quint8  dayBegin,
                                   quint16 yearEnd,   quint8  monthEnd,   quint8  dayEnd );
    Q_INVOKABLE void setDateMode ( quint8 dateMode );

    Q_INVOKABLE QVariantList incomeList ( quint8 currencyNo );
    Q_INVOKABLE QVariantList expenceList( quint8 currencyNo );
    Q_INVOKABLE QVariantList dateList   ( quint8 currencyNo );
    Q_INVOKABLE quint64 maxValue ( quint8 currencyNo );

    enum Modes: quint8 { Years = 2, Months = 1, Days = 0 };

public slots:
    void payAdded(const Pay* pay);
    void payRemoved(const Pay* pay);

    void currencyAdded( quint8 currencyNo );
    void currencyRemoved( quint8 currencyNo );

signals:
    void listChanged ( quint8 currencyNo );

    void updated();

private:
    void createLines();
    void fillLines();

    void clear();
    void clearLines();

    bool isDateFit(const Date& date) const;

    const PayList* p_PayModel;
    const Strings* p_currencyModel;
    const Lang* p_lang;

    std::vector< Line*> m_lines;

    Modes m_lineType;

    Date m_begin;
    Date m_end;
};

#endif // TLINESERIESMODEL_H
