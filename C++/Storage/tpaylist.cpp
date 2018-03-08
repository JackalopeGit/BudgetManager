#include "tpaylist.h"

TPayList::TPayList(
        PayList* payList,
        CategoryModel* category,
        Strings* currency,
        Settings* settings,
        QObject *parent
        )

    : QAbstractListModel(parent),
      p_payList( payList ),
      p_category( category ),
      p_currency( currency ),
      getData    (
          new std::function<QVariant(ulong)>[LastRole - Qt::UserRole + 1]
      ),
      setTPayData(
          new std::function<void(ulong,QVariant)>[LastRole - Qt::UserRole + 1]
      ),
      m_isSignNegativeSelected( false ),
      m_isSignPositiveSelected( false ),
      m_categorySelectedCount(0),
      m_currencySelectedCount(0),
      m_fileName( "tpays" ),
      p_timer ( new QTimer(this) ),
      p_settings( settings )
{
    p_category = category;
    p_currency = currency;

    this->prepareGetters();
    this->prepareSetters();

    for ( quint16 i = 0; i < 256; i++ )
    {
        m_categorySelected.push_back( false );
        m_currencySelected.push_back( false );
    }

    this->readFile();
    this->refreshSelection();
    this->refreshPays();
    this->startTimer();
}

TPayList::~TPayList()
{
    this->clear();
    delete [] getData;
    delete [] setTPayData;
}

void TPayList::createTPay(

        bool isPositive,
        QString sumInteger,
        QString sumFraction,
        quint16 yearFrom,
        quint8 monthFrom,
        quint8 dayFrom,
        quint8  hourFrom,
        quint8 minuteFrom,
        quint8 periodType,
        quint16 period,
        quint8 currency,
        quint8 category,
        quint16 maxRepeat,
        bool isEnabled,
        bool isPresendBound,
        QString description

        )
{
    Date dateFrom { yearFrom, monthFrom, dayFrom, hourFrom, minuteFrom }, lastTDate{ dateFrom };

#define isNotMaxRepeatSet !isPresendBound && maxRepeat == 0

    switch (periodType) {
    case ( PayFlags::PeriodType::YEAR ):
    {
        if ( isNotMaxRepeatSet ) {
            maxRepeat = 50;
        }
        lastTDate.reduceYears ( period );
    }
        break;
    case ( PayFlags::PeriodType::MONTH ):
    {
        if ( isNotMaxRepeatSet ) {
            maxRepeat = 50 * 12;
        }
        lastTDate.reduceMonths( period );
    }
        break;
    case ( PayFlags::PeriodType::DAY ):
    {
        if ( isNotMaxRepeatSet ) {
            maxRepeat = 9999;
        }
        lastTDate.reduceDays  ( period );
    }
        break;
    case ( PayFlags::PeriodType::HOUR ):
    {
        if ( isNotMaxRepeatSet ) {
            maxRepeat = 9999;
        }
        lastTDate.reduceHour  ( period );
    }
        break;
    }

    m_tPay.emplace_back( new TPay() );

    quint32 i = 0;

    while ( m_tPay.at( i )->getDate() > dateFrom ){
        i++;
    }

    delete m_tPay.back();

    m_tPay.pop_back();

    auto sum = qint64 ( isPositive ?
                            sumInteger.toLongLong() * 100 + sumFraction.toInt()
                          : - ( sumInteger.toLongLong() * 100 + sumFraction.toInt() )
                            );


    quint16 tNo = p_settings->getLastTNo();

    PayFlags flags(PayFlags::NotDeleted
                   | (periodType << PayFlags::PeriodShift)
                   | ( isEnabled      ? PayFlags::Enabled      : 0 )
                   | ( isPresendBound ? PayFlags::PresendBound : 0 ));

    m_tPay.emplace(
                m_tPay.begin() + i,
                new TPay(
                    sum,
                    currency,
                    category,
                    ++tNo,
                    dateFrom,
                    lastTDate,
                    period,
                    maxRepeat,
                    0,
                    flags,
                    description
                    )
                );

    p_settings->setLastTNo( tNo );



    p_timer->stop();
    if ( isEnabled ){
        this->refreshPays();
    } else {
        this->saveFile();
    }
    this->refreshSelection();

    p_timer->start();
}

void TPayList::eraseTPay(quint32 position)
{
    beginRemoveRows( QModelIndex(), int( position ), int ( position ) );
    emit tRemoved( m_tPay[m_sel[ position ]]->getTNo() );
    delete m_tPay[m_sel[position]];
    m_tPay.erase( m_tPay.begin() + m_sel[ position ] );

    this->saveFile();

    m_sel.erase( m_sel.begin() + position );
    for ( auto &sel : m_sel ){
        if ( sel >= position ) --sel;
    }
    endRemoveRows();
}

////////////////////////  PERIODIC SERVICE   ///////////////////////////////////


void TPayList::startTimer()
{
    connect( p_timer, SIGNAL(timeout() ), this, SLOT( refreshPays() ) );
    p_timer->start( 60000 );
}

void TPayList::refreshPays()
{
    QDateTime qDate = QDateTime::currentDateTime();
    Date lastTDate, currentDate = Date( qDate.date().year(), qDate.date().month(), qDate.date().day(),
                                        qDate.time().hour(), qDate.time().minute() );
    Date oldestDate(currentDate);
    quint32 newPayCount(0);
    bool payChanged(false);



//[!] Functions
    auto NeedToAdd = [ &lastTDate, &currentDate, this ]( quint32 i) -> bool
    {
        return ( ( !m_tPay[i]->isPresentBound() || lastTDate <= currentDate )
                 && ( m_tPay.at(i)->getNRepeat() < m_tPay.at(i)->getMaxRepeat()
                      || !m_tPay.at(i)->getMaxRepeat() ) );
    };

    auto UpdateTPay = [this](quint32 i)
    {
        if (m_tPay.at(i)->getNRepeat() == m_tPay.at(i)->getMaxRepeat()) { m_tPay[i]->setEnabled( false ); }
        emit dataChanged( index( int(i), int(i) ), index( int(i), int(i) ),
                          QVector<int>() << EnabledRole << NRepeatRole );
    };

    auto AddPay = [this, &payChanged, &lastTDate, &newPayCount](quint32 i)
    {
        ++(*m_tPay[i]);
        payChanged = true;
        m_tPay.at(i)->setLastTDate( lastTDate );
        p_payList->addPayUnsave(
                    new Pay(
                        m_tPay.at(i)->getSum(),
                        lastTDate,
                        m_tPay.at(i)->getCurrency(),
                        m_tPay.at(i)->getCategory(),
                        m_tPay[i]->getTNo(),
                        m_tPay.at(i)->getDescription(),
                        PayFlags( PayFlags::NotDeleted | PayFlags::FromTPay )
                        )
                    );
        newPayCount++;
    };
//[!]

    emit payModelResetStart();

    for ( quint32 i = 0; i < m_tPay.size(); i++ )
    {
        if ( m_tPay.at(i)->isEnabled() )
        {
            quint16 period = m_tPay[i]->getPeriod();

            lastTDate = m_tPay.at(i)->getLastTDate();
            if ( lastTDate < oldestDate ){
                oldestDate = lastTDate;
            }

            switch (m_tPay.at(i)->getPeriodType())
            {
            case ( PayFlags::PeriodType::MONTH ):
            {
                for ( lastTDate.addMonths( period ); NeedToAdd(i); lastTDate.addMonths( period ) ){
                    AddPay(i);
                }
            }
                break;
            case ( PayFlags::PeriodType::DAY ):
            {
                for ( lastTDate.addDays( period ); NeedToAdd(i); lastTDate.addDays( period ) ){
                    AddPay(i);
                }
            }
                break;
            case ( PayFlags::PeriodType::YEAR ):
            {
                for ( lastTDate.addYears( period ); NeedToAdd(i); lastTDate.addYears( period ) ){
                    AddPay(i);
                }
            }
                break;
            case ( PayFlags::PeriodType::HOUR ):
            {
                for ( lastTDate.addHour( period ); NeedToAdd(i); lastTDate.addHour( period ) ){
                    AddPay(i);
                }
            }
            }

            UpdateTPay(i);
        }
    }
    if ( payChanged )
    {
        this->saveFile();
        p_payList->sortAfterT( oldestDate, newPayCount );
        p_payList->refreshSelection();
    };
}

////////////////////////  MODEL FUNCTIONS  /////////////////////////////////////

int TPayList::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return int ( m_sel.size() );
}

QVariant TPayList::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    return getData[ role - Qt::UserRole + 1 ]( ulong( index.row() ) );
}

bool TPayList::setData(const QModelIndex& index, const QVariant& value, int role)
{
    setTPayData[ role - Qt::UserRole + 1 ]( ulong( index.row() ), value );

    return this->saveFile();
}


QHash<int, QByteArray> TPayList::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[IsIncomeRole]      = "isIncome";
    roles[SumIntegerRole]    = "sumInteger";
    roles[SumFractionRole]   = "sumFraction";
    roles[CategoryRole]      = "category";
    roles[CategoryColorRole] = "categoryColor";
    roles[CurrencyRole]      = "currency";
    roles[DescriptionRole]   = "description";
    roles[YearFromRole]      = "yearFrom";
    roles[MonthFromRole]     = "monthFrom";
    roles[DayFromRole]       = "dayFrom";
    roles[HourFromRole]      = "hourFrom";
    roles[MinuteFromRole]    = "minuteFrom";
    roles[PeriodTypeRole]    = "periodType";
    roles[PeriodRole]        = "period";
    roles[MaxRepeatRole]     = "maxRepeat";
    roles[NRepeatRole]       = "nRepeat";
    roles[EnabledRole]       = "isEnabled";
    roles[SelectedRole]      = "isSelected";

    return roles;
}

////////////////////////////////////////////////////////////////////////////////

void TPayList::categoryRemoved(quint8 categoryNo)
{
    beginResetModel();
    quint8 current;
    for ( quint32 i = 0; i < m_tPay.size(); i++){
        current = m_tPay[i]->getCategory();
        if ( current >= categoryNo ){
            if ( current > categoryNo ){
                m_tPay[i]->setCategory( --current );
            } else {
                m_tPay[i]->setCategory( Pay::EMPTY );
            }
        }
    }
    this->saveFile();
    endResetModel();
}

void TPayList::categoryChanged(quint8 categoryNo)
{
    QVector< int > roles;
    roles.append( CategoryRole );
    roles.append( CategoryColorRole );
    for ( quint32 i = 0; i < m_sel.size(); i++ ){
        if ( m_tPay[ m_sel[i] ]->getCategory() == categoryNo ){
            dataChanged( index( int(i), 0 ), index( int(i), 0 ), roles );
        }
    }
}

void TPayList::currencyRemoved(quint8 currencyNo)
{
    beginResetModel();
    quint8 current;
    for ( quint32 i = 0; i < m_tPay.size(); i++){
        current = m_tPay[i]->getCurrency();
        if ( current >= currencyNo ){
            if ( current > currencyNo ){
                m_tPay[i]->setCurrency( --current );
            } else {
                m_tPay[i]->setCurrency( Pay::EMPTY );
            }
        }
    }
    this->saveFile();
    endResetModel();
}

void TPayList::currencyRenamed(quint8 currencyNo)
{
    QVector< int > roles;
    roles.append( CurrencyRole );
    for ( quint32 i = 0; i < m_tPay.size(); i++ ){
        if ( m_tPay[ i ]->getCurrency() == currencyNo ){
            dataChanged( index( int(i), 0 ), index( int(i), 0 ), roles );
        }
    }
}

void TPayList::readFile()
{
    std::fstream file( m_fileName.toStdString(), std::ios::in | std::ios::binary );
    if ( file.is_open() ){

        file >> std::noskipws;

        qint64  sum;
        quint32 dateFrom,   dateLastT;
        quint16 period,     maxRepeat, nRepeat, tNo;
        char  currency,   category, flags, byte;
        QByteArray descriptionByteArray;

        file >> flags;
        while ( !file.eof() ){
            descriptionByteArray.clear();
            if ( flags & PayFlags::NotDeleted )
            {
                file.read( reinterpret_cast< char* >( &sum ), sizeof ( qint64 ) );
                file.read( reinterpret_cast< char* >( &dateFrom ), sizeof ( quint32 ) );
                file.read( reinterpret_cast< char* >( &dateLastT ), sizeof ( quint32 ) );
                file.read( reinterpret_cast< char* >( &period ), sizeof ( quint16 ) );
                file >> currency;
                file >> category;
                file.read( reinterpret_cast< char* >( &tNo ), sizeof ( quint16 ) );
                file.read( reinterpret_cast< char* >( &maxRepeat ), sizeof ( quint16 ) );
                file.read( reinterpret_cast< char* >( &nRepeat ), sizeof ( quint16 ) );
                file >> byte;
                while ( byte != DescriptionEnd ) {
                    descriptionByteArray += byte;
                    file >> byte;
                }
                m_tPay.emplace_back(
                            new TPay(
                                sum,
                                currency,
                                category,
                                tNo,
                                dateFrom,
                                dateLastT,
                                period,
                                maxRepeat,
                                nRepeat,
                                PayFlags ( flags ),
                                QString::fromUtf8( descriptionByteArray )
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

bool TPayList::saveFile()
{
    std::fstream file( m_fileName.toStdString(), std::ios::out | std::ios::binary );

    if ( file.is_open() ){

        qint64  v64; quint32 v32; quint16 v16;

        QByteArray description;

#define C_STR(a) reinterpret_cast< const char* >(&(a)), sizeof(a)

        for (TPay* tPay : m_tPay )
        {
            file << char(tPay->getFlags());
            file.write( C_STR( v64 = tPay->getSum() ) );
            file.write( C_STR( v32 = tPay->getDate().toQuint32() ) );
            file.write( C_STR( v32 = tPay->getLastTDate().toQuint32() ) );
            file.write( C_STR( v16 = tPay->getPeriod() ) );
            file << char(tPay->getCurrency())
                 << char(tPay->getCategory());
            file.write( C_STR( v16 = tPay->getTNo() ) );
            file.write( C_STR( v16 = tPay->getMaxRepeat() ) );
            file.write( C_STR( v16 = tPay->getNRepeat() ) );

            description = tPay->getDescription().toUtf8() + char(DescriptionEnd);

            file.write( description, description.size() );
        }
        file.close();

        return true;
    }
    return false;
}

void TPayList::refreshSelection()
{
    emit beginResetModel();
    if ( m_sel.size() ){
        m_sel.clear();
    }
    for ( ulong i = 0; i < m_tPay.size(); i++ ){
        if ( this->checkSelection( m_tPay[i] ) ){
            m_sel.push_back( i );
        }
    }
    emit endResetModel();
}

bool TPayList::checkSelection( TPay* target)
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
    return true;
}


void TPayList::selectionReset()
{
    if ( ( m_isSignNegativeSelected != m_isSignPositiveSelected )
         || m_categorySelectedCount || m_currencySelectedCount ){
        beginResetModel();
        m_isSignPositiveSelected = false;
        m_isSignNegativeSelected = false;
        if ( m_categorySelectedCount ){
            m_categorySelectedCount = 0;
            for ( quint16 i = 0; i < 256; i++ ){
                m_categorySelected[i] = false;
            }
        }
        if ( m_currencySelectedCount ) {
            m_currencySelectedCount = 0;
            for ( quint16 i = 0; i < 256; i++ ){
                m_currencySelected[i] = false;
            }
        }
        this->refreshSelection();
        endResetModel();
    }
}

void TPayList::selectSumSign(bool isPositive)
{
    if ( isPositive ){
        if ( !m_isSignPositiveSelected ){
            beginResetModel();
            m_isSignPositiveSelected = true;
            m_isSignNegativeSelected = false;
            this->refreshSelection();
            endResetModel();
        }
    } else {
        if ( !m_isSignNegativeSelected ){
            beginResetModel();
            m_isSignNegativeSelected = true;
            m_isSignPositiveSelected = false;
            this->refreshSelection();
            endResetModel();
        }
    }
}

void TPayList::selectSumSignReset()
{
    if ( m_isSignPositiveSelected || m_isSignNegativeSelected ){
        m_isSignPositiveSelected = false;
        m_isSignNegativeSelected = false;
        this->refreshSelection();
        endResetModel();
    }
}

void TPayList::selectionCategoryAdd(quint8 categoryNo)
{
    if  ( m_categorySelected[ categoryNo ] != true ){
        beginResetModel();
        m_categorySelectedCount++;
        m_categorySelected[ categoryNo ] = true;
        this->refreshSelection();
        endResetModel();
    }
}

void TPayList::selectionCategoryRemove(quint8 categoryNo)
{
    if  ( m_categorySelected[ categoryNo ] != false ){
        beginResetModel();
        m_categorySelectedCount --;
        m_categorySelected[ categoryNo ] = false;
        this->refreshSelection();
        endResetModel();
    }
}

void TPayList::selectionCategoryReset()
{
    if ( m_categorySelectedCount > 0 ) {
        beginResetModel();
        m_categorySelectedCount = 0;
        for ( quint16 i = 0; i < 256; i++ ){
            m_categorySelected[i] = false;
        }
        this->refreshSelection();
        endResetModel();
    }
}

bool TPayList::isCategorySelected() const
{
    return m_categorySelectedCount;
}

bool TPayList::isCategorySelected(quint8 categoryNo) const
{
    return m_categorySelected[ categoryNo ];
}

void TPayList::selectionCurrencyAdd(quint8 currencyNo)
{
    if  ( m_currencySelected[ currencyNo ] != true ){
        beginResetModel();
        m_currencySelectedCount ++;
        m_currencySelected[ currencyNo ] = true;
        this->refreshSelection();
        endResetModel();
    }
}

void TPayList::selectionCurrencyRemove(quint8 currencyNo)
{
    if  ( m_currencySelected[ currencyNo ] != false ){
        beginResetModel();
        m_currencySelected[ currencyNo ] = false;
        m_currencySelectedCount--;
        this->refreshSelection();
        endResetModel();
    }
}

void TPayList::selectionCurrencyReset()
{
    if ( m_currencySelectedCount > 0 ) {
        beginResetModel();
        m_currencySelectedCount = 0;
        for ( quint16 i = 0; i < 256; i++ ){
            m_currencySelected[i] = false;
        }
        this->refreshSelection();
        endResetModel();
    }
}

bool TPayList::isCurrencySelected() const
{
    return m_currencySelectedCount;
}

bool TPayList::isOneCurrencySelected() const
{
    return m_currencySelectedCount == 1;
}

bool TPayList::isCurrencySelected(quint8 currencyNo) const
{
    return m_currencySelected[ currencyNo ];
}

void TPayList::prepareGetters()
{
    getData[IsIncomeRole - Qt::UserRole + 1 ] = [this] ( quint32 index ) {
        return m_tPay[m_sel[index]]->getSum() > 0;
    };
    getData[SumIntegerRole - Qt::UserRole + 1 ] = [this] ( quint32 index )
    {
        auto sum = QString::number( m_tPay.at( m_sel[index] )->getSum() / 100 );
        for ( quint8 i = sum.length() % 3; i < sum.length() - 2; i+=4)
        {
            sum.insert( i, ' ' );
        }
        if ( m_tPay.at( m_sel[index] )->getSum() > 0 ) {
            return QVariant( QString( "+ " + sum ) );
        }
        return QVariant( sum.insert( 1, ' ' ) );
    };
    getData[SumFractionRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        quint8 sum = abs((m_tPay.at( m_sel[index] ))->getSum()%100);
        return sum == 0 ? QVariant(" ") : QVariant(sum);
    };
    getData[CategoryRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( p_category->operator[]( m_tPay[ m_sel[index] ]->getCategory() ) );
    };
    getData[CategoryColorRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant( p_category->getColor( m_tPay[ m_sel[index] ]->getCategory() ) );
    };
    getData[CurrencyRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( p_currency->operator[]( m_tPay[ m_sel[index] ]->getCurrency() ) );
    };
    getData[DescriptionRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( m_tPay[ m_sel[index] ]->getDescription() );
    };
    getData[YearFromRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( m_tPay.at( m_sel[index] )->getDate().year() );
    };
    getData[MonthFromRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( m_tPay.at( m_sel[index] )->getDate().month());
    };
    getData[DayFromRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( m_tPay.at( m_sel[index] )->getDate().day() );
    };
    getData[HourFromRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( m_tPay.at( m_sel[index] )->getDate().hour() );
    };
    getData[MinuteFromRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant (m_tPay.at( m_sel[index] )->getDate().minute());
    };
    getData[PeriodTypeRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( m_tPay.at( m_sel[index] )->getPeriodType() );
    };
    getData[PeriodRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( m_tPay.at( m_sel[index] )->getPeriod() );
    };
    getData[MaxRepeatRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( m_tPay.at( m_sel[index] )->getMaxRepeat() );
    };
    getData[NRepeatRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( m_tPay.at( m_sel[index] )->getNRepeat() );
    };
    getData[EnabledRole - Qt::UserRole +1 ] = [this] ( quint32 index ) {
        return QVariant ( m_tPay.at( m_sel[index] )->isEnabled() );
    };

}

void TPayList::prepareSetters()
{

    setTPayData[SumIntegerRole - Qt::UserRole + 1 ] = [this] ( quint32 index, QVariant value )
    {
        m_tPay[ m_sel[index] ]->setSum( value.toLongLong() * 100 + m_tPay[ m_sel[index] ]->getSum() % 100 );
    };
    setTPayData[SumFractionRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_tPay[ m_sel[index] ]->setSum( m_tPay[ m_sel[index] ]->getSum() / 100 * 100 + value.toInt() % 100 );
    };
    setTPayData[CategoryRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_tPay[ m_sel[index] ]->setCategory( quint8(value.toInt()) );
    };
    setTPayData[CurrencyRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_tPay[ m_sel[index] ]->setCurrency(quint8(value.toInt()) );
    };
    setTPayData[DescriptionRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_tPay[ m_sel[index] ]->setDescription( value.toString() );
    };
    setTPayData[YearFromRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_tPay[ m_sel[index] ]->setDate( m_tPay[ m_sel[index] ]->getDate().setYear( quint16( value.toInt() ) ) );
    };
    setTPayData[MonthFromRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_tPay[ m_sel[index] ]->setDate( m_tPay[ m_sel[index] ]->getDate().setMonth( quint8( value.toInt() ) ) );
    };
    setTPayData[DayFromRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_tPay[ m_sel[index] ]->setDate(
                    m_tPay[ m_sel[index] ]->getDate().setDay(
                    quint8( value.toInt() ) ) );
    };
    setTPayData[HourFromRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_tPay[ m_sel[index] ]->setDate( m_tPay[ m_sel[index] ]->getDate().setHour( quint8( value.toInt() ) ) );
    };
    setTPayData[MinuteFromRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_tPay[ m_sel[index] ]->setDate( m_tPay[ m_sel[index] ]->getDate().setMinute( quint8( value.toInt() ) ) );
    };
    setTPayData[PeriodTypeRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_tPay.at( m_sel[index] )->setPeriodType( PayFlags::PeriodType( value.toInt() ) );
    };
    setTPayData[PeriodRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_tPay.at( m_sel[index] )->setPeriod( quint8( value.toInt() ) );
    };
    setTPayData[MaxRepeatRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_tPay.at( m_sel[index] )->setMaxRepeat( quint8( value.toInt() ) );
    };
    setTPayData[NRepeatRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        m_tPay.at( m_sel[index] )->setNRepeat( quint8( value.toInt() ) );
    };
    setTPayData[EnabledRole - Qt::UserRole +1 ] = [this] ( quint32 index, QVariant value )
    {
        auto current = QDateTime::currentDateTime();
        Date lastTDate = m_tPay[m_sel[index]]->getLastTDate();
        quint8 periodType = m_tPay[ m_sel[index] ]->getPeriodType();
        quint16 period = m_tPay[m_sel[index]]->getPeriod();
        if      ( periodType == PayFlags::PeriodType::YEAR  ) lastTDate.reduceYears ( period );
        else if ( periodType == PayFlags::PeriodType::MONTH ) lastTDate.reduceMonths( period );
        else if ( periodType == PayFlags::PeriodType::DAY   ) lastTDate.reduceDays  ( period );
        else if ( periodType == PayFlags::PeriodType::HOUR  ) lastTDate.reduceHour  ( period );
        m_tPay[ m_sel[index] ]->setLastTDate( lastTDate );
        m_tPay.at( m_sel[index] )->setEnabled( value.toBool() );
        this->refreshPays();
    };
}

void TPayList::sortDate()
{
    ulong size{ m_tPay.size() }, step{ size };
    if ( size > 0)
    {
        float loadFactor{ 1.247f };
        bool complite{false};
        while ( !complite )
        {
            complite = true;
            step /= loadFactor;
            if ( step < 1 ) step = 1;
            for (quint32 i = 0; i < size - 1; i++)
            {
                if ( (i + step) < size )
                {
                    if ( m_tPay.at(i)->getDate() < m_tPay.at(i + step)->getDate() )
                    {
                        std::swap( m_tPay[i], m_tPay[i + step] );
                        complite = false;
                    }
                } else {
                    complite = false;
                }
            }
        }
    }
}

void TPayList::clear()
{
    for ( TPay* tPay : m_tPay ){
        delete tPay;
    }
    m_tPay.clear();
}
