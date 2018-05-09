#include "lineseriesmodel.h"



LineSeriesModel::LineSeriesModel(const PayList* payModel, const Strings* currency, const Lang* lang)

    : p_PayModel{ payModel }, p_currencyModel{ currency }, p_lang{lang},
      m_begin{ Date::YearMin, Date::MonthMin, Date::DayMin, Date::HourMin, Date::MinuteMin },
      m_end{ Date::YearMax, Date::MonthMax, Date::DayMaxDec, Date::HourMax, Date::MinuteMax }
{
    this->createLines();
}

LineSeriesModel::~LineSeriesModel()
{
    this->clear();
}

int LineSeriesModel::lineCount() const
{
    return m_lines.size();
}

int LineSeriesModel::lineItemCount() const
{
    return m_lines[0]->size();
}

void LineSeriesModel::setSelection(
        quint8 dateMode,
        quint16 yearBegin, quint8 monthBegin, quint8 dayBegin,
        quint16 yearEnd, quint8 monthEnd, quint8 dayEnd
        )
{
    m_begin.setYear( yearBegin ).setMonth( monthBegin ).setDay( dayBegin );
    m_end  .setYear( yearEnd   ).setMonth( monthEnd   ).setDay( dayEnd   );

    m_lineType = Modes( dateMode );

    this->fillLines();
}

void LineSeriesModel::setDateMode(quint8 dateMode)
{
    m_lineType = Modes( dateMode );
    this->fillLines();
}

QVariantList LineSeriesModel::incomeList(quint8 currencyNo)
{
    return m_lines[currencyNo]->incomeList();
}

QVariantList LineSeriesModel::expenceList(quint8 currencyNo)
{
    return m_lines[currencyNo]->expenceList();
}

QVariantList LineSeriesModel::dateList(quint8 currencyNo)
{
    return m_lines[currencyNo]->dateList();
}

quint64 LineSeriesModel::maxValue(quint8 currencyNo)
{
    return m_lines[currencyNo]->maxValue();
}

void LineSeriesModel::payAdded(const Pay* pay)
{
    if ( isDateFit(pay->date() ) )
    {
        switch (m_lineType)
        {
            case ( Modes::Years ):
            {
                if ( pay->getSum() > 0 ){
                    m_lines[ pay->getCurrency() ]->addIncome( pay->date().year() - m_begin.year(), pay->getSum() );
                } else {
                    m_lines[ pay->getCurrency() ]->addExpence( pay->date().year() - m_begin.year(), -pay->getSum() );
                }
                break;
            }
            case ( Modes::Months ):
            {
                if ( pay->getSum() > 0 ){
                    m_lines[ pay->getCurrency() ]->addIncome( pay->date().toMonths() - m_begin.toMonths(), pay->getSum() );
                } else {
                    m_lines[ pay->getCurrency() ]->addExpence( pay->date().toMonths() - m_begin.toMonths(), -pay->getSum() );
                }
                break;
            }
            case ( Modes::Days ):
            {
                if ( pay->getSum() > 0 ){
                    m_lines[ pay->getCurrency() ]->addIncome( pay->date().toDays() - m_begin.toDays(), pay->getSum() );
                } else {
                    m_lines[ pay->getCurrency() ]->addExpence( pay->date().toDays() - m_begin.toDays(), -pay->getSum() );
                }
                break;
            }
        }
        emit listChanged( pay->getCurrency() );
    }
}

void LineSeriesModel::payRemoved(const Pay* pay)
{
    if ( isDateFit(pay->date() ) )
    {
        switch (m_lineType)
        {
            case ( Modes::Years ):
            {
                if ( pay->getSum() > 0 ){
                    m_lines[ pay->getCurrency() ]->addIncome( pay->date().year() - m_begin.year(), -pay->getSum() );
                } else {
                    m_lines[ pay->getCurrency() ]->addExpence( pay->date().year() - m_begin.year(), pay->getSum() );
                }
                break;
            }
            case ( Modes::Months ):
            {
                if ( pay->getSum() > 0 ){
                    m_lines[ pay->getCurrency() ]->addIncome( pay->date().toMonths() - m_begin.toMonths(), -pay->getSum() );
                } else {
                    m_lines[ pay->getCurrency() ]->addExpence( pay->date().toMonths() - m_begin.toMonths(), pay->getSum() );
                }
                break;
            }
            case ( Modes::Days ):
            {
                if ( pay->getSum() > 0 ){
                    m_lines[ pay->getCurrency() ]->addIncome( pay->date().toDays() - m_begin.toDays(), -pay->getSum() );
                } else {
                    m_lines[ pay->getCurrency() ]->addExpence( pay->date().toDays() - m_begin.toDays(), pay->getSum() );
                }
                break;
            }
        }
        emit listChanged( pay->getCurrency() );
    }
}

void LineSeriesModel::currencyAdded(quint8 currencyNo)
{
    m_lines.emplace( m_lines.begin() + currencyNo, new Line );

    switch (m_lineType)
    {
        case ( Modes::Years ):
        {
            for ( int j = m_end.year() - m_begin.year(); j >=0; j--  )
            {
                m_lines[currencyNo]->add( 0, 0, QString::number( m_end.year() - j ) );
            }
        } break;
        case ( Modes::Months ):
        {
            auto beginMonths = m_begin.toMonths();
            Date temp{m_begin};
            for ( int j = m_end.toMonths() - beginMonths; j >=0; j--  )
            {
                m_lines[currencyNo]->add( 0, 0, (*p_lang)[11 + temp.month() ].mid(0,3)
                        + QString(' ') + QString::number( temp.year() ) );
                temp.addMonths(1);
            }
        } break;
        case ( Modes::Days ):
        {
            auto beginDays = m_begin.toDays();
            Date temp{m_begin};
            for ( int j = m_end.toDays() - beginDays; j >=0; j--  )
            {
                m_lines[currencyNo]->add( 0, 0, QString::number( temp.day() ) + QString(' ')
                                          + (*p_lang)[11 + temp.month() ].mid(0,3) );
                temp.addDays(1);
            }
        }
    }
    emit listChanged(currencyNo);
}

void LineSeriesModel::currencyRemoved(quint8 currencyNo)
{
    m_lines.erase( m_lines.begin() + currencyNo );
}

void LineSeriesModel::createLines()
{
    this->clear();
    for ( quint16 i{0}; i < p_currencyModel->size(); i++ ){
        m_lines.emplace_back( new Line );
    }
}

void LineSeriesModel::fillLines()
{
    this->clearLines();
    switch (m_lineType)
    {
        case ( Modes::Years ):
        {
            for ( quint16 i{0}; i < p_currencyModel->size(); i++ )
            {
                for ( int j = m_end.year() - m_begin.year(); j >=0; j--  )
                {
                    m_lines[i]->add( 0, 0, QString::number( m_end.year() - j ) );
                }
            }
            const Pay* pay;
            for ( size_t i{0}; i < p_PayModel->size(); i++ )
            {
                pay = (*p_PayModel)[i];
                if ( isDateFit(pay->date()) )
                {
                    if ( pay->getSum() > 0 ){
                        m_lines[ pay->getCurrency() ]->addIncome( pay->date().year() - m_begin.year(), pay->getSum() );
                    } else {
                        m_lines[ pay->getCurrency() ]->addExpence( pay->date().year() - m_begin.year(), -pay->getSum() );
                    }
                }
            }
            break;
        }
        case ( Modes::Months ):
        {
            auto beginMonths = m_begin.toMonths();
            for ( quint16 i{0}; i < p_currencyModel->size(); i++ )
            {
                Date temp{m_begin};
                for ( int j = m_end.toMonths() - beginMonths; j >=0; j--  )
                {
                    m_lines[i]->add( 0, 0, (*p_lang)[11 + temp.month() ].mid(0,3)
                            + QString(' ') + QString::number( temp.year() ) );
                    temp.addMonths(1);
                }
            }
            const Pay* pay;
            for ( size_t i{0}; i < p_PayModel->size(); i++ )
            {
                pay = (*p_PayModel)[i];
                if ( isDateFit(pay->date()) )
                {
                    if ( pay->getSum() > 0 ){
                        m_lines[ pay->getCurrency() ]->addIncome( pay->date().toMonths() - beginMonths, pay->getSum() );
                    } else {
                        m_lines[ pay->getCurrency() ]->addExpence( pay->date().toMonths() - beginMonths, -pay->getSum() );
                    }
                }
            }
            break;
        }
        case ( Modes::Days ):
        {
            auto beginDays = m_begin.toDays();
            for ( quint16 i{0}; i < p_currencyModel->size(); i++ )
            {
                Date temp{m_begin};
                for ( int j = m_end.toDays() - beginDays; j >=0; j--  )
                {
                    m_lines[i]->add( 0, 0, QString::number( temp.day() ) + QString(' ')
                                     + (*p_lang)[11 + temp.month() ].mid(0,3) );
                    temp.addDays(1);
                }
            }
            const Pay* pay;
            for ( size_t i{0}; i < p_PayModel->size(); i++ )
            {
                pay = (*p_PayModel)[i];
                if ( isDateFit(pay->date()) )
                {
                    if ( pay->getSum() > 0 ){
                        m_lines[ pay->getCurrency() ]->addIncome( pay->date().toDays() - beginDays, pay->getSum() );
                    } else {
                        m_lines[ pay->getCurrency() ]->addExpence( pay->date().toDays() - beginDays, -pay->getSum() );
                    }
                }
            }
        }
    }
    emit updated();
}

void LineSeriesModel::clear()
{
    for ( auto line : m_lines ){
        delete line;
    }
    m_lines.clear();
}

void LineSeriesModel::clearLines()
{
    for ( auto line : m_lines ){
        line->clear();
    }
}


bool LineSeriesModel::isDateFit(const Date& date) const
{
    return date >= m_begin && date <= m_end;
}

