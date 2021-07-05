#ifndef HYPER_H
#define HYPER_H

#include <QObject>
#include <QtNetwork>

class hyper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString status MEMBER m_status NOTIFY statusChanged)
    Q_PROPERTY(int speed MEMBER m_speed NOTIFY speedChanged)

public:
    explicit hyper(QObject *parent = nullptr);

    Q_INVOKABLE void setStatus(QString status);
    Q_INVOKABLE void setTimecode(int tc);
    Q_INVOKABLE void setDuration(int du);

signals:
    void play();
    void stop();
    void record();

    void statusChanged();
    void speedChanged();

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
    int m_speed;
    int m_clips;

    int m_clip_len;

    void writeResponse(QString key, QString val);
    void writeResponse(QString key, bool val);
    void writeResponse(QString key, int val);
};

#endif // HYPER_H
