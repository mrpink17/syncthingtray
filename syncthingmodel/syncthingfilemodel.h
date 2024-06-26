#ifndef DATA_SYNCTHINGFILEMODEL_H
#define DATA_SYNCTHINGFILEMODEL_H

#include "./syncthingmodel.h"

#include <vector>

namespace Data {

struct SyncthingItem;

class LIB_SYNCTHING_MODEL_EXPORT SyncthingFileModel : public SyncthingModel {
    Q_OBJECT
public:
    enum SyncthingFileModelRole { NameRole = SyncthingModelUserRole + 1, SizeRole, ModificationTimeRole, Actions, ActionNames, ActionIcons };

    explicit SyncthingFileModel(SyncthingConnection &connection, const QString &dirId, QObject *parent = nullptr);
    ~SyncthingFileModel() override;

public Q_SLOTS:
    QHash<int, QByteArray> roleNames() const override;
    QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &child) const override;
    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    int rowCount(const QModelIndex &parent) const override;
    int columnCount(const QModelIndex &parent) const override;
    bool canFetchMore(const QModelIndex &parent) const override;
    void fetchMore(const QModelIndex &parent) override;
    void triggerAction(const QString &action, const QModelIndex &index);

public:
    QString path(const QModelIndex &path) const;

private Q_SLOTS:
    void handleConfigInvalidated() override;
    void handleNewConfigAvailable() override;
    void handleForkAwesomeIconsChanged() override;

private:
    void processFetchQueue();

private:
    SyncthingConnection &m_connection;
    QString m_dirId;
    QModelIndexList m_fetchQueue;
    QMetaObject::Connection m_pendingRequest;
    mutable std::vector<SyncthingItem> m_items;
};

} // namespace Data

#endif // DATA_SYNCTHINGFILEMODEL_H
