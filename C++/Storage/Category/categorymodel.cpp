#include "categorymodel.h"

CategoryModel::CategoryModel(QString fileName)
    : m_fileName( fileName )
{
    this->readFile();
}

QString CategoryModel::operator[](quint8 index) const
{
    return m_category[index].name();
}

QString CategoryModel::getName(quint8 index)
{
    //if ( index < m_category.size() )
    return m_category[index].name();
    //else return "ERROR";
}

QString CategoryModel::getColor(quint8 index)
{
    return m_category[index].color().toString();
}

void CategoryModel::setName(quint8 index, QString name)
{
    m_category[index].setName( name );
    this->saveFile();
    emit changed( index );
    emit dataChanged( this->index( index, 0), this->index( index, 0), QVector<int>() << NameRole );
}

void CategoryModel::setColor(quint8 index, QString color)
{
    m_category[index].setColor( color );
    this->saveFile();
    emit changed( index );
    emit dataChanged( this->index( index, 0 ), this->index( index, 0), QVector<int>() << ColorRole );
}

void CategoryModel::set(quint8 index, QString name, QString color)
{
    m_category[index].setName( name );
    m_category[index].setColor( color );
    this->saveFile();
    emit changed( index );
    emit dataChanged( this->index( index, 0 ), this->index( index, 0), QVector<int>() << NameRole << ColorRole );
}

int CategoryModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return int(m_category.size());
}

QVariant CategoryModel::data(const QModelIndex& index, int role) const
{
    if ( role == NameRole ){
        return m_category[ ulong( index.row() ) ].name();
    } else {
        return m_category[ ulong( index.row() ) ].color().toString();
    }
}

bool CategoryModel::setData(const QModelIndex& index, const QVariant& value, int role)
{
    if ( role == NameRole ){
        m_category[ ulong( index.row() ) ].setName( value.toString() );
        emit dataChanged( index, index, QVector<int>() << NameRole );
        emit changed( quint8( index.row() ) );
        this->saveFile();
        return true;
    } else if ( role == ColorRole ){
        m_category[ ulong( index.row() ) ].setColor( value.toString() );
        emit dataChanged( index, index, QVector<int>() << ColorRole );
        emit changed( quint8( index.row() ) );
        this->saveFile();
        return true;
    }
    return false;
}

void CategoryModel::addCategory(QString name, QString color)
{
    emit beginInsertRows( QModelIndex(), int (m_category.size() ), int ( m_category.size() ) );
    m_category.emplace_back( name, color );
    this->saveFile();
    emit endInsertRows();
    emit added( m_category.size()-1 );
}

void CategoryModel::removeCategory(quint8 index)
{
    emit beginRemoveRows( QModelIndex(), index, index );
    m_category.erase( m_category.begin() + index );
    this->saveFile();
    emit endRemoveRows();
    emit removed( index );
}

QHash<int, QByteArray> CategoryModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[ NameRole  ] = "name";
    roles[ ColorRole ] = "categoryColor";

    return roles;
}

bool CategoryModel::readFile()
{
#define P_C_STR(a) reinterpret_cast< char* >(&(a)), sizeof(a)

    if ( m_fileName != "" ){
        std::fstream file( m_fileName.toStdString(), std::ios::in | std::ios::binary );
        if ( file.is_open() ) {
            file >> std::noskipws;
            quint32 color;
            char byte;
            QByteArray nameBytes;
            file.read( P_C_STR( color ) );
            while ( !file.eof() ){
                nameBytes.clear();
                file >> byte;
                while ( byte != 0 ) {
                    nameBytes += byte;
                    file >> byte;
                }
                m_category.emplace_back( QString::fromUtf8( nameBytes ), color );
                file.read( P_C_STR( color ) );
            }
            return true;
        }
    }
    return false;
}

bool CategoryModel::saveFile()
{
    if ( m_fileName != "" ){
        std::fstream file( m_fileName.toStdString(), std::ios::out | std::ios::binary );
        if ( file.is_open() ){
            for ( auto& category : m_category ){

                file.write( category.color().toCharArray(), 4 );

                QByteArray ba = category.name().toUtf8() + char(0);
                file.write( ba.data(), ba.size() );

            }
            file.close();
            return true;
        }
    }
    return false;
}
