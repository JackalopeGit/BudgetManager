#include "category.h"


Category::Category(const QString& name, const Color& color)
    : m_color( color ), m_name( name )
{

}

Color Category::color() const
{
    return m_color;
}

void Category::setColor(const Color& color)
{
    m_color = color;
}

QString Category::name() const
{
    return m_name;
}

void Category::setName(const QString& name)
{
    m_name = name;
}
