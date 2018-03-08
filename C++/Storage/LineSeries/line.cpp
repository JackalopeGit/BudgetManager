#include "line.h"


QVariant Line::income(int i) const
{
    return m_incomeValues[i];
}

QVariant Line::expence(int i) const
{
    return  m_expenceValues[i];
}

QVariant Line::time(int i) const
{
    return m_timeValues[i];
}

void Line::add(quint64 income, quint64 expence, QString time)
{
    m_incomeValues.append( income );
    m_expenceValues.append( expence );
    m_timeValues.append( time );
}

void Line::insert(int i, quint64 income, quint64 expence, QString time)
{
    m_incomeValues.insert( i, income );
    m_expenceValues.insert( i, expence );
    m_timeValues.insert( i, time );
}

void Line::erase(int i)
{
    m_incomeValues.erase( m_incomeValues.begin() + i );
    m_expenceValues.erase( m_expenceValues.begin() + i );
    m_timeValues.erase( m_timeValues.begin() + i );
}

void Line::addIncome(int i, qint64 income)
{
    m_incomeValues[i] =  m_incomeValues[i].toULongLong()+income;
}

void Line::addExpence(int i, qint64 income)
{
    m_expenceValues[i] =  m_expenceValues[i].toULongLong()+income;
}

int Line::size() const
{
    return m_timeValues.size();
}

quint64 Line::maxValue()
{
    quint64 maxValue{0};
    for ( auto item : m_incomeValues ){
        if ( maxValue < item.toULongLong()  ) maxValue = item.toULongLong();
    }
    for ( auto item : m_expenceValues ){
        if ( maxValue < item.toULongLong()  ) maxValue = item.toULongLong();
    }
    return maxValue/100+1;
}

QVariantList Line::incomeList() const
{
    QVariantList incomeList;
    for ( auto item : m_incomeValues ){
        incomeList.append(
                    ( double( item.toULongLong() )  +  double( item.toULongLong() % 100 ) )
                    /100 );
    }
    return incomeList;
}

QVariantList Line::expenceList() const
{
    QVariantList expenceList;
     for ( auto item : m_expenceValues ){
         expenceList.append(
                     ( double( item.toULongLong() )  +  double( item.toULongLong() % 100 ) )
                     /100 );
     }
    return expenceList;
}

QVariantList Line::dateList() const
{
    return m_timeValues;
}


void Line::clear()
{
    m_incomeValues.clear();
    m_expenceValues.clear();
    m_timeValues.clear();
}
