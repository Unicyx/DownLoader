import { IAlbumDownloadListener } from '../api/IAlbumDownloadListener';
import { DownloadError } from '@babyohs/download/src/main/ets/data/DownloadError';
import { AlbumDownloadInfo } from '../data/AlbumDownloadInfo';
import { AlbumDownloadParam } from '../data/AlbumDownloadParam';
import { Md5 } from '@babyohs/utils';
import { Constants } from '../const/Constants';

export abstract class BaseDLTypeHelper implements IAlbumDownloadListener {
  //同时下载的最大个数
  private static readonly MAX_DOWNLOAD_COUNT: number = 3

  onStart(downloadInfo: AlbumDownloadInfo): void {

  }

  onProgress(downloadInfo: AlbumDownloadInfo): void {

  }

  onCompleted(downloadInfo: AlbumDownloadInfo): void {

  }

  onFailed(downloadInfo?: AlbumDownloadInfo | null, error?: DownloadError): void {

  }

  onEnd(downloadInfo: AlbumDownloadInfo): void {

  }

  /**
   * 同时下载的最大个数
   * @returns
   */
  getMaxDownloadCount(): number {
    return BaseDLTypeHelper.MAX_DOWNLOAD_COUNT
  }


  getDownloadKey(param: AlbumDownloadParam): string {
    let id = this.getDownloadId(param);
    if (id) {
      return Md5.hashStr(id)
    }
    return ""
  }

  getDownloadId(param: AlbumDownloadParam): string {
    return param.id ?? ""
  }

  getFilePath(param: AlbumDownloadParam): string {
    if (param.path) {
      return param.path
    }
    return Constants.getCachePath(this.getDownloadId(param));
  }

  abstract getDownloadType(): string
}