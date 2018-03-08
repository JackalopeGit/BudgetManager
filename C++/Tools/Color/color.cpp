#include "color.h"

Color::Color()
{
    m_color.quint32conversion = 0;
}

Color::Color(quint8 r, quint8 g, quint8 b, quint8 a)
{
    m_color.a = a;
    m_color.r = r;
    m_color.g = g;
    m_color.b = b;
}

Color::Color(const ColorData& colorData)
{
    m_color.quint32conversion = colorData.quint32conversion;
}

Color::Color(const Color& other)
{
    m_color.quint32conversion = other.m_color.quint32conversion;
}

Color::Color(quint32 argb)
{
    m_color.quint32conversion = argb;
}

Color::Color(const QString& colorQml)
{
    if ( colorQml.size() == 9 ){
        //  012345678
        //  # a R G B
        m_color.a = quint8 ( QStringRef( &colorQml, 1, 2 ).toInt(0, 16) );
        m_color.r = quint8 ( QStringRef( &colorQml, 3, 2 ).toInt(0, 16) );
        m_color.g = quint8 ( QStringRef( &colorQml, 5, 2 ).toInt(0, 16) );
        m_color.b = quint8 ( QStringRef( &colorQml, 7, 2 ).toInt(0, 16) );
    } else if ( colorQml.size() == 7 ){
        //  0123456
        //  # R G B
        m_color.a = 0b11111111;
        m_color.r = quint8 ( QStringRef( &colorQml, 1, 2 ).toInt(0, 16) );
        m_color.g = quint8 ( QStringRef( &colorQml, 3, 2 ).toInt(0, 16) );
        m_color.b = quint8 ( QStringRef( &colorQml, 5, 2 ).toInt(0, 16) );
    }
}

Color::Color(const char* color)
{
    m_color.a = quint8( color[0] );
    m_color.r = quint8( color[1] );
    m_color.g = quint8( color[2] );
    m_color.b = quint8( color[3] );
}

quint8 Color::a() const
{
    return m_color.a;
}

quint8 Color::r() const
{
    return m_color.r;
}

quint8 Color::g() const
{
    return m_color.g;
}

quint8 Color::b() const
{
    return m_color.b;
}

quint32 Color::argb() const
{
    return m_color.quint32conversion;
}

void Color::setA(quint8 a)
{
    m_color.a = a;
}

void Color::setR(quint8 r)
{
    m_color.r = r;
}

void Color::setG(quint8 g)
{
    m_color.g = g;
}

void Color::setB(quint8 b)
{
    m_color.b = b;
}

void Color::setARGB(quint32 argb)
{
    m_color.quint32conversion = argb;
}

Color& Color::operator =(const QString& colorQml)
{
    if ( colorQml.size() == 9 ){
        //  012345678
        //  # a R G B
        m_color.a = quint8 ( QStringRef( &colorQml, 1, 2 ).toInt(0, 16) );
        m_color.r = quint8 ( QStringRef( &colorQml, 3, 2 ).toInt(0, 16) );
        m_color.g = quint8 ( QStringRef( &colorQml, 5, 2 ).toInt(0, 16) );
        m_color.b = quint8 ( QStringRef( &colorQml, 7, 2 ).toInt(0, 16) );
    } else if ( colorQml.size() == 7 ){
        //  0123456
        //  # R G B
        m_color.a = 0b11111111;
        m_color.r = quint8 ( QStringRef( &colorQml, 1, 2 ).toInt(0, 16) );
        m_color.g = quint8 ( QStringRef( &colorQml, 3, 2 ).toInt(0, 16) );
        m_color.b = quint8 ( QStringRef( &colorQml, 5, 2 ).toInt(0, 16) );
    }
    return *this;
}

QString Color::toString() const
{
    return '#'
            + ( m_color.a < 16 ? "0" : QString() ) + QString::number( m_color.a, 16 )
            + ( m_color.r < 16 ? "0" : QString() ) + QString::number( m_color.r, 16 )
            + ( m_color.g < 16 ? "0" : QString() ) + QString::number( m_color.g, 16 )
            + ( m_color.b < 16 ? "0" : QString() ) + QString::number( m_color.b, 16 );
}

char*Color::toCharArray() const
{
    static char color[4];
    color[0] = char(m_color.a);
    color[1] = char(m_color.r);
    color[2] = char(m_color.g);
    color[3] = char(m_color.b);
    return color;
}

ColorData Color::colorData() const
{
    return m_color;
}

void Color::setColorData(const ColorData& color)
{
    m_color = color;
}
