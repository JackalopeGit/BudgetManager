#include "piemodel.h"


PieModel::PieModel(PayList* payModel, CategoryModel* category , Strings* currency)
    : p_payModel{ payModel }, p_categoryModel{ category }, p_currencyModel{ currency },
      m_dateMode{DateMode::Null},
      m_DateSelectionBegin{ Date::YearMin, Date::MonthMin, Date::DayMin, Date::HourMin, Date::MinuteMin },
      m_DateSelectionEnd{ Date::YearMax, Date::MonthMax, Date::DayMaxDec, Date::HourMax, Date::MinuteMax }
{
    this->createSeries();
}

PieModel::~PieModel()
{
    this->clear();
}

quint8 PieModel::seriesCount() const
{
    return m_incomePieSeries.size();
}

int PieModel::sliceCount() const
{
    return m_incomePieSeries[0]->size();
}

quint64 PieModel::incomeValue(ulong seriesIndex, quint8 sliceIndex) const
{
    return m_incomePieSeries[seriesIndex]->operator[](sliceIndex)->getValue();
}

quint64 PieModel::consumptionValue(ulong seriesIndex, quint8 sliceIndex) const
{
    return m_expencePieSeries[seriesIndex]->operator[](sliceIndex)->getValue();
}


float PieModel::incomeRatioCurrency(quint8 currencyIndex) const
{
    return m_incomeRatioCurrencies[currencyIndex];
}

quint64 PieModel::incomeSumCurrency(quint8 currencyIndex) const
{
    return m_incomeSumCurrencies[currencyIndex];
}

quint64 PieModel::expenceSumCurrency(quint8 currencyIndex) const
{
    return m_expenceSumCurrencies[currencyIndex];
}


void PieModel::setDateRange(quint16 yearBegin, quint8 monthBegin, quint8 dayBegin,
                                 quint16 yearEnd, quint8 monthEnd, quint8 dayEnd)
{
    m_dateMode = DateMode::Range;
    m_DateSelectionBegin.setYear(yearBegin).setMonth(monthBegin).setDay(dayBegin);
    m_DateSelectionEnd.setYear(yearEnd).setMonth(monthEnd).setDay(dayEnd);
    this->setSeriesEmpty();
    this->fillSeries();
}

void PieModel::setYear(quint16 year)
{
    m_dateMode = DateMode::Year;
    m_DateSelectionBegin.setYear(year);
    this->setSeriesEmpty();
    this->fillSeries();
}

void PieModel::setMonth(quint16 year, quint8 month)
{
    m_dateMode = DateMode::Month;
    m_DateSelectionBegin.setYear(year).setMonth(month);
    this->setSeriesEmpty();
    this->fillSeries();
}

void PieModel::setDay(quint16 year, quint8 month, quint8 day)
{
    m_dateMode = DateMode::Day;
    m_DateSelectionBegin.setYear(year).setMonth(month).setDay(day);
    this->setSeriesEmpty();
    this->fillSeries();
}

void PieModel::setAllTime()
{
    m_dateMode = DateMode::Null;
    this->setSeriesEmpty();
    this->fillSeries();
}

void PieModel::payAdded(const Pay* pay)
{
    if ( this->checkPayDate(pay) ){
        if ( pay->getSum() > 0 ){
            (*m_incomePieSeries[pay->getCurrency()])  [pay->getCategory()]->operator+=( pay->getSum() );
            emit incomeValueChanged( pay->getCurrency(), pay->getCategory() );
        } else {
            (*m_expencePieSeries[pay->getCurrency()]) [pay->getCategory()]->operator-=( pay->getSum() );
            emit expenceValueChanged( pay->getCurrency(), pay->getCategory() );
        }
        this->createIncomeRatios();
    }
}

void PieModel::payRemoved(const Pay* pay)
{
    if ( this->checkPayDate(pay) ){
        if ( pay->getSum() > 0 ){
            (*m_incomePieSeries[pay->getCurrency()])  [pay->getCategory()]->operator-=( pay->getSum() );
            emit incomeValueChanged( pay->getCurrency(), pay->getCategory() );
        } else {
            (*m_expencePieSeries[pay->getCurrency()]) [pay->getCategory()]->operator+=( pay->getSum() );
            emit expenceValueChanged( pay->getCurrency(), pay->getCategory() );
        }
        this->createIncomeRatios();
    }
}

void PieModel::categoryAdded(quint8 categoryNo)
{
    for ( quint16 i{0}; i < this->seriesCount(); i++ ){
        m_incomePieSeries [i]->emplace( categoryNo, new PieSlice{0} );
        m_expencePieSeries[i]->emplace( categoryNo, new PieSlice{0} );
    }
    emit sliceAdded( categoryNo );
}

void PieModel::categoryRemoved(quint8 categoryNo)
{
    for ( quint16 i{0}; i < this->seriesCount(); i++ ){
        m_incomePieSeries[i]->erase( categoryNo );
        m_expencePieSeries[i]->erase( categoryNo );
    }
    emit sliceRemoved( categoryNo );
}

void PieModel::currencyAdded(quint8 currencyNo)
{
    m_incomePieSeries.emplace( m_incomePieSeries.begin() + currencyNo, new PieSeries );
    m_expencePieSeries.emplace( m_expencePieSeries.begin() + currencyNo, new PieSeries );
    for ( quint16 i{0}; i < this->sliceCount(); i++ ){
        m_incomePieSeries[currencyNo]->emplace_back( new PieSlice{0} );
        m_expencePieSeries[currencyNo]->emplace_back( new PieSlice{0} );
    }
    emit serieAdded( currencyNo );
}

void PieModel::currencyRemoved(quint8 currencyNo)
{
    m_incomePieSeries.erase( m_incomePieSeries.begin() + currencyNo );
    m_expencePieSeries.erase( m_expencePieSeries.begin() + currencyNo );
    emit serieRemoved( currencyNo );
}

void PieModel::createSeries()
{
    for ( quint16 i{0}; i < p_currencyModel->size(); i++ ){
        m_incomePieSeries.emplace_back( new PieSeries );
        m_expencePieSeries.emplace_back( new PieSeries );
        for ( quint16 j{0}; j < p_categoryModel->rowCount(); j++ ){
            m_incomePieSeries[i]->emplace_back( new PieSlice(0) );
            m_expencePieSeries[i]->emplace_back( new PieSlice(0) );
        }
    }
    this->fillSeries();
}

void PieModel::setSeriesEmpty()
{
    for ( quint16 i{0}; i < p_currencyModel->size(); i++ ){
        for ( quint16 j{0}; j < p_categoryModel->rowCount(); j++ ){
            (*m_incomePieSeries[i])[j]->setValue( 0 );
            (*m_expencePieSeries[i])[j]->setValue( 0 );
        }
    }
}

void PieModel::fillSeries()
{
    const Pay* pay;
    for ( size_t i{0}; i < p_payModel->size(); i++ ){
        pay = (*p_payModel)[i];
        if ( this->checkPayDate( pay ) ) {
            if ( pay->getSum() > 0 ){
                (*m_incomePieSeries[pay->getCurrency()])  [pay->getCategory()]->operator+=( pay->getSum() );
            } else {
                (*m_expencePieSeries[pay->getCurrency()]) [pay->getCategory()]->operator-=( pay->getSum() );
            }
        }
    }
    pieChanged();
    this->createIncomeRatios();
}

bool PieModel::checkPayDate(const Pay* pay) const
{
    switch ( m_dateMode )
        {
        case (Null) : return true;
        case (Range): return ( pay->getDate() >= m_DateSelectionBegin && pay->getDate() <= m_DateSelectionEnd);
        case (Year) : return ( pay->getDate().year() == m_DateSelectionBegin.year() );
        case (Month): return ( pay->getDate().year() == m_DateSelectionBegin.year()
                               && pay->getDate().month() == m_DateSelectionBegin.month() );
        case (Day)  : return ( pay->getDate().isDateEqual(m_DateSelectionBegin) );
        }
    return false;
}


void PieModel::createIncomeRatios()
{
    m_incomeRatioCurrencies.clear();
    m_incomeSumCurrencies.clear();
    m_expenceSumCurrencies.clear();

    for ( quint16 i{0}; i < m_incomePieSeries.size(); i++ )
    {
        m_incomeSumCurrencies.emplace_back(0);
        m_expenceSumCurrencies.emplace_back(0);

        for ( quint16 j{0}; j < this->sliceCount(); j++ )
        {
            m_incomeSumCurrencies[i]  += (*m_incomePieSeries[i] )[j]->getValue();
            m_expenceSumCurrencies[i] += (*m_expencePieSeries[i])[j]->getValue();
        }
        m_incomeRatioCurrencies.emplace_back( float( m_expenceSumCurrencies[i] ) / float( m_incomeSumCurrencies[i] ) );
    }
    emit incomeRatioChanged();
}


void PieModel::clear()
{
    for ( quint16 i{0}; i < m_incomePieSeries.size(); i++ ){
        delete m_incomePieSeries[i];
        delete m_expencePieSeries[i];
    }
    m_incomePieSeries.clear();
    m_expencePieSeries.clear();
}
