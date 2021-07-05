#ifndef HYPER_H
#define HYPER_H

#include <QObject>
#include <QtNetwork>

class hyper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString status MEMBER m_status NOTIFY statusChanged)    

public:
    explicit hyper(QObject *parent = nullptr);

    Q_INVOKABLE void setStatus(QString status);
    Q_INVOKABLE void setTimecode(int tc);

signals:
    void play();
    void stop();
    void record();

    void statusChanged();

protected slots:

private slots:
    void onReadyRead();
    void disconnectRemoteAccess();
    void newConnection();

private:
    QTcpServer *m_server;
    QTcpSocket *m_connection;

    QString m_status;
    int m_tc;
};

#endif // HYPER_H
