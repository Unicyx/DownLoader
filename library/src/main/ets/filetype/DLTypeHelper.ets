import { IAlbumDownloadListener } from '../api/IAlbumDownloadListener'
import { AlbumDownloadInfo } from '../data/AlbumDownloadInfo'
import { AlbumDownloadInfoManager } from '../data/AlbumDownloadInfoManager'
import { AlbumDownloadParam } from '../data/AlbumDownloadParam'
import { BaseDLTypeHelper } from './BaseDLTypeHelper'

export class DLTypeHelper {
  pendingList: Array<string> = []
  downloadingList: Array<string> = []
  needSort: boolean = false
  mCustomHelper: BaseDLTypeHelper

  constructor(customHelper: BaseDLTypeHelper) {
    this.mCustomHelper = customHelper
  }

  public isPending(key: string): boolean {
    return this.pendingList?.includes(key)
  }

  /**
   * 添加到等待下载的队列
   * @param download
   */
  public addPending(download: AlbumDownloadInfo): void {
    if (!download || this.pendingList.includes(download.getId())) {
      //已在下载等待队列
      return
    }
    if (this.pendingList.length == 0) {
      this.pendingList.push()
    } else if (this.pendingList.length == 1) {
      let pendingAlbumDownloadInfo = AlbumDownloadInfoManager.getInstance().getAlbumDownloadInfo(this.pendingList[0])
      if (!pendingAlbumDownloadInfo) {
        this.pendingList = [download.getId()]
      } else if (download.getPriority() > pendingAlbumDownloadInfo.getPriority()) {
        this.pendingList.unshift(download.getId())
      } else {
        this.pendingList.push(download.getId())
      }
    } else {
      let firstAlbumDownloadInfo = AlbumDownloadInfoManager.getInstance().getAlbumDownloadInfo(this.pendingList[0])
      let lastAlbumDownloadInfo =
        AlbumDownloadInfoManager.getInstance().getAlbumDownloadInfo(this.pendingList[this.pendingList.length - 1])
      if (firstAlbumDownloadInfo && firstAlbumDownloadInfo.getPriority() <= download.getPriority()) {
        //优先级最高   加入到队列第一个
        this.pendingList.unshift(download.getId())
      } else if (lastAlbumDownloadInfo != null && lastAlbumDownloadInfo.getPriority() >= download.getPriority()) {
        this.pendingList.push(download.getId())
      } else {
        //无法快速定位出排序位置  等后面重新排序
        this.pendingList.push(download.getId())
        this.needSort = true
      }
    }
  }

  /**
   * 添加到正在下载的队列
   * @param download
   */
  public addDownloading(download: AlbumDownloadInfo): void {
    this.downloadingList.push(download.getId())
    this.pendingList = this.pendingList.filter(item => item !== download.getId())
  }

  /**
   * 等待下载队列排序
   */
  private sortPendingList(): void {
    if (!this.needSort) {
      return
    }
    this.needSort = false
    this.pendingList.sort((left, right) => {
      //按优先级顺序进行降序排序
      let leftAlbumDownloadInfo = AlbumDownloadInfoManager.getInstance().getAlbumDownloadInfo(left)
      let rightAlbumDownloadInfo = AlbumDownloadInfoManager.getInstance().getAlbumDownloadInfo(right)
      if (!leftAlbumDownloadInfo || !rightAlbumDownloadInfo) {
        return 0

      }
      return rightAlbumDownloadInfo.getPriority() - leftAlbumDownloadInfo.getPriority()
    })
  }

  /**
   * 同时下载的格式已达上线
   * @returns
   */
  public isBusy(): boolean {
    return this.downloadingList.length >= this.getHelper().getMaxDownloadCount()
  }


  public hasPendingInfo(): boolean {
    return this.pendingList.length > 0
  }

  public hasNext(): boolean {
    return this.downloadingList.length < this.getHelper().getMaxDownloadCount()
  }

  public popNext(): string | null | undefined {
    this.sortPendingList()
    if (this.pendingList.length > 0) {
      return this.pendingList.shift()
    }
    return null
  }

  public remove(id: string) {
    this.downloadingList = this.downloadingList.filter(item => item !== id)
    this.pendingList = this.pendingList.filter(item => item !== id)
  }


  private getHelper() {
    return this.mCustomHelper
  }

  public getDownloadListener(): IAlbumDownloadListener {
    return this.getHelper()
  }

  public getId(param: AlbumDownloadParam) {
    return this.getHelper().getDownloadId(param)
  }

  public getFilePath(param: AlbumDownloadParam) {
    return this.getHelper().getFilePath(param)
  }

  /**
   * 填充最终参数
   * @param param
   */
  public fillAlbumDownloadParams(param: AlbumDownloadParam) {
    param.finalUrls = param.videos.map(video => video.url)
    param.finalPath = this.getFilePath(param)
  }

  public getDownloadType(): string {
    return this.getHelper().getDownloadType()
  }
}