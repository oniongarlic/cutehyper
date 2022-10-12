#ifndef HYPER_H
#define HYPER_H

#include <QObject>
#include <QtNetwork>
#include <QMediaPlayer>
#include <QMediaPlaylist>

class CuteHyper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString status MEMBER m_status NOTIFY statusChanged)
    Q_PROPERTY(int speed MEMBER m_speed NOTIFY speedChanged)
    Q_PROPERTY(int loop MEMBER m_loop NOTIFY loopChanged)

public:
    explicit CuteHyper(QObject *parent = nullptr);

    Q_INVOKABLE void setStatus(QString status);
    Q_INVOKABLE void setTimecode(int tc);
    Q_INVOKABLE void setDuration(int du);
    Q_INVOKABLE void setClips(int clips);

    Q_INVOKABLE QMediaPlaylist *getPlaylist(void) { return m_playlist; };

signals:
    void play();
    void stop();
    void record();

    void statusChanged();
    void speedChanged();
    void loopChanged();

protected slots:

private slots:
    void onReadyRead();
    void disconnectRemoteAccess();
    void newConnection();

private:
    QTcpServer *m_server;
    QMediaPlaylist *m_playlist;

    uint m_connections;

    QString m_status;
    int m_tc;
    int m_speed;
    int m_clips;

    int m_clip_len;

    bool m_slot_1;
    bool m_slot_2;

    int m_clip;
    int m_loop;        

    void writeResponse(QTcpSocket *con, QString key, QString val);
    void writeResponse(QTcpSocket *con, QString key, bool val);
    void writeResponse(QTcpSocket *con, QString key, int val);
};

#endif // HYPER_H
