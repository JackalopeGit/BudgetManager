#ifndef CATEGORYMODEL_H
#define CATEGORYMODEL_H

#include <QAbstractListModel>

#include <fstream>
#include <string>

#include <vector>

#include <assert.h>

#include "category.h"

class CategoryModel : public QAbstractListModel
{
   Q_OBJECT
public:
    CategoryModel( QString fileName = "category" );

    QString operator[]( quint8 index ) const;

    Q_INVOKABLE QString getName( quint8 index );
    Q_INVOKABLE QString getColor( quint8 index );

    Q_INVOKABLE void setName ( quint8 index, QString name );
    Q_INVOKABLE void setColor( quint8 index, QString color );

    Q_INVOKABLE void set( quint8 index, QString name, QString color );

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    bool setData( const QModelIndex &index, const QVariant &value, int role ) override;

    Q_INVOKABLE void addCategory( QString name, QString color );

    Q_INVOKABLE void removeCategory( quint8 index );

    QHash<int, QByteArray> roleNames() const override;

    enum { NameRole, ColorRole };

    enum Byte : quint8 { MIN = 0, MAX = 255 };
signals:
    void changed( quint8 index );
    void removed( quint8 index );
    void added( quint8 index );
private:
    bool readFile();
    bool saveFile();


    QString m_fileName;

    std::vector<Category> m_category;
};

#endif // CATEGORYMODEL_H
