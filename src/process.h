#ifndef PROCESS_H
#define PROCESS_H

#include <QProcess>
#include <QVariant>

class Process : public QProcess {
    Q_OBJECT

public:
    Process(QObject *parent = 0) : QProcess(parent) { }

    Q_INVOKABLE void start(const QString &program, const QVariantList &arguments) {
        QStringList args;

        // convert QVariantList from QML to QStringList for QProcess

        for (int i = 0; i < arguments.length(); i++) {
            args << arguments[i].toString();
        }

        QProcess::start(program, args);
    }

    Q_INVOKABLE int getExitCode() {
        return exitCode();
    }

    Q_INVOKABLE QString readAllAsString() {
        // Only works well when $LANG is set to a coherent value, which is NOT the case
        // when the app is launched by Qt Creator
        return readAll();
    }

    Q_INVOKABLE void cancel(bool useKill) {
        if (useKill) kill();
        else terminate();
    }
};

#endif // PROCESS_H
