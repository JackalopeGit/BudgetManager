#ifndef PIEMODEL_H
#define PIEMODEL_H

#include "pieseries.h"
#include "C++/Storage/paylist.h"

class PieModel : public QObject
{

    Q_OBJECT
public:
    PieModel( PayList* payModel, CategoryModel* category, Strings* currency );
    ~PieModel();

    Q_INVOKABLE quint8 seriesCount() const;
    Q_INVOKABLE int sliceCount () const;

    Q_INVOKABLE quint64 incomeValue( ulong seriesIndex, quint8 sliceIndex ) const;
    Q_INVOKABLE quint64 consumptionValue( ulong seriesIndex, quint8 sliceIndex ) const;

    Q_INVOKABLE float incomeRatioCurrency( quint8 currencyIndex ) const;
    Q_INVOKABLE quint64 incomeSumCurrency( quint8 currencyIndex ) const;
    Q_INVOKABLE quint64 expenceSumCurrency( quint8 currencyIndex ) const;


    Q_INVOKABLE void setDateRange( quint16 yearBegin, quint8  monthBegin, quint8  dayBegin,
                                   quint16 yearEnd,   quint8  monthEnd,   quint8  dayEnd  );
    Q_INVOKABLE void setYear ( quint16 year );
    Q_INVOKABLE void setMonth( quint16 year, quint8 month );
    Q_INVOKABLE void setDay  ( quint16 year, quint8 month, quint8 day );
    Q_INVOKABLE void setAllTime();


public slots:
    void payAdded(const Pay* pay);
    void payRemoved(const Pay* pay);

    void categoryAdded( quint8 categoryNo );
    void categoryRemoved( quint8 categoryNo );

    void currencyAdded( quint8 currencyNo );
    void currencyRemoved( quint8 currencyNo );

signals:
    void incomeValueChanged( quint8 currencyNo, quint8 categoryNo );
    void expenceValueChanged( quint8 currencyNo, quint8 categoryNo );

    void serieAdded( quint8 currencyNo );
    void serieRemoved( quint8 currencyNo );

    void sliceAdded( quint8 categoryNo );
    void sliceRemoved( quint8 categoryNo );

    void incomeRatioChanged();

    void pieChanged();

private:
    void createSeries();
    void setSeriesEmpty();
    void fillSeries();
    bool checkPayDate(const Pay*) const;
    void createIncomeRatios();
    void clear();

    PayList* p_payModel;
    CategoryModel* p_categoryModel;
    Strings*       p_currencyModel;
    std::vector <PieSeries*> m_incomePieSeries;
    std::vector <PieSeries*> m_expencePieSeries;
    std::vector < float > m_incomeRatioCurrencies;
    std::vector < quint64 > m_incomeSumCurrencies;
    std::vector < quint64 > m_expenceSumCurrencies;

    enum DateMode : quint8 { Null = 0, Range = 1, Year = 2, Month = 3, Day = 4 };
    //bool m_isFirstValuesSet:1;
    DateMode m_dateMode;

    Date m_DateSelectionBegin;
    Date m_DateSelectionEnd;
};

#endif // PIEMODEL_H
