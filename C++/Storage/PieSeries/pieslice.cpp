#include "pieslice.h"



PieSlice::PieSlice(quint64 value )
    : m_value( value )
{
}

void PieSlice::operator +=(qint64 value)
{
    m_value += value;
}

void PieSlice::operator -=(qint64 value)
{
    m_value -= value;
}

quint64 PieSlice::getValue() const
{
    return m_value;
}

void PieSlice::setValue(const quint64& value)
{
    m_value = value;
}

