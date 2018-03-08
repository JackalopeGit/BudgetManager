#include "Strings.h"

Strings::Strings(QString fileName)
{
   fileName_ = fileName;
   assert ( this->readFile() );
}

Strings::~Strings()
{
   assert ( this->saveFile() );
}


bool Strings::readFile()
{
   data_.clear();
   if ( fileName_ != "" ){
      QFile file( fileName_ );
      if ( file.open( QIODevice::ReadOnly | QIODevice::Text ) ){

         QTextStream in(&file);
         in.setCodec("UTF-8");
         while (!in.atEnd()) {
            data_.push_back( in.readLine() );
         }
         return true;
      } else {
         file.open(QIODevice::WriteOnly);
         data_.push_back("");
         return true;
      }
   } return false;
}

bool Strings::saveFile()
{
   QFile file( fileName_ );
   if ( file.open( QFile::WriteOnly | QFile::Text ) ){
      QTextStream out ( &file );
      out.setCodec("UTF-8");
      for ( auto str : data_ ){
         str.push_back("\n");
         out << str.toUtf8();
      }
      file.close();
      return true;
   }
   return false;
}

QString Strings::operator[](quint8 index) const
{
    return data_.at( index );
}

quint8 Strings::size() const
{
    return quint8(data_.size());
}

QString Strings::getName(quint8 index)
{
    return data_.at( index );
}

int Strings::rowCount(const QModelIndex& parent) const
{
   Q_UNUSED( parent )
   return data_.size();
}

QVariant Strings::data(const QModelIndex &index, int role) const
{
   if (!index.isValid())
      return QVariant();

   if ( role == NameRole ){
      return data_[ index.row() ];
   } else if ( role == NumberRole ){
      return index.row();
   }

   return QVariant();
}

bool Strings::set( int row, QString value )
{
   data_[ row ] = value;
   this->saveFile();
   emit dataChanged( index( row ), index( row ), QVector<int>() << NameRole );
   emit renamed( quint8( row ) );
   return true;
}

bool Strings::insertRows(int row, int count, const QModelIndex& parent)
{
   if ( data_.size() + count <= MAX ){
      beginInsertRows( parent, row, row + count - 1 );
      for ( quint16 i = 0; i < count; i++ ){
         data_.insert( row, "" );
      }
      this->saveFile();
      endInsertRows();
      emit added( row );
      return true;
   } else {
      return false;
   }
}

bool Strings::removeRows(int row, int count, const QModelIndex& parent)
{
   if ( row > -1 && row < data_.size() ){
      beginRemoveRows(parent, row, row + count - 1);
      for ( quint16 i = 0; i < count; i++ ){
         data_.remove( row );
         emit removed( quint8 ( row ) );
      }
      this->saveFile();
      endRemoveRows();
      return true;
   }
   return false;
}

QHash<int, QByteArray> Strings::roleNames() const
{
   QHash<int, QByteArray> roles;

   roles[ NameRole ]   = "name";
   roles[ NumberRole ] = "number";

   return roles;
}
