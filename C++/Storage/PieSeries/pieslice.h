#ifndef PIESLICE_H
#define PIESLICE_H

#include <QString>

class PieSlice
{
public:
    PieSlice() = default;
    PieSlice( quint64 value );

    void operator += ( qint64 value);
    void operator -= ( qint64 value);

    quint64 getValue() const;
    void setValue(const quint64& value);

private:
    quint64 m_value;
};

#endif // PIESLICE_H
