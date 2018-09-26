# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-ticket

CONFIG += sailfishapp

SOURCES += src/harbour-ticket.cpp

OTHER_FILES += qml/harbour-ticket.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-ticket.changes.in \
    rpm/harbour-ticket.spec \
    rpm/harbour-ticket.yaml \
    translations/*.ts \
    harbour-ticket.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-ticket-ru.ts
TRANSLATIONS += translations/harbour-ticket-sv.ts
TRANSLATIONS += translations/harbour-ticket-pl.ts
TRANSLATIONS += translations/harbour-ticket-el.ts

DISTFILES += \
    qml/pages/*.qml \
    qml/delegates/*.qml \
    qml/utils/*
