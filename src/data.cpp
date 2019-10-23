#include "data.h"
#include <utility>
#include <mutex>
#include <algorithm>

#include <QStringList>
#include <QtAlgorithms>

std::mutex _mutex;

Data::Data(QObject *parent) : QObject(parent)
{
}

int Data::sortByPrice()
{
    if (m_tickets.count() > 0)
    {
        std::sort(m_tickets.begin(), m_tickets.end(), [=](TicketInfo * first, TicketInfo * second) -> bool
        {
            return first->data().value("_value").toInt() < second->data().value("_value").toInt();
        });
        emit ticketsModelSorted(m_tickets);
    }
}

int Data::sortByDuration()
{
    if (m_tickets.count() > 0)
    {
        std::sort(m_tickets.begin(), m_tickets.end(), [=](TicketInfo * first, TicketInfo * second) -> bool
        {
            return first->data().value("duration").toInt() < second->data().value("duration").toInt();
        });
        emit ticketsModelSorted(m_tickets);
    }
}

void Data::timerEvent(QTimerEvent *event)
{
    if (event->timerId() == m_timer.timerId())
    {
        getTicketsListInfo(m_searchId);
    }
}

void Data::getAirportsList(const QString &searchText)
{
    connect(&manager, &NetworkManger::sendResponse, [=](const QJsonDocument &result){
        QJsonObject tmp = result.object();

        m_airports.clear();
        if (tmp.contains("data"))
        {
            QJsonValue value = tmp.value("data");
            if (value.isArray())
            {
                QJsonArray arr = value.toArray();
                for (auto item : arr)
                {
                    QJsonObject object { item.toObject() };
                    m_airports.append(new AirportInfo(0, object));
                }
            }
        }
        else
        {
            m_airports.append(new AirportInfo(1));
        }

        emit airportModelChanged(m_airports);
    });

    QUrl url = "http://nano.aviasales.ru/places_en?term=" + searchText;
    manager.performRequest(RequestType::Get, url);
}

void Data::getTicketsList(const QString &searchData)
{
    connect(&manager, &NetworkManger::sendResponse, [=](const QJsonDocument &result){
        if (result.isObject())
        {
            QJsonObject obj { result.object() };
            QJsonObject object { obj.value("data").toObject() };
            //            qDebug() << "Contains meta" << object.contains("meta") << "contains searchid" << object.contains("search_id");
            //            qDebug().noquote() << "Obj" << object;
            if (object.contains("meta"))
            {
                QJsonValue value = object.value("meta");
                QJsonObject meta = value.toObject();
                m_searchId = meta.value("uuid").toString();
                QJsonObject rates = object.value("currency_rates").toObject();
                m_currencyRates.append(new CurrencyRatesInfo(rates));
//                                qDebug() << "rates" << rates;
                emit currencyRatesChanged(m_currencyRates);
                m_timer.start(5000, this);
            }
        }
    });

    QJsonDocument document = QJsonDocument::fromJson(searchData.toUtf8());
    if (document.isObject())
    {
        QJsonObject obj = document.object();
        if(obj.contains("url") && obj.contains("params") && obj.contains("directFlight"))
        {
            QUrl url = obj.value("url").toString();
            QJsonDocument params(obj.value("params").toObject());

            QJsonObject object = params.object();
            m_arrivalAirport = object.value("segments").toArray().at(0).toObject().value("destination").toString();
            m_isDirect = obj.value("directFlight").toBool();
            //            qDebug().noquote() << "url" << url << "params" << params;
            manager.performRequest(RequestType::Post, url, params.toJson());
        }
    }
}

void Data::getTicketsListInfo(const QString &searchId)
{
    connect(&manager, &NetworkManger::sendResponse, this, &Data::parseTicketInfo, Qt::QueuedConnection);

    QUrl url = "http://api.travelpayouts.com/v1/flight_search_results?uuid=" + searchId;
    manager.performRequest(RequestType::Get, url);
}

void Data::parseTicketInfo(const QJsonDocument &result)
{
    std::lock_guard<std::mutex> lock(_mutex);
    //        qDebug() << "Info getTicketsListInfo" << result;
    QJsonObject mainObj = result.object();

    if (mainObj.contains("data"))
    {
        QJsonValue data = mainObj.value("data");
        if (data.isArray())
        {
            QJsonArray arr = data.toArray();
            for (auto item : arr)
            {
                QJsonObject object { item.toObject() };
                if (object.contains("proposals"))
                {
                    QJsonObject airportsInfo (object.value("airports").toObject());
                    QJsonObject airlinesInfo (object.value("airlines").toObject());
                    QJsonArray proposals (object.value("proposals").toArray());

                    m_timer.stop();
                    if (!proposals.isEmpty() && !airlinesInfo.isEmpty() && !airportsInfo.isEmpty())
                    {
                        for ( auto proposal : proposals )
                        {
                            QJsonObject proposalObject(proposal.toObject());
                            //                                qDebug() << "Proposal" << proposalObject.isEmpty();
                            if (!proposalObject.isEmpty())
                            {
                                QJsonObject result;

                                QStringList airports;

                                if (m_isDirect && !proposalObject.value("is_direct").toBool())
                                {
                                    continue;
                                }

                                QStringList airportsKeys = airportsInfo.keys();
                                QString arrivalAirport = m_arrivalAirport;

                                for (auto key : airportsKeys)
                                {
                                    QJsonObject _airport = airportsInfo.value(key).toObject();
                                    qDebug().noquote() << _airport.value("city_code").toString() << arrivalAirport << key;
                                    if (_airport.value("city_code").toString() ==  arrivalAirport)
                                    {
                                        arrivalAirport = key;
                                        break;
                                    }
                                }

                                QJsonArray segments = proposalObject.value("segment").toArray();
                                QJsonObject first(segments.first().toObject());
                                QString departure_date(first.value("departure_date").toString());
                                QJsonObject gatesInfo (object.value("gates_info").toObject());

                                                                    qDebug() << "gatesInfo" << gatesInfo.keys() << '\n';
                                QString geitId = gatesInfo.keys().at(0);

                                proposalObject.remove("xterms");
                                QJsonObject terms(proposalObject.value("terms").toObject());

                                //                                    qDebug() << "termsInfo" << terms << '\n';

                                QJsonObject term(terms.value(geitId).toObject());
                                QJsonObject timestamp(first.value("flight").toArray().first().toObject());
                                int local_departure_timestamp((timestamp.value("local_departure_timestamp").toInt()));
                                int local_arrival_timestamp { 0 };

                                QString arrival_date;
                                for (auto segment : segments)
                                {
                                    QJsonObject segmentPoint(segment.toObject());
                                    QJsonArray flights(segmentPoint.value("flight").toArray());
                                    for (auto flight : flights)
                                    {
                                        QJsonObject flightPoint(flight.toObject());
                                        QString departure = flightPoint.value("departure").toString();
                                        QString arrival = flightPoint.value("arrival").toString();
                                        QString point = departure + " - " + arrival;
                                        if (arrivalAirport == arrival)
                                        {
                                            arrival_date = flightPoint.value("arrival_date").toString();
                                            local_arrival_timestamp = flightPoint.value("local_arrival_timestamp").toInt();
                                            qDebug() << "local_arrival_timestamp" << local_arrival_timestamp;
                                        }
                                        airports.append(point);
                                    }
                                }
                                QString validating_carrier = proposalObject.value("validating_carrier").toString();
                                int total_duration = proposalObject.value("total_duration").toInt();
                                int max_stops = proposalObject.value("max_stops").toInt();
                                QString _search_id = object.value("search_id").toString();
                                result.insert("route", airports.join(" | "));
                                result.insert("depart_date", departure_date);
                                result.insert("arrival_date", arrival_date);
                                result.insert("carrier", validating_carrier);
                                result.insert("duration", total_duration);
                                result.insert("transfers", max_stops);
                                result.insert("fullInfo", proposalObject);
                                result.insert("_search_id", _search_id);
                                result.insert("airportsInfo", airportsInfo);
                                result.insert("airlinesInfo", airlinesInfo);
                                result.insert("_currency", term.value("currency").toString());
                                result.insert("_value", term.value("unified_price").toInt());
                                result.insert("price", term.value("price").toInt());
                                result.insert("local_departure_timestamp", local_departure_timestamp);
                                result.insert("local_arrival_timestamp", local_arrival_timestamp);

                                //                                    qDebug().noquote() << "fullInfo" << proposalObject;

                                m_tickets.append(new TicketInfo(result));
                            }
                        }
                        emit ticketsModelChanged(m_tickets);
                    }
                    m_timer.start(5000, this);
                }
                else
                {
                    //                        qDebug().noquote() << "m_timer.stop";
                    m_timer.stop();
                    emit searchFinished();
                }
            }
        }
    }
}

AirportInfo::AirportInfo(const int error): m_error(error)
{
}

AirportInfo::AirportInfo(const int error, const QJsonObject value)
    : m_error(error), m_obj(value)
{
}

void AirportInfo::setVal(const QJsonObject &value)
{
    m_obj = value;
}

void AirportInfo::setError(int error)
{
    m_error = error;
}


TicketInfo::TicketInfo(const QJsonObject value):
    m_obj(value)
{

}

void TicketInfo::setVal(const QJsonObject &value)
{
    m_obj = value;
}

CurrencyRatesInfo::CurrencyRatesInfo(const QJsonObject value) : m_obj(value)
{

}

void CurrencyRatesInfo::setVal(const QJsonObject &value)
{
    m_obj = value;
}
