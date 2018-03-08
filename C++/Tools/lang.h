#ifndef LANG_H
#define LANG_H

#include<vector>

#include<QString>
#include<QFile>
#include<QDataStream>

#include <QObject>

enum LangMode : quint8 { ENG = 0, RUS = 1 };

class Lang : public QObject
{
   Q_OBJECT
public:
   Lang();
   Lang(LangMode flag);

   Q_INVOKABLE void loadLang(quint8 flag);

   Q_INVOKABLE quint8 currentLang() const;
   ulong size() const;

   Q_INVOKABLE QString label(quint16 number) const;

   QString operator[](quint16 labelNo) const;

signals:
   void changed( quint8 lang );

private:
   LangMode m_langNo;
   std::vector<QString> m_label;
};

#endif // LANG_H
