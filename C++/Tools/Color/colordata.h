#ifndef COLORDATA_H
#define COLORDATA_H

#include <QtGlobal>

union ColorData {
    struct {
    quint8 a;
    quint8 r;
    quint8 g;
    quint8 b;
    };
    quint32 quint32conversion;
};

#endif // COLORDATA_H
