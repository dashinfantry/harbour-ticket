#pragma once

#include <functional>
#include <QObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QAbstractListModel>
#include <QQmlListProperty>
#include <QQmlProperty>
#include <QBasicTimer>
#include <QTimerEvent>

#include "networkmanger.h"


class AirportInfo: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QJsonObject data READ data NOTIFY dataChanged)

public:
    explicit AirportInfo(const int error);
    explicit AirportInfo(const int error, const QJsonObject value);

    int error() const { return m_error; }
    QJsonObject data() const { return m_obj; }

    void setVal(const QJsonObject &value);

    void setError(int error);

signals:
    void dataChanged();

private:
    int m_error { 0 };
    QJsonObject m_obj;
};

class TicketInfo: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QJsonObject data READ data NOTIFY dataChanged)

public:
    explicit TicketInfo(const QJsonObject value);

    QJsonObject data() const { return m_obj; }

    void setVal(const QJsonObject &value);

signals:
    void dataChanged();

private:
    QJsonObject m_obj;
};

class CurrencyRatesInfo: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QJsonObject data READ data)

public:
    explicit CurrencyRatesInfo(const QJsonObject value);

    QJsonObject data() const { return m_obj; }

    void setVal(const QJsonObject &value);

private:
    QJsonObject m_obj;
};

class Data : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QQmlListProperty<AirportInfo> airportModel READ airportModel NOTIFY airportModelChanged)
    Q_PROPERTY(QQmlListProperty<TicketInfo> ticketsModel READ ticketsModel NOTIFY ticketsModelChanged)
    Q_PROPERTY(QQmlListProperty<CurrencyRatesInfo> currencyRates READ currencyRates NOTIFY currencyRatesChanged)
public:
    explicit Data(QObject *parent = nullptr);


    Q_INVOKABLE int sortByPrice();
    Q_INVOKABLE int sortByDuration();

    //Airports
    Q_INVOKABLE void getAirportsList(const QString &searchText);
    Q_INVOKABLE void clearAirportsList() { m_airports.clear(); }
    Q_INVOKABLE int getAirportsCount() { return m_airports.count(); }

    //Tickets
    Q_INVOKABLE void getTicketsList(const QString &searchData);
    void getTicketsListInfo(const QString &searchId);
    Q_INVOKABLE int getTicketsCount() { return m_tickets.count(); }
    Q_INVOKABLE void clearTicketsList() { m_tickets.clear(); }


    QQmlListProperty<AirportInfo> airportModel() { return QQmlListProperty<AirportInfo>(this, m_airports); }
    QQmlListProperty<TicketInfo> ticketsModel() { return QQmlListProperty<TicketInfo>(this, m_tickets); }
    QQmlListProperty<CurrencyRatesInfo> currencyRates() { return  QQmlListProperty<CurrencyRatesInfo>(this,m_currencyRates); }

signals:
    void airportModelChanged(QList<AirportInfo *> result);
    void ticketsModelChanged(QList<TicketInfo *> result);
    void ticketsModelSorted(QList<TicketInfo *> result);
    void currencyRatesChanged(QList<CurrencyRatesInfo *> result);

    void searchFinished();

protected:
    void timerEvent(QTimerEvent *event) override;

public slots:

protected slots:
    void parseTicketInfo(const QJsonDocument &result);

private:
    NetworkManger manager;
    QList<AirportInfo *> m_airports;
    QList<TicketInfo *> m_tickets;
    QList<CurrencyRatesInfo *> m_currencyRates;
    QBasicTimer m_timer;
    QString m_searchId;
    QString m_arrivalAirport;
    bool m_isDirect;
};

// DATA_H
