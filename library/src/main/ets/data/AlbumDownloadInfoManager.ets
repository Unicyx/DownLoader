import { BBTsHelper } from '@babyohs/modulebase'
import HashMap from '@ohos.util.HashMap'
import { AlbumDownloadInfo } from './AlbumDownloadInfo'
import { AlbumDownloadParam } from './AlbumDownloadParam'
import { AlbumDownloadInfoSp } from './table/AlbumDownloadInfoSp'
import { AlbumDownloadFilePathSp } from './table/AlbumDownloadFilePathSp'
import { Constants } from '../const/Constants'

export class AlbumDownloadInfoManager {
  static INSTANCE: AlbumDownloadInfoManager
  // HashMap: id --> Info
  downloadInfoMap: HashMap<string, AlbumDownloadInfo> = new HashMap()

  static getInstance(): AlbumDownloadInfoManager {
    if (!AlbumDownloadInfoManager.INSTANCE) {
      AlbumDownloadInfoManager.INSTANCE = new AlbumDownloadInfoManager()
    }
    return AlbumDownloadInfoManager.INSTANCE
  }

  removeAlbumDownloadInfo(downloadInfo: AlbumDownloadInfo) {
    this.downloadInfoMap.remove(downloadInfo.getId())
    AlbumDownloadInfoSp.getInstance().remove(downloadInfo.getId())
  }

  getAlbumDownloadInfoByFilePath(path: string): AlbumDownloadInfo | undefined {
    let id = AlbumDownloadFilePathSp.getInstance().getString(path, undefined);
    AlbumDownloadInfoSp.getInstance().getAllKeys()
    if (id) {
      return this.getAlbumDownloadInfo(id);
    }
    return undefined
  }

  getAlbumDownloadInfo(id: string): AlbumDownloadInfo | undefined {
    let downloadInfo: AlbumDownloadInfo | undefined = this.downloadInfoMap.get(id)
    if (!downloadInfo) {
      downloadInfo = this.getCacheAlbumDownloadInfo(id)
      if (downloadInfo) {
        this.downloadInfoMap.set(id, downloadInfo)
      } else {
        return
      }
    }
    return downloadInfo
  }

  private getCacheAlbumDownloadInfo(id: string): AlbumDownloadInfo | undefined {
    if (!AlbumDownloadInfoSp.getInstance().containsKey(id)) {
      return
    }
    let cacheStr = AlbumDownloadInfoSp.getInstance().getString(id, "")
    if (!cacheStr || cacheStr.trim() !== "") {
      return
    }
    try {
      return BBTsHelper.parseWithMethods(cacheStr, AlbumDownloadInfo)
    } catch (e) {
    }
    return
  }

  createAlbumDownloadInfo(param: AlbumDownloadParam): AlbumDownloadInfo {
    let downloadInfo = this.getAlbumDownloadInfo(param.id)
    if (!downloadInfo) {
      downloadInfo = new AlbumDownloadInfo(param)
      downloadInfo.setDownloadPath(Constants.getCachePath(param.id))
    } else {
      downloadInfo.resetAlbumDownloadParam(param)
    }
    AlbumDownloadFilePathSp.getInstance().set(downloadInfo.getFilePath(), downloadInfo.getId())
    this.downloadInfoMap.set(param.id, downloadInfo)
    return downloadInfo
  }

  updateAlbumDownloadInfo(downloadInfo: AlbumDownloadInfo) {
    if (downloadInfo) {
      AlbumDownloadInfoSp.getInstance().set(downloadInfo.getId(), JSON.stringify(downloadInfo))
    }
  }

  clearAlbumDownloadInfo(downloadInfo: AlbumDownloadInfo) {
    this.downloadInfoMap.remove(downloadInfo.getId())
  }
}