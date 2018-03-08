#ifndef PIESERIES_H
#define PIESERIES_H

#include "pieslice.h"
#include <vector>

class PieSeries
{
public:
    PieSeries();
    ~PieSeries();

    void emplace_back( PieSlice* pieSlice );

    void emplace( quint8 index, PieSlice* pieSlice );

    void erase( quint8 index );

    PieSlice* operator [] ( quint8 index );

    quint8 size() const;

    void clear();

private:
    std::vector<PieSlice*> m_pieSlice;
};

#endif // PIESERIES_H
