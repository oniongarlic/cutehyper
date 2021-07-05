#include "hyper.h"

hyper::hyper(QObject *parent) :
    QObject(parent),
    m_connection(NULL)
{
    m_server = new QTcpServer(this);
    if (!m_server->listen(QHostAddress::AnyIPv4, 9993)) {
        qWarning() << "Unable to start the server: " << m_server->errorString();
    }
    connect(m_server, SIGNAL(newConnection()), this, SLOT(newConnection()));
}

void hyper::onReadyRead() {
    while (m_connection->canReadLine()) {
        QByteArray ba = m_connection->readLine();
        qDebug() << ba;
        if (ba.startsWith("quit")) {
            m_connection->write("200 ok\r\n");
            disconnectRemoteAccess();
            m_server->close();
            return;
        } else if (ba.startsWith("ping")) {
            qDebug() << "ping";

             m_connection->write("200 ok\r\n");
        } else if (ba.startsWith("play")) {
            qDebug() << "play";

            emit play();
            m_connection->write("200 ok\r\n");
        } else if (ba.startsWith("stop")) {
            qDebug() << "stop";

            emit stop();
            m_connection->write("200 ok\r\n");
        } else if (ba.startsWith("notify:")) {
            qDebug() << "notify response";

            m_connection->write("209 notify:\r\n");
            m_connection->write("transport: true\r\n");
            m_connection->write("slot: true\r\n");
            m_connection->write("remote: true\r\n");
            m_connection->write("configuration: false\r\n");
            m_connection->write("\r\n");

        } else if (ba.startsWith("transport info")) {
            qDebug() << "transport response";
            m_connection->write("208 transport info:\r\n");
            m_connection->write("status: stopped\r\n");
            m_connection->write("speed: 0\r\n");
            m_connection->write("slot id: 1\r\n");
            m_connection->write("display timecode: 01:00:00:00\r\n");
            m_connection->write("timecode: 00:00:00:00\r\n");
            m_connection->write("clip id: 1\r\n");
            m_connection->write("single clip: true\r\n");
            m_connection->write("video format: 1080p30\r\n");
            m_connection->write("loop: false\r\n");
            m_connection->write("\r\n");

        } else if (ba.startsWith("clips count")) {
            qDebug() << "clips response";
            m_connection->write("214 clips count:\r\n");
            m_connection->write("clip count: 1\r\n");
            m_connection->write("\r\n");

        } else if (ba.startsWith("disk list")) {
            qDebug() << "disk response";
            m_connection->write("206 disk list:\r\n");
            m_connection->write("slot id: 1\r\n");
//            m_connection->write("slot id: 1\r\n");
            m_connection->write("\r\n");

        } else if (ba.startsWith("slot info: slot id: 1")) {
            qDebug() << "slot 1 response";
            m_connection->write("202 slot info:\r\n");
            m_connection->write("slot id: 1\r\n");
            m_connection->write("status: mounted\r\n");
            m_connection->write("volume name: CUTEHYPER\r\n");
            m_connection->write("recording time: 36000\r\n");
            m_connection->write("video format: 1080p30\r\n");
            m_connection->write("\r\n");

        } else if (ba.startsWith("slot info: slot id: 2")) {
            qDebug() << "slot 2 response";
            m_connection->write("202 slot info:\r\n");
            m_connection->write("slot id: 2\r\n");
            m_connection->write("status: empty\r\n");
            m_connection->write("volume name: \r\n");
            m_connection->write("recording time: 0\r\n");
            m_connection->write("video format: 1080p30\r\n");
            m_connection->write("\r\n");

        } else if (ba.startsWith("slot info")) {
            qDebug() << "slot 0 response";
            m_connection->write("202 slot info:\r\n");
            m_connection->write("slot id: 1\r\n");
            m_connection->write("status: mounted\r\n");
            m_connection->write("volume name: CUTEHYPER\r\n");
            m_connection->write("recording time: 36000\r\n");
            m_connection->write("video format: 1080p30\r\n");
            m_connection->write("\r\n");

        } else if (ba.startsWith("help")) {
            m_connection->write("200 ok\r\n");

        } else if (ba.startsWith("remote")) {
            qDebug() << "remote response";

            m_connection->write("210 remote info:\r\n");
            m_connection->write("enabled: true\r\n");
            m_connection->write("override: false\r\n");
            m_connection->write("\r\n");

        } else if (ba.startsWith("configuration")) {
            m_connection->write("211 configuration:\r\n");
            m_connection->write("audio input: embedded\r\n");
            m_connection->write("video input: HDMI\r\n");
            m_connection->write("\r\n");
        } else {
            m_connection->write("103 unsupported\r\n");
        }
    }
}
void hyper::disconnectRemoteAccess() {
    qDebug("Remote disconnected");
    m_connection->deleteLater();
    m_connection=NULL;
}

void hyper::newConnection() {
    if (m_connection==NULL) {
        qDebug("Remote connection accepted");
        m_connection = m_server->nextPendingConnection();
        m_connection->write("500 connection info:\r\n");
        m_connection->write("protocol version: 1.9\r\n");
        m_connection->write("model: HyperDeck Studio Mini\r\n");
        m_connection->write("\r\n");
        connect(m_connection, SIGNAL(disconnected()), this, SLOT(disconnectRemoteAccess()));
        connect(m_connection, SIGNAL(readyRead()), this, SLOT(onReadyRead()));
    } else {
        qDebug("Remote connection already exists, disconnect directly");
        QTcpSocket *tmp = m_server->nextPendingConnection();
        connect(tmp, SIGNAL(disconnected()), tmp, SLOT(deleteLater()));
        tmp->write("120 connection rejected\n");
        tmp->disconnectFromHost();
    }
}