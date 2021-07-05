#ifndef HYPER_H
#define HYPER_H

#include <QObject>
#include <QtNetwork>

class hyper : public QObject
{
    Q_OBJECT
public:
    explicit hyper(QObject *parent = nullptr);

signals:
    void play();
    void stop();

protected slots:

private slots:
    void onReadyRead();
    void disconnectRemoteAccess();
    void newConnection();

private:
    QTcpServer *m_server;
    QTcpSocket *m_connection;
};

#endif // HYPER_H
