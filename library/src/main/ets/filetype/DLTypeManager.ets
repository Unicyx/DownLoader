import HashMap from '@ohos.util.HashMap'
import { DownloadError } from '@babyohs/download/src/main/ets/data/DownloadError'
import { AlbumDownloadInfo } from '../data/AlbumDownloadInfo'
import { BaseDLTypeHelper } from './BaseDLTypeHelper'
import { DefaultDLTypeHelper } from './DefaultDLTypeHelper'
import { DLTypeHelper } from './DLTypeHelper'

/**
 * 自定义下载管理  管理类
 */
export class DLTypeManager{
  private static INSTANCE:DLTypeManager
  helperMap:HashMap<string,DLTypeHelper> = new HashMap()

  public static getInstance():DLTypeManager{
    if(DLTypeManager.INSTANCE == null){
      DLTypeManager.INSTANCE = new DLTypeManager()
    }
    return DLTypeManager.INSTANCE
  }

  constructor() {
    this.addDLTypeHelper(new DefaultDLTypeHelper())
  }

  public getDLTypeHelper(type:string):DLTypeHelper{
    return this.helperMap.get(type)
  }

  public addDLTypeHelper(typeHelper:BaseDLTypeHelper){
    let helper = new DLTypeHelper(typeHelper);
    this.helperMap.set(helper.getDownloadType(),helper)
  }

  addPending(downloadInfo:AlbumDownloadInfo){
    let helper = this.helperMap.get(downloadInfo.getDownloadType())
    helper?.addPending(downloadInfo)
  }

  addStart(downloadInfo:AlbumDownloadInfo){
    let helper = this.helperMap.get(downloadInfo.getDownloadType())
    helper?.addPending(downloadInfo)
  }

  onPending(downloadInfo: AlbumDownloadInfo){
    let helper = this.helperMap.get(downloadInfo.getDownloadType())
    let pending = helper?.getDownloadListener().onPending;
    if (pending) {
      pending(downloadInfo)
    }
  }

  /**
   * 下载开始
   */
  onStart(downloadInfo: AlbumDownloadInfo){
    let helper = this.helperMap.get(downloadInfo.getDownloadType())
    let onStart = helper?.getDownloadListener().onStart
    if (onStart) {
      onStart(downloadInfo)
    }
  }
  /**
   * 进度更新
   */
  onProgress(downloadInfo: AlbumDownloadInfo){
    let helper = this.helperMap.get(downloadInfo.getDownloadType())
    let onProgress = helper?.getDownloadListener().onProgress
    if (onProgress) {
      onProgress(downloadInfo)
    }
  }
  /**
   * 下载完成
   */
  onCompleted(downloadInfo: AlbumDownloadInfo,filePath?:string){
    let helper = this.helperMap.get(downloadInfo.getDownloadType())
    helper?.getDownloadListener().onCompleted(downloadInfo)
  }
  /**
   * 下载失败
   */
  onFailed(downloadInfo: AlbumDownloadInfo,error?:DownloadError){
    let helper = this.helperMap.get(downloadInfo.getDownloadType())
    let onFailed = helper?.getDownloadListener().onFailed
    if (onFailed) {
      onFailed(downloadInfo, error)
    }
  }

  /**
   * 下载暂停/中断
   */
  onCanceled(downloadInfo: AlbumDownloadInfo){
    let helper = this.helperMap.get(downloadInfo.getDownloadType())
    let onCanceled = helper?.getDownloadListener().onCanceled
    if (onCanceled) {
      onCanceled(downloadInfo)
    }
  }

  onDownloadEnd(downloadInfo: AlbumDownloadInfo){
    let helper = this.helperMap.get(downloadInfo.getDownloadType())
    helper?.remove(downloadInfo.getId())
    let onDownloadEnd = helper?.getDownloadListener().onDownloadEnd
    if (onDownloadEnd) {
      onDownloadEnd(downloadInfo)
    }
  }

}