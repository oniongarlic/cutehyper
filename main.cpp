#include <QtQuick>
#include <QtQml>

#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "hyper.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QCoreApplication::setOrganizationDomain("org.tal.cutehyper");
    QCoreApplication::setOrganizationName("tal.org");
    QCoreApplication::setApplicationName("CuteHyper");
    QCoreApplication::setApplicationVersion("0.1");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    qmlRegisterType<hyper>("org.tal.hyperhyper", 1, 0, "HyperServer");

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
