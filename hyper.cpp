#include "hyper.h"

#include <QMediaPlayer>

hyper::hyper(QObject *parent) :
    QObject(parent),
    m_connections(0),
    m_tc(0),    
    m_clips(0),
    m_clip_len(0),
    m_loop(0)
{
    m_server = new QTcpServer(this);
    if (!m_server->listen(QHostAddress::AnyIPv4, 9993)) {
        qWarning() << "Unable to start the server: " << m_server->errorString();
    } else {
        qDebug() << m_server->serverAddress() << m_server->serverPort();
    }
    connect(m_server, SIGNAL(newConnection()), this, SLOT(newConnection()));
}

void hyper::setStatus(QString status)
{
    m_status=status;
    emit statusChanged();
}

void hyper::setTimecode(int tc)
{
    m_tc=tc;
}

void hyper::setDuration(int du)
{
    m_clip_len=du;
}

void hyper::setClips(int clips)
{
    m_clips=clips;
}

void hyper::writeResponse(QTcpSocket *con, QString key, QString val)
{
    con->write(key.toLocal8Bit());
    con->write(": ");
    con->write(val.toLocal8Bit());
    con->write("\r\n");
}

void hyper::writeResponse(QTcpSocket *con, QString key, bool val)
{
    con->write(key.toLocal8Bit());
    con->write(": ");
    con->write(val ? "true" : "false");
    con->write("\r\n");
}

void hyper::writeResponse(QTcpSocket *con, QString key, int val)
{
    con->write(key.toLocal8Bit());
    con->write(": ");
    con->write(QByteArray::number(val));
    con->write("\r\n");
}

void hyper::onReadyRead()
{
    QTcpSocket *con = qobject_cast<QTcpSocket*>(sender());

    while (con->canReadLine()) {
        QByteArray ba = con->readLine();
        qDebug() << ba;
        if (ba.startsWith("quit")) {
            con->write("200 ok\r\n");
            disconnectRemoteAccess();
            m_server->close();
            return;
        } else if (ba.startsWith("ping")) {
            qDebug() << "ping";

            con->write("200 ok\r\n");
        } else if (ba.startsWith("play")) {
            qDebug() << "play";

            emit play();
            con->write("200 ok\r\n");
        } else if (ba.startsWith("record")) {
            qDebug() << "record";

            emit record();
            con->write("200 ok\r\n");
        } else if (ba.startsWith("stop")) {
            qDebug() << "stop";

            emit stop();
            con->write("200 ok\r\n");
        } else if (ba.startsWith("notify:")) {
            qDebug() << "notify response";

            con->write("209 notify:\r\n");
            con->write("transport: true\r\n");
            con->write("slot: true\r\n");
            con->write("remote: true\r\n");
            con->write("configuration: false\r\n");
            con->write("\r\n");

        } else if (ba.startsWith("transport info")) {
            qDebug() << "transport response";

            QTime tc(0,0,0);
            tc=tc.addSecs(m_tc);
            QString stc=tc.toString("00:hh:mm:ss");

            qDebug() << "tc" << stc << m_status;

            con->write("208 transport info:\r\n");
            writeResponse(con, "status", m_status);
            writeResponse(con, "speed", m_speed);

            con->write("slot id: 1\r\n");
            writeResponse(con, "display timecode: ", stc);
            writeResponse(con, "timecode: ", stc);
            if (m_clips>0)
                writeResponse(con, "clip id", 1);
            else
                writeResponse(con, "clip id", "none");
            con->write("single clip: true\r\n");
            con->write("video format: 1080p30\r\n");
            con->write("loop: false\r\n");
            con->write("\r\n");

        } else if (ba.startsWith("clips count")) {
            qDebug() << "clips count response";
            con->write("214 clips count:\r\n");            
            writeResponse(con, "clip count", m_clips);
            con->write("\r\n");

        } else if (ba.startsWith("clips get")) {
            QTime tc(0,0,0);
            tc=tc.addSecs(m_clip_len);
            QString stc=tc.toString("00:hh:mm:ss");

            qDebug() << "clips get response" << m_clip_len << stc;

            con->write("205 clips info:\r\n");
            writeResponse(con, "clip count", m_clips);
            if (m_clips>0) {                
                con->write("1: media.mov H.264High 1080p30 00:00:00:00 ");
                con->write(stc.toLocal8Bit());
                con->write("\r\n");
            }
            con->write("\r\n");

        } else if (ba.startsWith("disk list")) {
            qDebug() << "disk response";

            QTime tc(0,0,0);
            tc=tc.addSecs(m_clip_len);
            QString stc=tc.toString("00:hh:mm:ss");

            con->write("206 disk list:\r\n");
            con->write("slot id: 1\r\n");
            con->write("1: media.mov H.264High 1080p30 00:00:00:00 ");
            con->write(stc.toLocal8Bit());
            con->write("\r\n");
            con->write("\r\n");

        } else if (ba.startsWith("slot info: slot id: 1")) {
            qDebug() << "slot 1 response";
            con->write("202 slot info:\r\n");
            con->write("slot id: 1\r\n");
            con->write("status: mounted\r\n");
            con->write("volume name: CUTEHYPER\r\n");
            con->write("recording time: 36000\r\n");
            con->write("video format: 1080p30\r\n");
            con->write("\r\n");

        } else if (ba.startsWith("slot info: slot id: 2")) {
            qDebug() << "slot 2 response";
            con->write("202 slot info:\r\n");
            con->write("slot id: 2\r\n");
            con->write("status: empty\r\n");
            con->write("volume name: \r\n");
            con->write("recording time: 0\r\n");
            con->write("video format: 1080p30\r\n");
            con->write("\r\n");

        } else if (ba.startsWith("slot info")) {
            qDebug() << "slot 0 response";
            con->write("202 slot info:\r\n");
            con->write("slot id: 1\r\n");
            con->write("status: mounted\r\n");
            con->write("volume name: CUTEHYPER\r\n");
            con->write("recording time: 36000\r\n");
            con->write("video format: 1080p30\r\n");
            con->write("\r\n");

        } else if (ba.startsWith("goto")) {
            con->write("200 ok\r\n");

        } else if (ba.startsWith("help")) {
            con->write("200 ok\r\n");

        } else if (ba.startsWith("remote")) {
            qDebug() << "remote response";

            con->write("210 remote info:\r\n");
            con->write("enabled: true\r\n");
            con->write("override: false\r\n");
            con->write("\r\n");

        } else if (ba.startsWith("configuration")) {
            con->write("211 configuration:\r\n");
            con->write("audio input: embedded\r\n");
            con->write("video input: HDMI\r\n");
            con->write("\r\n");
        } else {
            con->write("103 unsupported\r\n");
        }
    }
}
void hyper::disconnectRemoteAccess() {
    QTcpSocket *con = qobject_cast<QTcpSocket*>(sender());

    qDebug() << "Remote disconnected" << con->peerAddress();

    con->deleteLater();

    m_connections--;
}

void hyper::newConnection() {
    if (m_connections<10) {
        QTcpSocket *tmp = m_server->nextPendingConnection();

        qDebug() << "Remote connection accepted" << m_connections << tmp->peerAddress();

        tmp->write("500 connection info:\r\n");
        tmp->write("protocol version: 1.11\r\n");
        tmp->write("model: HyperDeck Studio Mini\r\n");
        tmp->write("unique id: 123456789\r\n");
        tmp->write("\r\n");

        connect(tmp, SIGNAL(disconnected()), this, SLOT(disconnectRemoteAccess()));
        connect(tmp, SIGNAL(readyRead()), this, SLOT(onReadyRead()));

        m_connections++;
    } else {
        qDebug("Max remote connections already exists, deny.");
        QTcpSocket *tmp = m_server->nextPendingConnection();
        connect(tmp, SIGNAL(disconnected()), tmp, SLOT(deleteLater()));
        tmp->write("120 connection rejected\n");
        tmp->disconnectFromHost();
    }
}
