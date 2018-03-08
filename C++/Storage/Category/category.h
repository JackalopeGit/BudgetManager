#ifndef CATEGORY_H
#define CATEGORY_H

#include "C++/Tools/Color/color.h"
#include <QString>

class Category
{
public:
    Category( const QString& m_name, const Color& m_color = Color() );

    Color color() const;
    void setColor(const Color& color);

    QString name() const;
    void setName(const QString& name);

private:
    Color   m_color;
    QString m_name;
};

#endif // CATEGORY_H
