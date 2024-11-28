import { DownloadError } from '@babyohs/download/src/main/ets/data/DownloadError'
import { AlbumDownloadInfo } from '../data/AlbumDownloadInfo'

export interface IAlbumDownloadListener{
  onPending?:(AlbumDownloadInfo:AlbumDownloadInfo) => void
  onStart?:(AlbumDownloadInfo:AlbumDownloadInfo) => void
  onProgress?:(AlbumDownloadInfo:AlbumDownloadInfo) => void
  onCompleted:(AlbumDownloadInfo:AlbumDownloadInfo,filePath?:string) => void
  onFailed?:(AlbumDownloadInfo?:AlbumDownloadInfo|null,error?:DownloadError) => void
  onCanceled?:(AlbumDownloadInfo:AlbumDownloadInfo) => void
  //下载结束  在 onFailed onPause onCompleted 之后调用
  onDownloadEnd?:(AlbumDownloadInfo:AlbumDownloadInfo) => void
}