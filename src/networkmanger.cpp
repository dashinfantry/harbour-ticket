#include "networkmanger.h"
#include <QJsonValue>
#include <QJsonArray>

NetworkManger::NetworkManger(QObject *parent) : QObject(parent)
{
    m_networkManager = new QNetworkAccessManager(this);

    connect(m_networkManager, &QNetworkAccessManager::finished,
            this, &NetworkManger::requestDone);
}

NetworkManger::~NetworkManger()
{
    delete m_networkManager;
}

void NetworkManger::performRequest(RequestType requestType, const QUrl &url, const QByteArray &params)
{
    switch (requestType)
    {
    case RequestType::Get:
    {
        QNetworkRequest request(url);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
//        request.setRawHeader("Accept-Encoding", "gzip, deflate, sdch");
        m_networkManager->get(request);
        break;
    }
    case RequestType::Post:
    {
        qDebug().noquote() << "Post params" << params;
        QNetworkRequest request(url);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
        m_networkManager->post(request, params);
        break;
    }
    }
}

void NetworkManger::sendRequest(RequestType requestType, const QUrl url)
{
    Q_UNUSED(requestType)
    Q_UNUSED(url)
//    switch (requestType)
//    {
//    case RequestType::Get:
//        QNetworkRequest request(url);
//        m_networkManager->get(request);
//        break;
//    case RequestType::Post:
//        QNetworkRequest request(url);
//        m_networkManager->get(request);
////        m_networkManager->post(request);
//        break;
//    default:
//        break;
//    }
}

void NetworkManger::requestDone(QNetworkReply *reply)
{
    QString body(reply->readAll());
    QJsonObject requestResult;

//    qDebug().noquote() << "error code" << reply->error() << reply->errorString() \
//             << "Message" << body;

    requestResult.insert("error", reply->error());

    if (reply->error() == QNetworkReply::NoError)
    {
        QJsonDocument message { QJsonDocument::fromJson(body.toUtf8()) };
        if (message.isArray())
        {
            requestResult.insert("data", message.array());
        }
        else if (message.isObject())
        {
            requestResult.insert("data", message.object());
        }
        QJsonDocument result(requestResult);
        emit sendResponse(result);
    }
    else
    {
        QJsonDocument result(requestResult);
        emit sendResponse(result);
    }
    reply->deleteLater();
}
