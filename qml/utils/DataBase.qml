import QtQuick 2.2
import QtQuick.LocalStorage 2.0 as Sql

Item {
    // reference to the database object
    property var _db;

    property variant record

    property string currency: "eur"
    property string language: "en"
    property bool showHints: true
    property bool convertCurrency: false    
    property bool openInBrowser: false

    Component.onCompleted: {
        initDatabase()

        var currencyIndex = getName("currency")
        if (currencyIndex) {
            currency = currencyIndex.toLowerCase()
        } else {
            storeData("currency", 1, "EUR")
        }
        var languageIndex = getName("language")
        if (languageIndex) {
            language = languageIndex.toLowerCase()
        } else {
            storeData("language", 0, "EN")
        }
        var _showHints = getName("hints")
        if (_showHints) {
            if (_showHints == "false") {
                showHints = false
            }
        } else {
            storeData("hints", "true", "true")
        }
        var convert = getName("convert")
        if (convert) {
            if (convert == "false") {
                convertCurrency = false
            } else {
                convertCurrency = true
            }
        } else {
            database.storeData("convert", "false", "false")
        }
        var browser = getName("browser")
        if (browser) {
            if (browser === "false") {
                openInBrowser = false
            } else {
                openInBrowser = true
            }
        } else {
            database.storeData("browser", "false", "false")
        }
    }

    function initDatabase() {
        // initialize the database object
        console.log('initDatabase()')
        _db = Sql.LocalStorage.openDatabaseSync("AviaTicket", "1.0", "AviaTicket settings SQL database", 1000000)
        _db.transaction( function(tx) {
            // Create the database if it doesn't already exist
            console.log("Create the database if it doesn't already exist")
            tx.executeSql('CREATE TABLE IF NOT EXISTS settings(keyname TEXT UNIQUE, value TEXT, textName TEXT)')
            tx.executeSql('CREATE TABLE IF NOT EXISTS favorites(keyname TEXT UNIQUE, value TEXT)')
//            tx.executeSql('DROP TABLE IF EXISTS favorites')
        })
    }

    function storeData(keyname, value, textName) {
        // stores data to _db
        console.log('storeData()', keyname, value, textName)
        if(!_db) { return; }
        _db.transaction( function(tx) {
            var result = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?,?);', [keyname,value,textName])
            if(result.rowsAffected === 1) {// use update
                console.log('record exists, update it')
            }
        })
    }

    function getValue(keyname) {
        console.log('getValue()', keyname)
        var res
        if(!_db) { return; }
        _db.transaction( function(tx) {
            var result = tx.executeSql('SELECT value from settings WHERE keyname=?', [keyname])
            if(result.rows.length === 1) {// use update
                res = result.rows.item(0).value
            }
        })
        return res
    }

    function getName(keyname) {
        console.log('getName()', keyname)
        var res
        if(!_db) { return; }
        _db.transaction( function(tx) {
            var result = tx.executeSql('SELECT textName from settings WHERE keyname=?', [keyname])
            if(result.rows.length === 1) {// use update
                res = result.rows.item(0).textName
                console.log("tx result", res)
            }
        })
        return res
    }

    function storeFavorite(keyname, value) {
        console.log('storeFavorite()', value)
        if(!_db) { return; }
        _db.transaction( function(tx) {
            var result = tx.executeSql('INSERT OR REPLACE INTO favorites VALUES (?,?);', [keyname,value])
            if(result.rowsAffected === 1) {// use update
                console.log('record exists, update it')
            }
        })
    }

    function getFavorite(keyname) {
        console.log('getFavorite()', keyname)
        var res
        if(!_db) { return; }
        _db.transaction( function(tx) {
            var result = tx.executeSql('SELECT value from favorites WHERE keyname=?', [keyname])
            if(result.rows.length === 1) {// use update
                res = result.rows.item(0).value
            }
        })
        return res
    }

    function getFavorites() {
        console.log('getFavorites()')
        var res = []
        if(!_db) { return; }
        _db.transaction( function(tx) {
            var result = tx.executeSql('SELECT value FROM favorites')
            console.log(result, JSON.stringify(result))
            for(var i = 0; i < result.rows.length; i++) {
//                print(result.rows.item(i).value)
                res.push(result.rows.item(i).value)
            }
        })
        return res
    }

    function deleteFavorite(keyname) {
        console.log('deleteFavorite()')
        var res = ""
        if(!_db) { return; }
        _db.transaction( function(tx) {
            res = tx.executeSql('DELETE FROM favorites WHERE keyname=?', [keyname])
        })
        return res
    }
    function deleteFavorites() {
        console.log('delete favorite table')
        var res = ""
        if(!_db) { return; }
        _db.transaction( function(tx) {
            res = tx.executeSql('DROP TABLE favorites')
            res = tx.executeSql('CREATE TABLE IF NOT EXISTS favorites(keyname TEXT UNIQUE, value TEXT)')
        })
        return res
    }
}
