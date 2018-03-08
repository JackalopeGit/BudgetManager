#ifndef Strings_H
#define Strings_H

#include <QAbstractListModel>
#include <QString>
#include <QFile>
#include <QDataStream>
#include <QTextStream>
#include <QVector>

#include <assert.h>

class Strings : public QAbstractListModel
{
    Q_OBJECT

public:
    Strings() = default;
    Strings( QString fileName );
    ~Strings();

    bool readFile();
    bool saveFile();

    QString operator[](quint8 index ) const;

    void set(quint8 number, QString value)         { data_[number] = value; }

    quint8 size() const;

    Q_INVOKABLE QString getName( quint8 index );

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index,
                  int role = Qt::DisplayRole) const override;

    Q_INVOKABLE bool set(int row, QString value);

    Q_INVOKABLE bool insertRows(int row, int count,
                                const QModelIndex &parent = QModelIndex()) override;

    Q_INVOKABLE bool removeRows(int row, int count,
                                const QModelIndex &parent = QModelIndex()) override;

    QHash<int, QByteArray> roleNames() const override;

    enum CurrencyRoles{ NameRole, NumberRole };

    enum Byte : quint8 { MIN = 0, MAX = 255 };

signals:
    void removed( quint8 index );
    void renamed( quint8 index );
    void added( quint8 index );
private:

    QString fileName_;

    QVector <QString> data_;

};

#endif // Strings_H
