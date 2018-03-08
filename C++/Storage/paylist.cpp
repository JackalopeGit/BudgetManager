#include "paylist.h"

PayList::PayList(CategoryModel* catModel, Strings* curModel, QObject *parent)
    : QAbstractListModel(parent),
      getData    (
          new std::function<QVariant(ulong)>[LastRole - Qt::UserRole + 1]
      ),
      setPayData(
          new std::function<void(ulong,QVariant)>[LastRole - Qt::UserRole + 1]
      ),
      p_categoryModel( catModel ),
      p_currencyModel( curModel ),
      m_isSignNegativeSelected( false ),
      m_isSignPositiveSelected( false ),
      m_isYearSelected( false ),
      m_isMonthSelected( false ),
      m_isDaySelected( false ),
      m_isDateRangeSelected( false ),
      m_categorySelectedCount(0),
      m_currencySelectedCount(0),
      m_dateSelectionBegin(0,0,0,0,0),
      m_dateSelectionEnd( Date::YearMax, Date::MonthMax, Date::DayMaxDec,
                          Date::HourMax, Date::MinuteMax),
      m_fileName( "pays" )
{
    this->prepareGetters();
    this->prepareSetters();

    for ( quint16 i = 0; i < Strings::MAX; i++ ){
        m_categorySelected.push_back( false );
        m_currencySelected.push_back( false );
    }
    this->readFile();
}

PayList::~PayList()
{
    this->clear();
    delete[] setPayData;
    delete[] getData;
}


void PayList::readFile()
{
    m_pay.clear();

    std::fstream file( m_fileName.toStdString(), std::ios::in | std::ios::binary );
    if ( file.is_open() ){

        file >> std::noskipws;

#define P_C_STR(a) reinterpret_cast< char* >(&(a)), sizeof(a)

        qint64 sum;
        quint32 date;
        char currency, category, flags, byte;
        quint16 tNo;
        QByteArray descriptionByteArray;

        file >> flags;
        while ( !file.eof() )
        {
            descriptionByteArray.clear();
            if ( flags & PayFlags::NotDeleted )
            {
                file.read( P_C_STR(sum) );
                file.read( P_C_STR(date) );
                file >> currency;
                file >> category;
                file.read( P_C_STR(tNo) );

                file >> byte;
                while ( byte != DescriptionEnd ) {
                    descriptionByteArray += byte;
                    file >> byte;
                }

                m_pay.emplace_back(
                            new Pay(
                                sum,
                                date,
                                currency,
                                category,
                                tNo,
                                QString::fromUtf8( descriptionByteArray ),
                                PayFlags ( flags )
                                )
                            );
            }
            else
            {
                file.seekg( ByteCount, std::ios_base::cur );
                file >> byte;
                while ( byte != DescriptionEnd ) {
                    file >> byte;
                }
            }
            file >> flags;  // moved to the end for EOF compatibility
        }

        file.close();
    }
}

void PayList::clear()
{
    for ( Pay* pay : m_pay ){
        delete pay;
    }
    m_pay.clear();
}

void PayList::sortDate( quint32 beforeIndex )
{
    ulong size = beforeIndex, step = size;
    if ( size > 0 ){
        float loadFactor = 1.247f;
        bool isSorted = false;
        while ( !isSorted ) {
            isSorted = true;
            step /= loadFactor;
            if ( step < 1 ) {
                step = 1;
            }
            for ( quint32 i = 0; i < size - 1; i++ ) {
                if ( (i + step) < size ) {
                    if ( m_pay[i]->getDate() > m_pay[ i + step ]->getDate() )
                    {
                        std::swap( m_pay[i], m_pay[i + step]);
                        isSorted = false;
                    }
                } else {
                    isSorted = false;
                }
            }
        }
    }
}

void PayList::sortDate(Date startDate)
{
    quint32 i;
    for ( i = m_pay.size() - 1; i > 0 && m_pay[i]->getDate() < startDate  ; i-- ) ;
    this->sortDate( i );
}

void PayList::sortAfterT(Date startDate, quint32 newPayCount)
{
    quint32 startIndex;
    for ( startIndex = m_pay.size(); startIndex > 0 && m_pay[--startIndex]->getDate() > startDate; );


    std::vector< Pay* > temp, newPays;

    quint32 newBegin = m_pay.size() - newPayCount;

    quint32 i;
    for ( i = startIndex; i < newBegin;     temp.push_back( m_pay[i++]    ) );
    for (               ; i < m_pay.size(); i++ ){
        newPays.push_back( m_pay[i] );
        emit payAdded( m_pay[i] );
    }

    quint32 newIndex(0), tempIndex(0);

    i = startIndex;

    while ( tempIndex < temp.size() && newIndex < newPays.size() )
    {
        if ( temp[tempIndex]->getDate() < newPays[newIndex]->getDate() )
        {
            m_pay[i++] = temp[tempIndex++];
        } else
        {
            m_pay[i++] = newPays[newIndex++];
        }
    }
    for (; tempIndex < temp.size();   m_pay[i++] = temp[tempIndex++] );
    for (; newIndex < newPays.size(); m_pay[i++] = newPays[newIndex++] );

    this->saveFile();
}



void PayList::saveFile()
{
    std::fstream file( m_fileName.toStdString(), std::ios::out | std::ios::binary | std::ios::trunc );
    if ( file.is_open() ){

        file >> std::noskipws;

        QByteArray description;

        qint64  v64; quint32 v32; quint16 v16;

#define C_STR(a) reinterpret_cast< const char* >(&(a)), sizeof(a)

        for ( auto pay : m_pay ){
            file << char( pay->getFlags() );
            file.write( C_STR(v64 = pay->getSum()) );
            file.write( C_STR(v32 = pay->getDate().toQuint32()) );
            file << char( pay->getCurrency() )
                 << char( pay->getCategory() );
            file.write( C_STR(v16 = pay->getTNo()) );

            description = pay->getDescription().toUtf8() += DescriptionEnd;
            file.write( description.data(), description.size() );
        }

        file.close();
    }
}

void PayList::createPay(

        bool isPositive,
        QString sumInteger,
        QString sumFraction,

        quint16 year,
        quint8  month,
        quint8  day,
        quint8  hour,
        quint8  minute,

        quint8 currency,
        quint8 category,
        QString description

        )
{

    auto sum = qint64 (
                   isPositive ?
                       sumInteger.toLongLong() * 100 + sumFraction.toInt()
                     : - ( sumInteger.toLongLong() * 100 + sumFraction.toInt() )
                       );

    this->appendPay(
                new Pay(

                    sum,
                    Date( year, month, day, hour, minute ),
                    currency,
                    category,
                    0,
                    description,
                    PayFlags( PayFlags::NotDeleted )

                    )
                );
}

void PayList::appendPay(Pay* newPay)
{

    quint32 i = 0;
    if ( m_pay.size() != 0 ){
        if ( m_pay[0]->getDate() <= newPay->getDate() ){
            for ( i = m_pay.size(); m_pay.at( --i )->getDate() > newPay->getDate(); );
            ++i;
        }
    }
    m_pay.emplace( m_pay.begin() + (i), newPay );

    this->saveFile();

    this->refreshSelection();
    emit payAdded( newPay );
}

void PayList::addPayUnsave(Pay* newPay)
{
    m_pay.emplace_back( newPay );
}


void PayList::erasePay(quint32 index )
{
    beginRemoveRows( QModelIndex(), int(index), int(index) );
    emit payRemoved( m_pay[m_sel[index]] );
    delete m_pay[m_sel[index]];
    m_pay.erase( m_pay.begin() + m_sel[index] );

    std::fstream file( m_fileName.toStdString(), std::ios::out | std::ios::in | std::ios::binary );

    if ( file.is_open() ){

        file >> std::noskipws;

        quint32 i = 0;
        char byte;
        while ( i < m_sel[index] ){
            file >> byte;
            if ( byte ) {
                i++;
            }
            file.seekg( ByteCount, std::ios_base::cur );
            file >> byte;
            while ( byte != DescriptionEnd ) {
                file >> byte;
            }
        }
        file >> byte;
        while ( !byte ) {
            file.seekg( ByteCount, std::ios_base::cur );
            file >> byte;
            while ( byte != DescriptionEnd ) {
                file >> byte;
            }
            file >> byte;
        }
        file.seekp( -1, file.cur );

        file << char( PayFlags::Deleted );

        file.close();
    }

    for ( size_t i{0}; m_sel[index] < m_sel[i] && i < m_sel.size(); i++ ){
        --m_sel[i];
    }
    m_sel.erase( m_sel.begin() + long(index) );
    endRemoveRows();

}


void PayList::categoryRemoved( quint8 categoryNo )
{
    beginResetModel();
    quint8 current;
    for ( quint32 i = 0; i < m_pay.size(); i++){
        current = m_pay[i]->getCategory();
        if ( current >= categoryNo ){
            if ( current > categoryNo ){
                m_pay[i]->setCategory( --current );
            } else {
                m_pay[i]->setCategory( Pay::EMPTY );
            }
        }
    }
    this->saveFile();
    endResetModel();
}

void PayList::categoryChanged( quint8 categoryNo )
{
    QVector< int > roles;
    roles << CategoryRole << CategoryColorRole;
    for ( quint32 i = 0; i < m_sel.size(); i++ ){
        if ( m_pay[m_sel[ i ]]->getCategory() == categoryNo ){
            dataChanged( index( int(i), 0 ), index( int(i), 0 ), roles );
        }
    }
}

void PayList::currencyRemoved(quint8 currencyNo)
{
    beginResetModel();
    quint8 current;
    for ( quint32 i = 0; i < m_pay.size(); i++){
        current = m_pay[i]->getCurrency();
        if ( current >= currencyNo ){
            if ( current > currencyNo ){
                m_pay[i]->setCurrency( --current );
            } else {
                m_pay[i]->setCurrency( Pay::EMPTY );
            }
        }
    }
    this->saveFile();
    endResetModel();
}

void PayList::currencyRenamed(quint8 currencyNo)
{
    QVector< int > roles;
    roles.append( CurrencyRole );
    for ( quint32 i = 0; i < m_pay.size(); i++ ){
        if ( m_pay[ i ]->getCurrency() == currencyNo ){
            dataChanged( index( int(i), 0 ), index( int(i), 0 ), roles );
        }
    }
}

void PayList::tRemoved(quint16 tNo)
{
    quint32 prev(0);
    for ( quint32 i = 0; i < m_pay.size(); i++ ){
        if ( m_pay[i]->getTNo() != tNo ){
            m_pay[prev++] = m_pay[i];
        } else {
            emit payRemoved( m_pay[i] );
            delete m_pay[i];
        }
    }
    m_pay.resize( prev );
    this->saveFile();
    this->refreshSelection();
}



void PayList::refreshSelection()
{
    emit beginResetModel();
    if ( m_sel.size() ){
        m_sel.clear();
    }
    for ( ulong i = m_pay.size(); i > 0; ){
        if ( this->checkSelection( m_pay[--i] ) ){
            m_sel.push_back( i );
        }
    }
    emit endResetModel();
}

void PayList::sortDate()
{
    this->sortDate(m_pay.size());
}

bool PayList::checkSelection( Pay* target )
{
    if ( m_isSignPositiveSelected != m_isSignNegativeSelected ){
        if ( m_isSignPositiveSelected ){
            if ( target->getSum() < 0 ){
                return false;
            }
        } else {
            if ( target->getSum() > 0 ){
                return false;
            }
        }
    }
    if ( m_categorySelectedCount && !m_categorySelected[ target->getCategory() ] ){
        return false;
    }
    if ( m_currencySelectedCount && !m_currencySelected[ target->getCurrency() ] ){
        return false;
    }
    if ( m_isDateRangeSelected ){
        Date current = target->getDate();
        if ( current < m_dateSelectionBegin || current > m_dateSelectionEnd ){
            return false;
        }
    } else if ( m_isYearSelected ){
        if ( target->getDate().year() != m_dateSelectionBegin.year() ){
            return false;
        }
    } else if ( m_isMonthSelected ){
        Date current = target->getDate();
        if ( current.year() != m_dateSelectionBegin.year() || current.month() != m_dateSelectionBegin.month() ){
            return false;
        }
    } else if ( m_isDaySelected ){
        if ( !target->getDate().isDateEqual(m_dateSelectionBegin) ){
            return false;
        }
    }
    return true;
}

bool PayList::isCategorySelected(quint8 categoryNo) const
{
    return m_categorySelected[ categoryNo ];
}

bool PayList::isCurrencySelected(quint8 currencyNo) const
{
    return m_currencySelected[ currencyNo ];
}

bool PayList::isOneCurrencySelected() const
{
    return m_currencySelectedCount == 1;
}

bool PayList::isCategorySelected() const
{
    return m_categorySelectedCount;
}

bool PayList::isCurrencySelected() const
{
    return m_currencySelectedCount;
}

void PayList::selectionReset()
{
    if ( ( m_isSignNegativeSelected != m_isSignPositiveSelected )
         || m_categorySelectedCount || m_currencySelectedCount ){

        beginResetModel();

        m_isSignPositiveSelected = false;
        m_isSignNegativeSelected = false;

        if ( m_categorySelectedCount ){

            m_categorySelectedCount = 0;
            for ( quint16 i = 0; i < Strings::MAX; i++ ){
                m_categorySelected[i] = false;
            }
        }
        if ( m_currencySelectedCount ) {

            m_currencySelectedCount = 0;
            for ( quint16 i = 0; i < Strings::MAX; i++ ){
                m_currencySelected[i] = false;
            }
        }
        this->refreshSelection();
        endResetModel();
    }
}

void PayList::selectSumSign(bool isPositive)
{
    if ( isPositive ){
        if ( !m_isSignPositiveSelected ){
            beginResetModel();
            m_isSignPositiveSelected = true;
            this->refreshSelection();
            endResetModel();
        }
    } else {
        if ( !m_isSignNegativeSelected ){
            beginResetModel();
            m_isSignNegativeSelected = true;
            this->refreshSelection();
            endResetModel();
        }
    }
}

void PayList::selectSumSignRemove( bool isPositive )
{
    if ( isPositive ){
        if ( m_isSignPositiveSelected ){
            beginResetModel();
            m_isSignPositiveSelected = false;
            this->refreshSelection();
            endResetModel();
        }
    } else {
        if ( m_isSignNegativeSelected ){
            beginResetModel();
            m_isSignNegativeSelected = false;
            this->refreshSelection();
            endResetModel();
        }
    }
}

void PayList::selectionCategoryAdd(quint8 categoryNo)
{
    if  ( m_categorySelected[ categoryNo ] != true ){
        beginResetModel();
        m_categorySelectedCount ++;
        m_categorySelected[ categoryNo ] = true;
        this->refreshSelection();
        endResetModel();
    }
}

void PayList::selectionCategoryRemove(quint8 categoryNo)
{
    if  ( m_categorySelected[ categoryNo ] != false ){
        beginResetModel();
        m_categorySelectedCount --;
        m_categorySelected[ categoryNo ] = false;
        this->refreshSelection();
        endResetModel();
    }
}

void PayList::selectionCategoryReset()
{
    if ( m_categorySelectedCount > 0 ) {
        beginResetModel();
        m_categorySelectedCount = 0;
        for ( quint16 i = 0; i < Strings::MAX; i++ ){
            m_categorySelected[i] = false;
        }
        this->refreshSelection();
        endResetModel();
    }
}

void PayList::selectionCurrencyAdd(quint8 currencyNo)
{
    if  ( m_currencySelected[ currencyNo ] != true ){
        beginResetModel();
        m_currencySelectedCount ++;
        m_currencySelected[ currencyNo ] = true;
        this->refreshSelection();
        endResetModel();
    }
}

void PayList::selectionCurrencyRemove(quint8 currencyNo)
{
    if  ( m_currencySelected[ currencyNo ] != false ){
        beginResetModel();
        m_currencySelected[ currencyNo ] = false;
        m_currencySelectedCount--;
        this->refreshSelection();
        endResetModel();
    }
}

void PayList::selectionCurrencyReset()
{
    if ( m_currencySelectedCount > 0 ) {
        beginResetModel();
        m_currencySelectedCount = 0;
        for ( quint16 i = 0; i < Strings::MAX; i++ ){
            m_currencySelected[i] = false;
        }
        this->refreshSelection();
        endResetModel();
    }
}

void PayList::selectDateRange(quint16 yearBegin, quint8 monthBegin, quint8 dayBegin,
                              quint16 yearEnd,   quint8 monthEnd,   quint8 dayEnd)
{
    beginResetModel();
    m_isDateRangeSelected = true;
    m_isYearSelected = m_isMonthSelected = m_isDaySelected   = false;
    m_dateSelectionBegin.setYear( yearBegin).setMonth( monthBegin ).setDay( dayBegin   );
    m_dateSelectionEnd  .setYear( yearEnd  ).setMonth( monthEnd   ).setDay( dayEnd   );
    this->refreshSelection();
    endResetModel();
}

void PayList::selectYear(quint16 year)
{
    beginResetModel();
    m_isDateRangeSelected = m_isMonthSelected = m_isDaySelected = false;
    m_isYearSelected  = true;
    m_dateSelectionBegin.setYear(year);
    this->refreshSelection();
    endResetModel();
}

void PayList::selectMonth(quint16 year, quint8 month)
{
    beginResetModel();
    m_isDateRangeSelected = m_isYearSelected = m_isDaySelected = false;
    m_isMonthSelected = true;
    m_dateSelectionBegin.setYear(year).setMonth(month);
    this->refreshSelection();
    endResetModel();
}

void PayList::selectDay(quint16 year, quint8 month, quint8 day)
{
    beginResetModel();
    m_isDateRangeSelected = m_isYearSelected = m_isMonthSelected = false;
    m_isDaySelected = true;
    m_dateSelectionBegin.setYear(year).setMonth(month).setDay(day);
    this->refreshSelection();
    endResetModel();
}

void PayList::selectionDateReset()
{
    if ( m_isDateRangeSelected ||  m_isYearSelected || m_isMonthSelected || m_isDaySelected ){
        beginResetModel();
        m_isDateRangeSelected = m_isYearSelected = m_isMonthSelected = m_isDaySelected = false;
        m_dateSelectionBegin.setYear( Date::YearMin   ).setMonth( Date::MonthMin  ).setDay( Date::DayMin    );
        m_dateSelectionEnd.  setYear( Date::YearMax   ).setMonth( Date::MonthMax  ).setDay( Date::DayMaxDec );
        this->refreshSelection();
        endResetModel();
    }
}


////////////////////////////////////////////////////////////////////////////////
////////////////////////  MODEL FUNCTIONS  /////////////////////////////////////

int PayList::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return int( m_sel.size() );
}


QVariant PayList::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    return getData[ role - Qt::UserRole + 1 ]( ulong( index.row() ) );
}

bool PayList::setData(const QModelIndex& index, const QVariant& value, int role)
{
    ulong payNo = m_sel[ index.row() ];
    setPayData[ role - Qt::UserRole + 1 ]( payNo, value );

    emit dataChanged( index, index, QVector<int>() << role );


    std::fstream file( m_fileName.toStdString(), std::ios::out | std::ios::in | std::ios::binary );
    if ( file.is_open() ){

        file >> std::noskipws;

        file.seekg( 1, file.beg );
        ulong i = 0;
        char byte;
        while ( i < payNo ){
            file >> byte;
            if ( byte & PayFlags::NotDeleted ) {
                i++;
            }
            file.seekg( ByteCount, file.cur );
            file >> byte;
            while ( byte != DescriptionEnd ){
                file >> byte;
            }
        }
        file >> byte;
        while ( !(byte & PayFlags::NotDeleted) ) {
            file >> byte;
            while ( byte != DescriptionEnd ){
                file >> byte;
            }
            file >> byte;
        }
        file.seekp( -1, file.cur );

        quint64 sum;
        quint32 date;
        quint16 tNo;
        file << char(m_pay.at( ulong(i) )->getFlags());
        file.write( reinterpret_cast< const char* >(  &(sum = m_pay.at( ulong(i) )->getSum())),
                    sizeof (qint64)  );
        file.write( reinterpret_cast< const char* >(  &(date = m_pay.at( ulong(i) )->getDate().toQuint32())),
                    sizeof (quint32) );
        file << char( m_pay.at( ulong(i) )->getCurrency() )
             << char( m_pay.at( ulong(i) )->getCategory() );
        file.write( reinterpret_cast< const char* >( &(tNo = m_pay.at( ulong(i))->getTNo() ) ), sizeof (quint16) );
        QByteArray description = m_pay.at( ulong(i) )->getDescription().toUtf8();
        file.write( (description += DescriptionEnd).data(), description.size() );

        file.close();
    }
    return true;
}

QHash<int, QByteArray> PayList::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[IsIncomeRole]      = "isIncome";
    roles[SumIntegerRole]    = "sumInteger";
    roles[SumFractionRole]   = "sumFraction";
    roles[CategoryRole]      = "category";
    roles[CategoryColorRole] = "categoryColor";
    roles[CurrencyRole]      = "currency";
    roles[DescriptionRole]   = "description";
    roles[YearRole]          = "year";
    roles[MonthRole]         = "month";
    roles[DayRole]           = "day";
    roles[HourRole]          = "hour";
    roles[MinuteRole]        = "minute";
    roles[FromTPayRole]      = "isFromTPay";


    return roles;

}

size_t PayList::size() const
{
    return m_pay.size();
}

const Pay* PayList::operator [](size_t i) const
{
    return m_pay[i];
}

void PayList::prepareGetters()
{
    getData[IsIncomeRole - Qt::UserRole + 1 ] = [this] ( quint32 index ) {
        return m_pay[m_sel[index]]->getSum() > 0;
    };
    getData[SumIntegerRole - Qt::UserRole + 1 ] = [this] ( quint32 index )
    {
        auto sum = QString::number( m_pay.at( m_sel[index] )->getSum() / 100 );
        for ( quint8 i = sum.length() % 3; i < sum.length() - 2; i+=4)
        {
            sum.insert( i, ' ' );
        }
        if ( m_pay.at( m_sel[index] )->getSum() > 0 ) {
            return QVariant( QString( "+ " + sum ) );
        }
        return QVariant( sum.insert( 1, ' ' ) );
    };
    getData[SumFractionRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        quint8 sum = abs((m_pay.at( m_sel[index] ))->getSum()%100);
        return sum == 0 ? QVariant(" ") : QVariant(sum);
    };
    getData[CategoryRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( (*p_categoryModel)[ m_pay[ m_sel[index] ]->getCategory() ] );
    };
    getData[CategoryColorRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( p_categoryModel->getColor( m_pay[ m_sel[index] ]->getCategory() ) );
    };
    getData[CurrencyRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( (*p_currencyModel)[ m_pay[ m_sel[index] ]->getCurrency() ] );
    };
    getData[DescriptionRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( m_pay[ m_sel[index] ]->getDescription() );
    };
    getData[YearRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( m_pay.at( m_sel[index] )->getDate().year() );
    };
    getData[MonthRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( m_pay.at( m_sel[index] )->getDate().month());
    };
    getData[DayRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( m_pay.at( m_sel[index] )->getDate().day() );
    };
    getData[HourRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( m_pay.at( m_sel[index] )->getDate().hour() );
    };
    getData[MinuteRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( m_pay.at( m_sel[index] )->getDate().minute());
    };
    getData[FromTPayRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( m_pay.at( m_sel[index] )->isFromTPay() );
    };
}

void PayList::prepareSetters()
{
    setPayData[SumIntegerRole - Qt::UserRole + 1 ] = [this] ( quint32 index, QVariant value )
    {
        m_pay[ m_sel[index] ]->setSum(
                    value.toLongLong() * 100
                    + m_pay[ m_sel[index] ]->getSum() % 100
                );
    };
    setPayData[SumFractionRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_pay[ m_sel[index] ]->setSum(
                    m_pay[ m_sel[index] ]->getSum() / 100 * 100
                + value.toInt() % 100
                );
    };
    setPayData[CategoryRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_pay[ m_sel[index] ]->setCategory( quint8(value.toInt()) );
    };
    setPayData[CurrencyRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_pay[ m_sel[index] ]->setCurrency(quint8(value.toInt()) );
    };
    setPayData[DescriptionRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_pay[ m_sel[index] ]->setDescription( value.toString() );
    };
    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////

    setPayData[YearRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_pay[ m_sel[index] ]->setDate( m_pay[ m_sel[index] ]->getDate().setYear( quint16( value.toInt() ) ) );
    };
    setPayData[MonthRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_pay[ m_sel[index] ]->setDate( m_pay[ m_sel[index] ]->getDate().setMonth(quint8( value.toInt() ) ) );
    };
    setPayData[DayRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_pay[ m_sel[index] ]->setDate( m_pay[ m_sel[index] ]->getDate().setDay( quint8( value.toInt() ) ) );
    };
    setPayData[HourRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_pay[ m_sel[index] ]->setDate( m_pay[ m_sel[index] ]->getDate().setHour( quint8( value.toInt() ) ) );
    };
    setPayData[MinuteRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_pay[ m_sel[index] ]->setDate( m_pay[ m_sel[index] ]->getDate().setMinute( quint8( value.toInt() ) ) );
    };
    setPayData[FromTPayRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_pay.at( m_sel[index] )->setIsFromTPay( value.toBool() );
    };
}
