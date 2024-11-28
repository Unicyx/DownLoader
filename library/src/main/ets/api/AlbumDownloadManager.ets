import { AlbumDownloadManagerImpl } from '../core/AlbumDownloadManagerImpl'
import { AlbumDownloadInfo } from '../data/AlbumDownloadInfo'
import { AlbumDownloadInfoManager } from '../data/AlbumDownloadInfoManager'
import { Album, AlbumDownloadParam } from '../data/AlbumDownloadParam'
import { Utils } from '@babyohs/download/src/main/ets/utils/Utils'
import { AlbumDownloadBuilder } from './AlbumDownloadBuilder'
import { IAlbumDownloadListener } from './IAlbumDownloadListener'

export namespace AlbumDownloadManager {
  /**
   * 判断是否需已下载
   * @param url 完整Url
   * @returns
   */
  export function isDownloaded(id: string): boolean {
    let downloadInfo: AlbumDownloadInfo = AlbumDownloadInfoManager.getInstance().getAlbumDownloadInfo(id)!
    if (downloadInfo && downloadInfo.isDownloadCompleted()) {
      if (!Utils.isFileExist(downloadInfo.getFilePath())) {
        AlbumDownloadInfoManager.getInstance().removeAlbumDownloadInfo(downloadInfo)
        return false
      }
      return true
    }
    return false
  }

  export function isDownloading(id: string): boolean {
    return AlbumDownloadManagerImpl.getInstance().isDownloading(id)
  }

  export function getAlbumDownloadInfo(id: string): AlbumDownloadInfo | null | undefined {
    let downloadInfo: AlbumDownloadInfo = AlbumDownloadInfoManager.getInstance().getAlbumDownloadInfo(id)!
    if (downloadInfo && downloadInfo.isDownloadCompleted()) {
      if (!Utils.isFileExist(downloadInfo.getFilePath())) {
        AlbumDownloadInfoManager.getInstance().removeAlbumDownloadInfo(downloadInfo)
        return null
      }
    }
    return downloadInfo
  }

  export function getDownloadInfoByFilePath(filePath: string): AlbumDownloadInfo | null | undefined {
    let downloadInfo: AlbumDownloadInfo =
      AlbumDownloadInfoManager.getInstance().getAlbumDownloadInfoByFilePath(filePath)!
    if (downloadInfo && downloadInfo.isDownloadCompleted()) {
      if (!Utils.isFileExist(downloadInfo.getFilePath())) {
        AlbumDownloadInfoManager.getInstance().removeAlbumDownloadInfo(downloadInfo)
        return null
      }
    }
    return downloadInfo
  }

  /**
   *
   * @param url
   * @returns
   */
  export function download(downloadType: string = DLType.DEFAULT): AlbumDownloadBuilder {
    return new AlbumDownloadBuilder(downloadType)
  }

  /**
   * 直接开始下载
   * @param album
   * @param filePath
   * @param priority
   * @param listener
   */
  export function startDownload(album: Album, filePath: string, priority: number,
    listener: IAlbumDownloadListener): void {
    AlbumDownloadManagerImpl.getInstance()
      .download(new AlbumDownloadParam(DLType.DEFAULT, album.id, album.videos, priority, album.title, filePath),
        listener);
  }

  export function cancel(id: string) {
    AlbumDownloadManagerImpl.getInstance().cancel(id)
  }

  export function cancelByFilePath(filePath: string) {
    AlbumDownloadManagerImpl.getInstance().cancelByFilePath(filePath)
  }

  export function cancelNClear(id: string) {
    AlbumDownloadManagerImpl.getInstance().cancelNClear(id)
  }

  export function cancelNClearByFilePath(filePath: string) {
    AlbumDownloadManagerImpl.getInstance().cancelNClearByFilePath(filePath)
  }

  /**
   * 下载类型
   */
  export class DLType {
    static readonly DEFAULT = "DL_TYPE_DEFAULT"
  }

  /**
   * 下载状态
   */
  export class DownloadState {
    /**
     * 未下载
     */
    static readonly UNDOWNLOAD = 0;
    /**
     * 下载中
     */
    static readonly DOWNLOADING = 1;
    /**
     * 暂停
     */
    static readonly PAUSED = 2;
    /**
     * 等待下载
     */
    static readonly PENDING = 3;
    /**
     * 下载失败
     */
    static readonly FAILED = 4;
    /**
     * 下载成功
     */
    static readonly COMPLETED = 5;
    /**
     * 开始下载
     */
    static readonly STARTED = 7;
  }


}