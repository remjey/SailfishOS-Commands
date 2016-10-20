pragma Singleton

import QtQuick 2.0
import QtQuick.LocalStorage 2.0 as Sql

QtObject {

    signal commandsChanged()

    function listCommands() {
        return _data.commands;
    }

    function getCommand(id) {
        return _data.commands[_arrayFind(_data.commands, _propChecker("id", id))];
    }

    function saveCommand(command) {
        if (command.id === undefined) {
            command.id = ++_data.idGenerator;
            _data.commands.push(command);
        } else {
            _data.commands[_arrayFind(_data.commands, _propChecker("id", command.id))] = command;
        }
        commandsChanged();
        save();
    }

    function moveCommand(index, dir) {
        if (index >= -dir && index < _data.commands.length - dir) {
            var c = _data.commands[index];
            _data.commands.splice(index, 1);
            _data.commands.splice(index + dir, 0, c);
        }
        commandsChanged();
        save();
    }

    function deleteCommand(id) {
        _data.commands.splice(_arrayFind(_data.commands, _propChecker("id", id)), 1);
        commandsChanged();
        save();
    }

    property var _db
    property var _data: ({
                             idGenerator: 0,
                             commands: [],
                         })

    function save() {
        _db.transaction(function (tx) {
            tx.executeSql("update data set v = ?", [ JSON.stringify(_data) ]);
        });
    }

    Component.onCompleted: {
        _db = Sql.LocalStorage.openDatabaseSync("commands", "", "commands", 1000000);
        if (_db.version === "") {
            _db.changeVersion(_db.version, "0.0.1", function (tx) {
                tx.executeSql("create table data (v blob not null)");
                tx.executeSql("insert into data values (?)", JSON.stringify(_data));
            })
        }
        _db.readTransaction(function (tx) {
            _data = JSON.parse(tx.executeSql("select v from data").rows[0].v);
        })
    }

    function _arrayFind(a, p) {
        for (var i = 0; i < a.length; i++)
            if (p(a[i], i)) return i;
        return -1;
    }

    function _propChecker(p, v) {
        return function (item) {
            return item[p] === v;
        }
    }
}
