#include "pieseries.h"

PieSeries::PieSeries()
{
}

PieSeries::~PieSeries()
{
    this->clear();
}

void PieSeries::emplace_back(PieSlice* pieSlice)
{
    m_pieSlice.emplace_back( pieSlice );
}

void PieSeries::emplace(quint8 index, PieSlice* pieSlice)
{
    m_pieSlice.emplace( m_pieSlice.begin() + index, pieSlice );
}

void PieSeries::erase(quint8 index)
{
    m_pieSlice.erase( m_pieSlice.begin() + index );
}

PieSlice*PieSeries::operator [](quint8 index)
{
    return m_pieSlice[index];
}

quint8 PieSeries::size() const
{
    return quint8 ( m_pieSlice.size() );
}

void PieSeries::clear()
{
    for ( auto pieSlice : m_pieSlice ){
        delete pieSlice;
    }
    m_pieSlice.clear();
}
