#ifndef LINE_H
#define LINE_H

#include<QVariantList>

class Line
{
public:
    Line() = default;
    ~Line() = default;

    Q_INVOKABLE QVariant income( int i ) const;
    Q_INVOKABLE QVariant expence(int i ) const;
    Q_INVOKABLE QVariant time( int i ) const;

    void add(quint64 income, quint64 expence, QString time );
    void insert( int i, quint64 income, quint64 expence, QString time );
    void erase( int i );

    void addIncome( int i, qint64 income );
    void addExpence( int i, qint64 income );

    int size() const;

    quint64 maxValue();

    QVariantList incomeList() const;
    QVariantList expenceList() const;
    QVariantList dateList() const;

    void clear();
private:

    QVariantList m_incomeValues;
    QVariantList m_expenceValues;
    QVariantList m_timeValues;
};

#endif // LINE_H
