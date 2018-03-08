#include "lang.h"

Lang::Lang()
{
    this->loadLang( LangMode::ENG );
}

Lang::Lang(LangMode flag)
{
    this->loadLang(flag);
}

void Lang::loadLang(quint8 flag)
{
    m_label.clear();
    m_langNo = LangMode(flag);

    emit changed( flag );

    QString fileName = flag == LangMode::ENG ? ":Translate/Eng" : ":Translate/Rus";

    QFile local(fileName);
    local.open(QIODevice::ReadOnly | QIODevice::Text);

    while (!local.atEnd()){
       m_label.push_back(QString::fromUtf8(local.readLine()));
    }
    for ( quint16 i = 0; i < m_label.size(); i++ ){
       m_label[i].chop(1);
    }
    local.close();
}

quint8 Lang::currentLang() const
{
    return m_langNo;
}

ulong Lang::size() const
{
    return m_label.size();
}


QString Lang::label(quint16 number) const
{
    return m_label[number];
}

QString Lang::operator[](quint16 labelNo) const
{
    return m_label[labelNo];
}
