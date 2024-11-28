import HashMap from '@ohos.util.HashMap';
import { AlbumDownloadTask } from './AlbumDownloadTask';
import { IAlbumDownloadListener } from '../api/IAlbumDownloadListener';
import { DownloadError } from '@babyohs/download/src/main/ets/data/DownloadError';
import { AlbumDownloadInfo } from '../data/AlbumDownloadInfo';
import { AlbumDownloadInfoManager } from '../data/AlbumDownloadInfoManager';
import { AlbumDownloadParam } from '../data/AlbumDownloadParam';
import { DLTypeManager } from '../filetype/DLTypeManager';
import { DLTypeHelper } from '../filetype/DLTypeHelper';
import { Utils } from '@babyohs/download/src/main/ets/utils/Utils'

export class AlbumDownloadManagerImpl implements IAlbumDownloadListener {
  private static INSTANCE: AlbumDownloadManagerImpl;
  //HashMap:id --> Task
  private albumDownloadTaskMap: HashMap<string, AlbumDownloadTask> = new HashMap()
  //正在下载的任务
  private downloadingArray: Array<string> = []
  private pendingArray: Array<string> = []
  //最多同时下载个数 不一定是真正的同时在下载还要看下载引擎那边支持几个同时在下载
  private maxDownloadCount: number = 10

  static getInstance(): AlbumDownloadManagerImpl {
    if (!AlbumDownloadManagerImpl.INSTANCE) {
      AlbumDownloadManagerImpl.INSTANCE = new AlbumDownloadManagerImpl()
    }
    return AlbumDownloadManagerImpl.INSTANCE;
  }

  cancel(id: string) {
    if (this.albumDownloadTaskMap.hasKey(id)) {
      let downloadTask = this.albumDownloadTaskMap.remove(id);
      downloadTask.cancel()
    }
  }

  cancelByFilePath(filePath: string) {
    let downloadInfo = AlbumDownloadInfoManager.getInstance().getAlbumDownloadInfoByFilePath(filePath);
    let id = downloadInfo?.getId();
    if (id) {
      this.cancel(id);
    }
  }

  cancelNClear(id: string) {
    if (this.albumDownloadTaskMap.hasKey(id)) {
      let downloadTask = this.albumDownloadTaskMap.remove(id);
      downloadTask.cancelNClear()
    }
  }

  cancelNClearByFilePath(filePath: string) {
    let downloadInfo = AlbumDownloadInfoManager.getInstance().getAlbumDownloadInfoByFilePath(filePath);
    let id = downloadInfo?.getId();
    if (id) {
      this.cancelNClear(id);
    }
  }


  /**
   * 开始下载 -入口函数
   * @param albumDownloadParam
   * @param listener
   */
  download(albumDownloadParam: AlbumDownloadParam, listener?: IAlbumDownloadListener): void {
    let helper = DLTypeManager.getInstance().getDLTypeHelper(albumDownloadParam.downloadType);
    if (helper == null) {
      //不支持当前下载类型
      if (listener?.onFailed) {
        listener?.onFailed(null,
          new DownloadError("-999", "do not support current type:" + albumDownloadParam.downloadType))
      }
      return
    }
    helper.fillAlbumDownloadParams(albumDownloadParam)
    let downloadTask = this.albumDownloadTaskMap.get(albumDownloadParam.id)
    if (downloadTask) {
      //正在下载的话就合并下载参数 同时回调给外部开始下载
      downloadTask.mergeDownloadParam(albumDownloadParam, listener);
      return
    }
    let downloadInfo = AlbumDownloadInfoManager.getInstance().createAlbumDownloadInfo(albumDownloadParam)
    //新下载 创建下载信息
    //创建AlbumDownloadInfo
    //判断AlbumDownloadInfo有效性和是否正在下载
    //触发真正下载
    let result = this.checkValidity(downloadInfo);
    if (result != null && listener?.onFailed) {
      listener?.onFailed(null, new DownloadError("0", result))
      return
    }
    //尝试开始下载
    this.newDownload(helper, downloadInfo, listener)
  }

  isDownloading(id: string): boolean {
    return this.albumDownloadTaskMap.hasKey(id)
  }

  /**
   * 检测参数的有效性
   * @param downloadInfo
   * @returns
   */
  private checkValidity(downloadInfo: AlbumDownloadInfo): string | null {
    if (!downloadInfo.getUrls()) {
      return "url 不能为空！"
    }
    if (!downloadInfo.getFilePath() || downloadInfo.getFilePath().trim() == "") {
      return "保存路径 不能为空！"
    }
    const urls = downloadInfo.getUrls()
    for (let url of urls) {
      if (!url.startsWith("http://") && !url.startsWith("https://")) {
        return "url 地址不合法：" + url;
      }
    }
    return null
  }

  /**
   * 开始新的下载
   * @param downloadInfo
   * @param listener
   */
  private async newDownload(helper: DLTypeHelper, downloadInfo: AlbumDownloadInfo, listener?: IAlbumDownloadListener) {
    let downloadTask: AlbumDownloadTask = new AlbumDownloadTask(downloadInfo, listener, this, false)
    if (downloadTask) {
      //保存下载任务
      this.albumDownloadTaskMap.set(downloadInfo.getId(), downloadTask)
      downloadTask?.onPending()
      if (this.downloadingArray.length >= this.maxDownloadCount || helper.isBusy()) {
        this.addPending(helper, downloadInfo, downloadTask)
      } else {
        this.addStart(helper, downloadInfo, downloadTask)
      }
    } else {
      if (listener?.onFailed) {
        listener?.onFailed(downloadInfo, new DownloadError("-999", "createAlbumDownloadTask Failed"))
      }
    }
  }

  /**
   * 加入等待队列
   * @param downloadTask
   */
  private addPending(helper: DLTypeHelper, downloadInfo: AlbumDownloadInfo, downloadTask: AlbumDownloadTask) {
    this.pendingArray.push(downloadInfo.getId())
    helper.addPending(downloadInfo)
  }

  /**
   * 加入开始队列触发下载
   * @param downloadTask
   */
  private addStart(helper: DLTypeHelper, downloadInfo: AlbumDownloadInfo, downloadTask: AlbumDownloadTask) {
    Utils.mkFileDir(downloadInfo.getFilePath())
    Utils.mkFileDir(downloadInfo.getDownloadPath())
    downloadTask.start()
    this.downloadingArray.push(downloadInfo.getId())
    this.pendingArray = this.pendingArray.filter(item => item !== downloadInfo.getId())
    helper.addDownloading(downloadInfo)
  }

  /******************************************************************
   *      下载监听 Start
   *****************************************************************/


  onPending(downloadInfo: AlbumDownloadInfo) {
    if (!downloadInfo) {
      return
    }
    DLTypeManager.getInstance().onPending(downloadInfo)
  }

  /**
   * 下载开始
   */
  onStart(downloadInfo?: AlbumDownloadInfo) {
    if (!downloadInfo) {
      return
    }
    DLTypeManager.getInstance().onStart(downloadInfo)
    AlbumDownloadInfoManager.getInstance().updateAlbumDownloadInfo(downloadInfo)
  }

  /**
   * 进度更新
   */
  onProgress(downloadInfo?: AlbumDownloadInfo) {
    if (!downloadInfo) {
      return
    }
    DLTypeManager.getInstance().onProgress(downloadInfo)
    AlbumDownloadInfoManager.getInstance().updateAlbumDownloadInfo(downloadInfo);
  }

  /**
   * 下载完成
   */
  onCompleted(downloadInfo?: AlbumDownloadInfo) {
    if (!downloadInfo) {
      return
    }
    DLTypeManager.getInstance().onCompleted(downloadInfo)
    AlbumDownloadInfoManager.getInstance().updateAlbumDownloadInfo(downloadInfo);
  }

  /**
   * 下载失败
   */
  onFailed(downloadInfo?: AlbumDownloadInfo | null, error?: DownloadError) {
    if (!downloadInfo) {
      return
    }
    DLTypeManager.getInstance().onFailed(downloadInfo, error)
    AlbumDownloadInfoManager.getInstance().updateAlbumDownloadInfo(downloadInfo);
  }

  /**
   * 下载暂停/中断
   */
  onCanceled(downloadInfo?: AlbumDownloadInfo) {
    if (!downloadInfo) {
      return
    }
    DLTypeManager.getInstance().onCanceled(downloadInfo)
    AlbumDownloadInfoManager.getInstance().updateAlbumDownloadInfo(downloadInfo);
  }

  onDownloadEnd(downloadInfo?: AlbumDownloadInfo) {
    if (!downloadInfo) {
      return
    }
    DLTypeManager.getInstance().onDownloadEnd(downloadInfo)
    this.albumDownloadTaskMap.remove(downloadInfo.getId())
    this.downloadingArray = this.downloadingArray.filter(item => item !== downloadInfo.getId())
    this.checkPending()
  }

  isBusy() {
    return this.downloadingArray.length >= this.maxDownloadCount
  }

  private checkPending() {
    if (this.pendingArray.length > 0) {
      let i = 0
      while (!this.isBusy() && i < this.pendingArray.length) {
        let url = this.pendingArray[i];
        let downloadTask = this.albumDownloadTaskMap.get(url)
        if (downloadTask) {
          let helper =
            DLTypeManager.getInstance().getDLTypeHelper(downloadTask.getAlbumDownloadInfo().getDownloadType())
          if (!helper.isBusy()) {
            this.addStart(helper, downloadTask.getAlbumDownloadInfo(), downloadTask)
            continue
          }
        }
        i++;
      }
    }
  }

  /******************************************************************
   *      下载监听 End
   *****************************************************************/
}