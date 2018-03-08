#ifndef COLOR_H
#define COLOR_H

#include "colordata.h"
#include <QString>

class Color
{
public:
    Color();
    Color( quint8 r, quint8 g, quint8 b, quint8 a = 0b11111111 );
    Color( const ColorData& colorData );
    Color( const Color& other );
    Color( quint32 argb );
    Color( const QString& colorQml );
    Color( const char* color );

    quint8 a() const;
    quint8 r() const;
    quint8 g() const;
    quint8 b() const;
    quint32 argb() const;

    void setA( quint8 a );
    void setR( quint8 r );
    void setG( quint8 g );
    void setB( quint8 b );
    void setARGB(quint32 argb );

    Color& operator = ( const QString& colorQml );

    QString toString() const;
    char* toCharArray() const;

    ColorData colorData() const;
    void setColorData(const ColorData& color);

private:
    ColorData m_color;
};

#endif // COLOR_H
