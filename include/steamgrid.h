#ifndef STEAMGRID_H
#define STEAMGRID_H

#include <QObject>
#include <QVariantList>
#include <QSettings>
#include <QtConcurrent>
#include <QString>
#include <filesystem>

class SteamGrid : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList gamesModel READ gamesModel NOTIFY gamesModelChanged)
    Q_PROPERTY(bool cacheExists READ cacheExists NOTIFY cacheExistsChanged)
    Q_PROPERTY(QString apiKey READ apiKey NOTIFY configChanged)
    Q_PROPERTY(QString path READ path NOTIFY configChanged)
    Q_PROPERTY(QVariantList imagesModel READ imagesModel NOTIFY imagesModelChanged)
    Q_PROPERTY(bool isLoadingImages READ isLoadingImages NOTIFY isLoadingImagesChanged)
    Q_PROPERTY(bool hasMoreImages READ hasMoreImages NOTIFY hasMoreImagesChanged)
    Q_PROPERTY(QString downloadStatus READ downloadStatus NOTIFY downloadStatusChanged)
    Q_PROPERTY(QString currentLanguage READ currentLanguage NOTIFY languageChanged)
    Q_PROPERTY(QString Error READ Error NOTIFY errorSignal)

public:
    explicit SteamGrid(QObject* parent = nullptr);

    Q_INVOKABLE void init();
    Q_INVOKABLE void saveConfiguration(const QString& apiKey, const QString& steamPath);
    Q_INVOKABLE void createCache() { (void)QtConcurrent::run([this]() { buildCache(); }); }
    Q_INVOKABLE void reload() { (void)QtConcurrent::run([this]() { buildCache(); }); }
    Q_INVOKABLE void setLanguage(const QString& langCode);
    Q_INVOKABLE void searchImages(const QString& steamAppId, const QString& type, bool append = false);
    Q_INVOKABLE void loadMoreImages();
    Q_INVOKABLE void downloadAndReplace(const QString& url, const QString& steamAppId, const QString& type);
    void setCurrentLanguage(const QString& lang) { m_currentLanguage = lang; }

    QVariantList gamesModel() const { return m_gamesModel; }
    QVariantList imagesModel() const { return m_imagesModel; }
    bool isLoadingImages() const { return m_isLoadingImages; }
    bool hasMoreImages() const { return m_hasMoreImages; }
    bool cacheExists() const { return std::filesystem::exists(m_cacheFile.toStdString()); }
    QString apiKey() const { return m_apiKey; }
    QString path() const { return m_path; }
    QString downloadStatus() const { return m_downloadStatus; }
    QString currentLanguage() const { return m_currentLanguage; }
    QString Error() const { return m_Error; }

signals:
    void gamesModelChanged();
    void cacheExistsChanged();
    void configChanged();
    void progressChanged(double percent);
    void cacheStarted();
    void imagesModelChanged();
    void isLoadingImagesChanged();
    void hasMoreImagesChanged();
    void downloadStatusChanged();
    void languageChanged(const QString& langCode);
    void errorSignal();

private:
    void writeCache();
    void readCache();
    void buildCache();
    void fetchImagesInternal(bool append);

    QVariantList m_gamesModel;
    QVariantList m_imagesModel;
    bool m_isLoadingImages=false;
    bool m_hasMoreImages=false;
    QString m_downloadStatus;
    QString m_currentLanguage="en";
    QString m_cacheFile="steamgrid.cache";
    QString m_apiKey;
    QString m_path;
    QString m_lastAppId;
    QString m_lastType;
    QString m_Error;
    QString fetchGameName(const std::string& appId);
    static QString fileSuffix(const QString& type);
    int m_page=0;
};

#endif