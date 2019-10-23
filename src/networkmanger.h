#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QByteArray>


enum class RequestType
{
    Get,
    Post
};

class NetworkManger : public QObject
{
    Q_OBJECT
public:
    explicit NetworkManger(QObject *parent = nullptr);
    virtual ~NetworkManger();

    void performRequest(RequestType requestType, const QUrl &url, const QByteArray &params = nullptr);
private:
    void sendRequest(RequestType requestType, const QUrl url);

signals:
    void sendResponse(const QJsonDocument result);

private slots:
    void requestDone(QNetworkReply* reply);

private:
    QNetworkAccessManager *m_networkManager;
};


// NETWORKMANGER_H
