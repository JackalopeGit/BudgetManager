#ifndef TPAYLIST_H
#define TPAYLIST_H

#include <QAbstractListModel>
#include <QDateTime>
#include <QTimer>

#include <functional>

#include "tpay.h"
#include "C++/Tools/Strings.h"
#include "C++/Tools/Settings.h"
#include "Category/categorymodel.h"
#include "paylist.h"

class TPayList : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit TPayList(

            PayList *payList,
            CategoryModel* category,
            Strings* currency,
            Settings* settings,
            QObject *parent = nullptr

                              );

    ~TPayList();


    Q_INVOKABLE void createTPay(

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
            QString description = QString()

                                  );

    Q_INVOKABLE void eraseTPay( quint32 position );

signals:
    void tRemoved( quint16 tNo );
private:
    void startTimer();
private slots:

    void refreshPays();
signals:
    void payModelResetStart();
    void payModelResetEnd();

private:
    void refreshSelection();
    inline bool checkSelection( TPay* target);
public:
    Q_INVOKABLE void selectionReset();

    Q_INVOKABLE void selectSumSign      ( bool isPositive );
    Q_INVOKABLE void selectSumSignReset ();

    Q_INVOKABLE void selectionCategoryAdd   ( quint8 categoryNo );
    Q_INVOKABLE void selectionCategoryRemove( quint8 categoryNo );
    Q_INVOKABLE void selectionCategoryReset ();
    Q_INVOKABLE bool isCategorySelected() const;
    Q_INVOKABLE bool isCategorySelected( quint8 categoryNo ) const;

    Q_INVOKABLE void selectionCurrencyAdd   ( quint8 currencyNo );
    Q_INVOKABLE void selectionCurrencyRemove( quint8 currencyNo );
    Q_INVOKABLE void selectionCurrencyReset ();
    Q_INVOKABLE bool isCurrencySelected() const;
    Q_INVOKABLE bool isOneCurrencySelected() const;
    Q_INVOKABLE bool isCurrencySelected( quint8 currencyNo ) const;

private:
    void prepareGetters();
    void prepareSetters();

public:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data( const QModelIndex &index, int role = Qt::DisplayRole ) const override;

    bool setData( const QModelIndex &index, const QVariant &value, int role ) override;

    QHash<int, QByteArray> roleNames() const override;

    enum PaymentRoles{
        IsIncomeRole = Qt::UserRole +1, SumIntegerRole, SumFractionRole,
        CategoryRole,    CategoryColorRole,  CurrencyRole,
        DescriptionRole,
        YearFromRole,    MonthFromRole,   DayFromRole,
        HourFromRole,    MinuteFromRole,
        PeriodTypeRole,  PeriodRole,
        MaxRepeatRole,   NRepeatRole,
        EnabledRole,     SelectedRole,
        LastRole
    };

    ////////////////////////////////////////////////////////////////////////////////

public slots:
    void categoryRemoved( quint8 categoryNo );
    void categoryChanged( quint8 categoryNo );
    void currencyRemoved( quint8 currencyNo );
    void currencyRenamed( quint8 currencyNo );

private:
    void readFile();
    bool saveFile();
    void sortDate();

    void clear();

    PayList* p_payList;
    CategoryModel *p_category;
    Strings* p_currency;

    std::vector<TPay*> m_tPay;
    std::vector<ulong> m_sel;


    std::function< QVariant( ulong ) >* getData;
    std::function< void ( ulong, QVariant ) >* setTPayData;

    bool m_isSignNegativeSelected, m_isSignPositiveSelected;

    quint8 m_categorySelectedCount;
    std::vector< bool > m_categorySelected;

    quint8 m_currencySelectedCount;
    QVector< bool > m_currencySelected;

    QString m_fileName;

    QTimer* p_timer;

    Settings* p_settings;

    enum PayFile: char {  ByteCount = 26, DescriptionEnd = '\0' };
};

#endif
