#ifndef PAYLIST_H
#define PAYLIST_H

#include <QAbstractListModel>
#include <vector>
#include <QString>
#include <fstream>

#include <functional>

#include "pay.h"
#include "C++/Tools/date.h"
#include "C++/Tools/Strings.h"
#include "Category/categorymodel.h"

class PayList : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit PayList( CategoryModel* catModel, Strings* curModel, QObject *parent = nullptr );
    ~PayList();


    Q_INVOKABLE void createPay(bool isPositive,
                               QString sumInteger,
                               QString sumFraction,

                               quint16 year,
                               quint8 month,
                               quint8 day,
                               quint8 hour,
                               quint8 minute,

                               quint8 currency = Pay::EMPTY,
                               quint8 category = Pay::EMPTY,

                               QString description = QString()

                                                     );
    void appendPay(Pay* newPay );

    void addPayUnsave(Pay* newPay);

    Q_INVOKABLE void erasePay( quint32 index );

    void refreshSelection();
    void sortDate();
    void sortDate( quint32 beforeIndex );
    void sortDate( Date startDate );
    void sortAfterT( Date startDate, quint32 newPayCount );

    Q_INVOKABLE bool isCategorySelected( quint8 categoryNo ) const;
    Q_INVOKABLE bool isCurrencySelected( quint8 currencyNo ) const;
    Q_INVOKABLE bool isOneCurrencySelected() const;
    Q_INVOKABLE bool isCategorySelected() const;
    Q_INVOKABLE bool isCurrencySelected() const;

    Q_INVOKABLE void selectionReset();

    Q_INVOKABLE void selectSumSign       ( bool isPositive );
    Q_INVOKABLE void selectSumSignRemove ( bool isPositive );
    Q_INVOKABLE void selectionCategoryAdd   ( quint8 categoryNo );
    Q_INVOKABLE void selectionCategoryRemove( quint8 categoryNo );
    Q_INVOKABLE void selectionCategoryReset ();
    Q_INVOKABLE void selectionCurrencyAdd   ( quint8 currencyNo );
    Q_INVOKABLE void selectionCurrencyRemove( quint8 currencyNo );
    Q_INVOKABLE void selectionCurrencyReset ();

    Q_INVOKABLE void selectDateRange     ( quint16 yearBegin, quint8  monthBegin,
                                           quint8  dayBegin,  quint16 yearEnd,
                                           quint8  monthEnd,  quint8  dayEnd );
    Q_INVOKABLE void selectYear          ( quint16 year );
    Q_INVOKABLE void selectMonth         ( quint16 year, quint8 month );
    Q_INVOKABLE void selectDay           ( quint16 year, quint8 month, quint8 day );
    Q_INVOKABLE void selectionDateReset();

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(
            const QModelIndex &index,
            int role = Qt::DisplayRole
                       ) const override;

    bool setData( const QModelIndex &index, const QVariant &value, int role ) override;

    QHash<int, QByteArray> roleNames() const override;

    enum PaymentRoles{
        IsIncomeRole = Qt::UserRole +1, SumIntegerRole, SumFractionRole,
        CategoryRole, CategoryColorRole, CurrencyRole,
        DescriptionRole,
        YearRole, MonthRole, DayRole, HourRole, MinuteRole,
        FromTPayRole,
        LastRole
    };

    size_t size() const;
    const Pay* operator []( size_t i ) const;

public slots:
    void categoryRemoved( quint8 categoryNo );
    void categoryChanged( quint8 categoryNo );

    void currencyRemoved( quint8 currencyNo );
    void currencyRenamed( quint8 currencyNo );

    void tRemoved( quint16 tNo );

signals:

    void payAdded(const Pay*);
    void payRemoved(const Pay*);

private:
    void prepareGetters();
    void prepareSetters();

    inline bool checkSelection( Pay* target);

    void readFile();
    void saveFile();

    void clear();

    std::vector< Pay*> m_pay;
    std::vector< ulong > m_sel;

    std::function< QVariant( ulong ) >* getData;
    std::function< void ( ulong, QVariant ) >* setPayData;

    CategoryModel* p_categoryModel;
    Strings* p_currencyModel;

    bool m_isSignNegativeSelected:1;
    bool m_isSignPositiveSelected:1;
    bool m_isYearSelected:1;
    bool m_isMonthSelected:1;
    bool m_isDaySelected:1;
    bool m_isDateRangeSelected:1;

    quint8 m_categorySelectedCount;
    quint8 m_currencySelectedCount;
    std::vector< bool > m_categorySelected;
    QVector< bool > m_currencySelected;

    Date m_dateSelectionBegin;
    Date m_dateSelectionEnd;

    QString m_fileName;

    enum PayFile: char {  ByteCount = 16, DescriptionEnd = '\0' };
};

#endif // PAYLIST_H
