import { AlbumDownloadManager } from '../api/AlbumDownloadManager'
import { DownloadError } from '@babyohs/download/src/main/ets/data/DownloadError'
import { AlbumDownloadParam, Video } from './AlbumDownloadParam'


/**
 * 下载信息唯一标识是下载地址  不存在类型概念
 * 支持多种参数触发下载 下载完会拷贝文件到不同的路径
 */
export class AlbumDownloadInfo {
  private multiParam: Map<string, AlbumDownloadParam> = new Map
  private albumDownloadParam: AlbumDownloadParam
  private downloadType: string
  private priority: number
  private id: string
  private videos: Video[]
  private urls: string[]
  private title: string
  //文件下载的最终路径
  private filePath: string
  //文件下载的临时路径
  private downloadPath?: string
  private totalCnt: number = 0
  private downloadCnt: number = 0
  private state: number = AlbumDownloadManager.DownloadState.UNDOWNLOAD
  private error?: DownloadError
  private progress?: number

  constructor(albumDownloadParam: AlbumDownloadParam) {
    this.urls = albumDownloadParam.finalUrls!
    this.id = albumDownloadParam.id
    this.title = albumDownloadParam.title!
    this.videos = albumDownloadParam.videos
    this.filePath = albumDownloadParam.finalPath!
    this.albumDownloadParam = albumDownloadParam
    this.priority = albumDownloadParam.priority
    this.downloadType = albumDownloadParam.downloadType
  }

  public resetAlbumDownloadParam(albumDownloadParam: AlbumDownloadParam) {
    this.urls = albumDownloadParam.finalUrls!
    this.filePath = albumDownloadParam.finalPath!
    this.id = albumDownloadParam.id
    this.videos = albumDownloadParam.videos
    this.title = albumDownloadParam.title!
    this.albumDownloadParam = albumDownloadParam
    this.priority = albumDownloadParam.priority
    this.downloadType = albumDownloadParam.downloadType
    this.state = AlbumDownloadManager.DownloadState.PENDING
    this.multiParam.clear()
  }

  mergeAlbumDownloadParam(albumDownloadParam: AlbumDownloadParam) {
    if (albumDownloadParam.finalPath === this.filePath) {
      this.albumDownloadParam = albumDownloadParam
    } else {
      this.multiParam.set(albumDownloadParam.finalPath!, albumDownloadParam)
    }
  }

  getPriority(): number {
    return this.priority
  }

  getDownloadKey(): string[] {
    return this.getUrls()
  }

  getUrls(): string[] {
    return this.urls
  }

  getVideos(): Video[] {
    return this.videos
  }

  getTitle(): string {
    return this.title
  }

  getId(): string {
    return this.id
  }

  getFilePath(): string {
    return this.filePath
  }

  setDownloadPath(downloadPath: string) {
    this.downloadPath = downloadPath
  }

  getDownloadPath(): string {
    return this.downloadPath ? this.downloadPath : this.getFilePath()
  }

  getTotalCnt(): number {
    return this.totalCnt
  }

  getDownloadCnt(): number {
    return this.downloadCnt
  }

  getProgress(): number {
    if (this.totalCnt == 0) {
      return 0
    }
    this.progress = Math.min(100, Math.floor(this.downloadCnt * 100 / this.totalCnt))
    return this.progress
  }

  getState(): number {
    return this.state
  }

  getError(): DownloadError | null | undefined {
    return this.error
  }

  getAlbumDownloadParam(filePath?: string): AlbumDownloadParam | null | undefined {
    let result: AlbumDownloadParam | null | undefined
    if (filePath && this.multiParam?.has(filePath)) {
      result = this.multiParam.get(filePath)
    }
    if (!result) {
      result = this.albumDownloadParam
    }
    return result
  }

  getDownloadType(): string {
    return this.downloadType
  }

  setTotalCnt(totalCnt: number) {
    this.totalCnt = totalCnt
  }

  setDownloadCnt(downloadCnt: number) {
    this.downloadCnt = downloadCnt
    this.progress = this.getProgress()
  }

  setState(state: number) {
    this.state = state
  }

  setCompleted(totalCnt: number) {
    if (totalCnt > 0) {
      this.totalCnt = totalCnt;
    }
    this.downloadCnt = this.totalCnt;
    this.progress = 100
    this.setState(AlbumDownloadManager.DownloadState.COMPLETED)
  }

  setFailed(error: DownloadError) {
    this.state = AlbumDownloadManager.DownloadState.FAILED
    this.error = error
    this.setState(AlbumDownloadManager.DownloadState.FAILED)
  }

  isDownloadCompleted(): boolean {
    return this.state === AlbumDownloadManager.DownloadState.COMPLETED
  }
}