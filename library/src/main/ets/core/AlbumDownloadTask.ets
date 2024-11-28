import HashMap from '@ohos.util.HashMap'
import { DownloadError } from '@babyohs/download/src/main/ets/data/DownloadError'
import { AlbumDownloadInfo } from '../data/AlbumDownloadInfo'
import { AlbumDownloadInfoManager } from '../data/AlbumDownloadInfoManager'
import { AlbumDownloadParam } from '../data/AlbumDownloadParam'
import { AlbumDownloadManager } from '../api/AlbumDownloadManager'
import { IAlbumDownloadListener } from '../api/IAlbumDownloadListener'
import { IEngineDownloadListener } from './IEngineDownloadListener'
import { DownloadTaskFactory } from '../core/DownloadTaskFactory'
import { Utils } from '@babyohs/download/src/main/ets/utils/Utils'
import { AlbumDownloadFilePathSp } from '../data/table/AlbumDownloadFilePathSp'

export async function createDownloadTask(url: string, filePath: string, restart: boolean,
  listener: IEngineDownloadListener) {
  return (await getImpl()).createDownloadTask(url, filePath, restart, listener)
}

/**
 * 下载任务
 */
export class AlbumDownloadTask implements IEngineDownloadListener {
  private globalListener?: IAlbumDownloadListener | null
  private downloadListenerWrapper: DownloadListenerWrapper
  private downloadInfo: AlbumDownloadInfo
  private downloadTask?: DownloadTaskFactory.IDownloadTask
  private restart: boolean = false
  private hasStart: boolean = false
  private isCanceled: boolean = false;
  private urls: string[]
  private id: string
  private title: string

  constructor(downloadInfo: AlbumDownloadInfo, listener?: IAlbumDownloadListener,
    globalListener?: IAlbumDownloadListener | null, restart: boolean = false) {
    this.downloadListenerWrapper = new DownloadListenerWrapper(downloadInfo, listener)
    this.globalListener = globalListener;
    this.downloadInfo = downloadInfo;
    this.restart = restart
    this.urls = downloadInfo.getUrls()
    this.id = downloadInfo.getId()
    this.title = downloadInfo.getTitle()
  }

  /**
   * 合并参数  一般是同一个下载链接不同保存路径才会用到
   * @param downloadParam
   * @param listener
   */
  public mergeDownloadParam(downloadParam: AlbumDownloadParam, listener?: IAlbumDownloadListener) {
    this.downloadInfo.mergeAlbumDownloadParam(downloadParam)
    this.downloadListenerWrapper.addDownloadListener(downloadParam.finalPath!, listener)
  }

  private getDownloadListener(): IEngineDownloadListener {
    return this
  }

  /**
   * 开始下载
   */
  //TODO: 加入单个视频下载的调用和控制
  // public async start() {
  //   Utils.LogD(`开始下载任务：${this.title}`)
  //   if (this.isCanceled) {
  //     return
  //   }
  //   if (!this.downloadTask) {
  //     try {
  //       this.downloadTask = await DownloadTaskFactory.createDownloadTask(
  //         this.downloadInfo.getId(),
  //         this.downloadInfo.getDownloadPath(),
  //         this.restart,
  //         this.getDownloadListener()
  //       )
  //     } catch (e) {
  //     }
  //   }
  //   if (this.isCanceled) {
  //     return
  //   }
  //   if (!this.downloadTask) {
  //     this.onFailed(this.downloadInfo.getId(), new DownloadError("-999", "downloadTask 创建失败"))
  //   } else {
  //     this.downloadTask?.startDownload()
  //   }
  // }

  /**
   * 取消下载
   */
  public cancel() {
    Utils.LogD(`取消下载：${this.title}`)
    if (this.isCanceled) {
      return
    }
    this.isCanceled = true;
    this.downloadTask?.cancel()
  }

  /**
   * 取消下载并清理缓存
   */
  public cancelNClear() {
    Utils.LogD(`取消下载并清理缓存：${this.title}`)
    if (this.isCanceled) {
      return
    }
    this.isCanceled = true;
    return new Promise<void>(() => {
      //清理缓存
      this.downloadTask?.cancelNClear()
      //删除已下载的文件
      Utils.deleteFile(this.downloadInfo.getDownloadPath())
      //删除下载信息
      AlbumDownloadInfoManager.getInstance().clearAlbumDownloadInfo(this.downloadInfo)
    })
  }

  getAlbumDownloadInfo(): AlbumDownloadInfo {
    return this.downloadInfo
  }

  onPending() {
    Utils.LogD(`加入下载队列：${this.title}`)
    if (!this.hasStart) {
      try {
        if (this.downloadInfo.isDownloadCompleted()) {
          return
        }
        this.downloadInfo.setState(AlbumDownloadManager.DownloadState.PENDING)
        this.downloadListenerWrapper.onPending(this.downloadInfo)
      } catch (e) {

      }
      if (this.globalListener?.onPending) {
        this.globalListener?.onPending(this.downloadInfo)
      }
    }
  }

  /**
   * 下载开始
   */
  onStart(url: string, totalSize: number) {
    Utils.LogD(`开始下载：${this.title}`)
    if (!url) {
      return
    }
    this.hasStart = true
    this.downloadInfo.setState(AlbumDownloadManager.DownloadState.STARTED)
    this.downloadInfo.setTotalCnt(totalSize)
    this.downloadListenerWrapper.onStart(this.downloadInfo)
    if (this.globalListener?.onStart) {
      this.globalListener?.onStart(this.downloadInfo)
    }
  }

  /**
   * 进度更新
   */
  onProgress(url: string, progress: number, totalSize: number, downloadSize: number) {
    Utils.LogD(`进度更新：${progress} / ${this.title}`)
    if (!url) {
      return
    }
    if (this.downloadInfo.isDownloadCompleted()) {
      this.downloadInfo.setTotalCnt(totalSize)
      this.downloadInfo.setDownloadCnt(totalSize)
      return
    }
    this.downloadInfo.setTotalCnt(totalSize)
    this.downloadInfo.setDownloadCnt(downloadSize)
    this.downloadInfo.setState(AlbumDownloadManager.DownloadState.DOWNLOADING)
    this.downloadListenerWrapper.onProgress(this.downloadInfo)
    if (this.globalListener?.onProgress) {
      this.globalListener?.onProgress(this.downloadInfo)
    }
  }

  /**
   * 下载完成
   */
  onCompleted(url: string, totalSize: number) {
    Utils.LogD(`下载完成：${this.title}`)
    if (!url) {
      return
    }
    this.downloadInfo.setCompleted(totalSize)
    this.downloadListenerWrapper.onCompleted(this.downloadInfo)
    this.globalListener?.onCompleted(this.downloadInfo)

    this.onDownloadEnd(this.downloadInfo)
  }

  /**
   * 下载失败
   */
  onFailed(url: string, error: DownloadError) {
    Utils.LogD(`下载失败：${this.title}`, error)
    if (!url) {
      return
    }
    this.downloadInfo.setFailed(error)
    this.downloadListenerWrapper.onFailed(this.downloadInfo, error)
    if (this.globalListener?.onFailed) {
      this.globalListener?.onFailed(this.downloadInfo, error)
    }

    this.onDownloadEnd(this.downloadInfo)
  }

  /**
   * 下载暂停/中断
   */
  onCanceled(url: string) {
    Utils.LogD(`下载已取消：${this.title}`)
    if (!url) {
      return
    }
    this.downloadInfo.setState(AlbumDownloadManager.DownloadState.PAUSED)
    this.downloadListenerWrapper.onCanceled(this.downloadInfo)
    if (this.globalListener?.onCanceled) {
      this.globalListener?.onCanceled(this.downloadInfo)
    }

    this.onDownloadEnd(this.downloadInfo)
  }

  onDownloadEnd: (downloadInfo: AlbumDownloadInfo) => void = (downloadInfo: AlbumDownloadInfo) => {
    this.downloadListenerWrapper.onDownloadEnd(downloadInfo)
    if (this.globalListener?.onDownloadEnd) {
      this.globalListener?.onDownloadEnd(downloadInfo)
    }
  }
}

/**
 * 下载监听封装  支持多个监听
 */
class DownloadListenerWrapper implements IAlbumDownloadListener {
  listenerMap: HashMap<string, IAlbumDownloadListener | null | undefined> = new HashMap()
  hasStart: boolean = false
  id: string
  downloadInfo: AlbumDownloadInfo

  constructor(downloadInfo: AlbumDownloadInfo, listener?: IAlbumDownloadListener) {
    this.id = downloadInfo.getId()
    this.downloadInfo = downloadInfo
    this.listenerMap.set(downloadInfo.getFilePath(), listener)
  }

  public addDownloadListener(filePath: string, listener?: IAlbumDownloadListener) {
    AlbumDownloadFilePathSp.getInstance().set(filePath, this.id)
    this.listenerMap.set(filePath, listener)
    if (this.hasStart && listener?.onStart) {
      listener?.onStart(this.downloadInfo)
    }
  }

  public removeDownloadListener(listener: IAlbumDownloadListener) {
    this.listenerMap.forEach((value, key) => {
      if (value == listener) {
        //放到后台下载
        this.listenerMap.set(key, null)
      }
    })
  }

  onPending(downloadInfo: AlbumDownloadInfo) {
    try {
      this.listenerMap.forEach(listener => {
        if (listener?.onPending) {
          listener?.onPending(downloadInfo)
        }
      })
    } catch (e) {
      let error = e as Error;
      console.error(error.message)
    }
  }

  onStart(downloadInfo: AlbumDownloadInfo) {
    this.hasStart = true
    try {
      this.listenerMap.forEach(listener => {
        if (listener?.onStart) {
          listener?.onStart(downloadInfo)
        }
      })
    } catch (e) {
      let error = e as Error;
      console.error(error.message)
    }
  }

  onProgress(downloadInfo: AlbumDownloadInfo) {
    try {
      this.listenerMap.forEach(listener => {
        if (listener?.onProgress) {
          listener?.onProgress(downloadInfo)
        }
      })
    } catch (e) {
      let error = e as Error;
      console.error(error.message)
    }
  }

  onCompleted(downloadInfo: AlbumDownloadInfo) {
    try {
      let downloadFilePath = downloadInfo.getDownloadPath()
      //判断文件是否存在
      if (!Utils.isFileExist(downloadFilePath)) {
        this.onFailed(downloadInfo, new DownloadError("-999", "文件不存在"))
        return
      }
      let deleteDownloadFile = true
      //先拷贝文件  再设置状态  再通知已下载完成
      this.listenerMap.forEach((listener, filePath) => {
        if (filePath && filePath !== downloadFilePath) {
          //保存路径和下载路径不一样需要拷贝
          Utils.copyFile(downloadFilePath, filePath)
        } else {
          //保存路径和下载路径一样 保留下载文件
          deleteDownloadFile = false
        }
      })
      if (deleteDownloadFile) {
        Utils.deleteFile(downloadFilePath)
      }
      //设置下载完成状态
      downloadInfo.setCompleted(downloadInfo.getTotalCnt())
      //通知外部下载完成
      this.listenerMap.forEach((listener, filePath) => {
        listener?.onCompleted(downloadInfo, filePath)
      })
    } catch (e) {
      let error = e as Error;
      console.error(error.message)
    }
  }

  onFailed(downloadInfo?: AlbumDownloadInfo | null, error?: DownloadError) {
    //下载失败
    try {
      this.listenerMap.forEach(listener => {
        if (listener?.onFailed) {
          listener?.onFailed(downloadInfo, error)
        }
      })
    } catch (e) {
      let error = e as Error;
      console.error(error.message)
    }
  }

  onCanceled(downloadInfo: AlbumDownloadInfo) {
    //暂停下载
    try {
      this.listenerMap.forEach(listener => {
        if (listener?.onCanceled) {
          listener?.onCanceled(downloadInfo)
        }
      })
    } catch (e) {
      let error = e as Error;
      console.error(error.message)
    }
  }

  onDownloadEnd(downloadInfo: AlbumDownloadInfo) {
    //下载结束  在 onFailed onPause onCompleted 之后调用
    try {
      this.listenerMap.forEach(listener => {
        if (listener?.onDownloadEnd) {
          listener?.onDownloadEnd(downloadInfo)
        }
      })
    } catch (e) {
      let error = e as Error;
      console.error(error.message)
    }
  }
}