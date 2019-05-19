#ifndef DATA_SYNCTHINGICONS_H
#define DATA_SYNCTHINGICONS_H

#include "./global.h"

#include <QIcon>
#include <QSize>

#include <vector>

QT_FORWARD_DECLARE_CLASS(QColor)

namespace Data {

enum class StatusEmblem {
    None,
    Scanning,
    Synchronizing,
    Alert,
    Paused,
    Complete,
    Add,
};

struct GradientColor {
    GradientColor(const QColor &start, const QColor &end);
    GradientColor(QColor &&start, QColor &&end);
    GradientColor(const QString &start, const QString &end);

    QColor start;
    QColor end;
};

inline GradientColor::GradientColor(const QColor &start, const QColor &end)
    : start(start)
    , end(end)
{
}

inline GradientColor::GradientColor(QColor &&start, QColor &&end)
    : start(start)
    , end(end)
{
}

inline GradientColor::GradientColor(const QString &start, const QString &end)
    : start(start)
    , end(end)
{
}

QByteArray LIB_SYNCTHING_MODEL_EXPORT makeSyncthingIcon(
    const GradientColor &gradientColor = GradientColor{ QStringLiteral("#26B6DB"), QStringLiteral("#0882C8") },
    StatusEmblem statusEmblem = StatusEmblem::None);
QPixmap LIB_SYNCTHING_MODEL_EXPORT renderSvgImage(const QString &path, const QSize &size = QSize(128, 128), int margin = 0);
QPixmap LIB_SYNCTHING_MODEL_EXPORT renderSvgImage(const QByteArray &contents, const QSize &size = QSize(128, 128), int margin = 0);
QByteArray LIB_SYNCTHING_MODEL_EXPORT loadFontAwesomeIcon(const QString &iconName, const QColor &color, bool solid = true);

struct LIB_SYNCTHING_MODEL_EXPORT StatusIconSettings {
    explicit StatusIconSettings();
    explicit StatusIconSettings(const QString &str);

    GradientColor defaultColor;
    GradientColor errorColor;
    GradientColor warningColor;
    GradientColor idleColor;
    GradientColor scanningColor;
    GradientColor synchronizingColor;
    GradientColor pausedColor;
    GradientColor disconnectedColor;

    static constexpr auto distinguishableColorCount = 8;

    struct ColorMapping {
        QString colorName;
        StatusEmblem defaultEmblem;
        GradientColor &setting;
    };
    std::vector<ColorMapping> colorMapping();
    QString toString() const;
};

struct StatusIcons {
    StatusIcons();
    StatusIcons(const StatusIconSettings &settings);
    QIcon disconnected;
    QIcon idling;
    QIcon scanninig;
    QIcon notify;
    QIcon pause;
    QIcon sync;
    QIcon syncComplete;
    QIcon error;
    QIcon errorSync;
    QIcon newItem;
};

inline StatusIcons::StatusIcons()
{
}

struct FontAwesomeIcons {
    FontAwesomeIcons(const QColor &color, const QSize &size, int margin);
    QIcon hashtag;
    QIcon folderOpen;
    QIcon globe;
    QIcon home;
    QIcon shareAlt;
    QIcon refresh;
    QIcon clock;
    QIcon exchangeAlt;
    QIcon exclamationTriangle;
    QIcon cogs;
    QIcon link;
    QIcon eye;
    QIcon fileArchive;
    QIcon folder;
    QIcon certificate;
    QIcon networkWired;
    QIcon cloudDownloadAlt;
    QIcon cloudUploadAlt;
    QIcon tag;
};

class LIB_SYNCTHING_MODEL_EXPORT IconManager : public QObject {
    Q_OBJECT
public:
    static IconManager &instance();

    void applySettings(const StatusIconSettings &settings);
    const StatusIcons &statusIcons() const;
    const FontAwesomeIcons &fontAwesomeIconsForLightTheme() const;
    const FontAwesomeIcons &fontAwesomeIconsForDarkTheme() const;

Q_SIGNALS:
    void statusIconsChanged();

private:
    IconManager();

    StatusIcons m_statusIcons;
    FontAwesomeIcons m_fontAwesomeIconsForLightTheme;
    FontAwesomeIcons m_fontAwesomeIconsForDarkTheme;
};

inline void IconManager::applySettings(const StatusIconSettings &settings)
{
    m_statusIcons = StatusIcons(settings);
    emit statusIconsChanged();
}

inline const StatusIcons &IconManager::statusIcons() const
{
    return m_statusIcons;
}

inline const FontAwesomeIcons &IconManager::fontAwesomeIconsForLightTheme() const
{
    return m_fontAwesomeIconsForLightTheme;
}

inline const FontAwesomeIcons &IconManager::fontAwesomeIconsForDarkTheme() const
{
    return m_fontAwesomeIconsForDarkTheme;
}

inline const StatusIcons &statusIcons()
{
    return IconManager::instance().statusIcons();
}

inline const FontAwesomeIcons &fontAwesomeIconsForLightTheme()
{
    return IconManager::instance().fontAwesomeIconsForLightTheme();
}

inline const FontAwesomeIcons &fontAwesomeIconsForDarkTheme()
{
    return IconManager::instance().fontAwesomeIconsForDarkTheme();
}

} // namespace Data

#endif // DATA_SYNCTHINGICONS_H
