import { DownloadManager } from '@babyohs/download'
import fs from '@ohos.file.fs'
import { showToast } from '@babyohs/globaldata'
import { preferences } from '@babyohs/globaldata/src/main/ets/utils/Preferences'
import { HashMap } from '@kit.ArkTS'

export interface AudioItemType {
  audioID: number
  audioName: string
  audioUrl: string
}

export interface DownloadOptions {
  audioList: AudioItemType[]
  albumID: number
  albumName: string
  albumCover: string
}

export enum AlbumDownState {
  Pending = "pending", //准备
  Loading = "loading", //下载中
  Paused = "paused", //暂停下载
  Success = "success", //下载成功
  Failed = "failed" // 下载失败
}

export interface AlbumDownloadInfo {
  state: AlbumDownState
  index: number
  total: number
  progress: number
  albumID: number
}

class AlbumDownloadManager {
  private downloadOptions?: DownloadOptions
  private currentIndex: number = 1
  private total: number = 0
  private downloadState: AlbumDownState = AlbumDownState.Pending
  private albumDownQueue: DownloadOptions[] = []

  // todo: priority
  startDownload(options: DownloadOptions, priority: boolean = false) {
    // if (priority) {
    //   if (this.downloadState == AlbumDownState.Loading) {
    //     if (options.albumID == this.downloadOptions?.albumID) {
    //       return
    //     }
    //   }
    // } else {
    if (this.downloadState == AlbumDownState.Loading) {
      if (options.albumID == this.downloadOptions?.albumID) {
        return
      }
      this.albumDownQueue.push(options)
      return
    }
    this.downloadOptions = options
    this.total = options.audioList.length
    // 按本地记录继续下载
    const infoList = this.getAllAlbumDownloadHistory()
    this.currentIndex = infoList.find(i => i.albumID == this.downloadOptions?.albumID)?.index || 1

    this.onLoading()
    this.downLoadAudio()
    // }
  }

  private downLoadAudio() {
    const audio = this.downloadOptions!.audioList[this.currentIndex - 1]

    const start: number = audio.audioUrl.lastIndexOf(".")
    const fileName: string = `${audio.audioID}.${audio.audioUrl.substring(start + 1)}`

    const fn = () => {
      DownloadManager.startDownload(audio.audioUrl, fileName, {
        onCompleted: (info, path) => {
          console.log(`--bblog-- 专辑下载 第${this.currentIndex}/${this.total}首成功，${path}`)
          this.onSuccess()
        },
        onProgress: (info) => {
          console.log(`--bblog-- 专辑下载 第${this.currentIndex}/${this.total}首进行中，${info.getProgress()}`)
          // this.onLoading()
        },
        onCanceled: () => {
          console.log(`--bblog-- 专辑下载 第${this.currentIndex}/${this.total}首失败,被取消}`)
          this.onFailed()
        },
        onFailed: (info, err) => {
          console.log(`--bblog-- 专辑下载 第${this.currentIndex}/${this.total}首失败，${JSON.stringify(err)}`)
          showToast(err?.errorMsg || "下载出错")
          this.onFailed()
        }
      })
    }
    fn()
  }

  private onSuccess() {
    if (this.currentIndex == this.total) {
      this.downloadState = AlbumDownState.Success
      this.updateProgress()

      // 重置下载信息
      this.currentIndex = 1

      if (this.albumDownQueue.length > 0) {
        this.startDownload(this.albumDownQueue.shift()!)
      } else {
        this.onPending()
      }
    } else {
      this.updateProgress()
      this.currentIndex++
      if (this.downloadState == AlbumDownState.Paused) {
        return
      }
      this.downLoadAudio()
    }
  }

  private updateProgress() {
    const albumDownloadInfo: AlbumDownloadInfo = {
      albumID: this.downloadOptions?.albumID!,
      index: this.currentIndex,
      total: this.total,
      progress: this.total > 0 ? (this.currentIndex / this.total) : 0,
      state: this.downloadState
    }
    const infoList = this.getAllAlbumDownloadHistory()
    const targetIndex = infoList.findIndex(i => i.albumID == albumDownloadInfo.albumID)
    // 更新本地
    if (targetIndex >= 0) {
      infoList.splice(targetIndex, 1, albumDownloadInfo)
    } else {
      infoList.push(albumDownloadInfo)
    }
    preferences.putSync('myStore', 'albumDownloadInfoList', JSON.stringify(infoList))
    // 待下载的信息打包一起到HashMap，作UI展示用
    if (this.albumDownQueue.length > 0) {
      this.albumDownQueue.forEach(item => {
        infoList.push({
          albumID: item.albumID,
          progress: 0,
          index: 1,
          total: item.audioList.length,
          state: AlbumDownState.Pending
        })
      })
    }
    const infoMap: HashMap<number, AlbumDownloadInfo> = new HashMap()
    infoList.forEach(i => {
      infoMap.set(i.albumID, i)
    })
    AppStorage.setOrCreate('albumDownloadUIState', infoMap)
    // todo：触发器
  }

  private getAllAlbumDownloadHistory(): Array<AlbumDownloadInfo> {
    const albumDownloadInfoListStr: string = preferences.getSync('myStore', "albumDownloadInfoList")
    try {
      if (albumDownloadInfoListStr) {
        const albumDownloadInfoList = JSON.parse(albumDownloadInfoListStr) as AlbumDownloadInfo[]
        return albumDownloadInfoList
      } else {
        return []
      }
    } catch (e) {
      return []
    }
  }

  getUIState(): Array<AlbumDownloadInfo> {
    const tmp: Array<AlbumDownloadInfo> | undefined = AppStorage.get('albumDownloadUIState')
    return tmp == undefined ? [] : tmp
  }

  pause(albumID: number) {
    if (this.downloadOptions?.albumID == albumID) {
      this.onPause()
    } else {
      const target = this.albumDownQueue.findIndex(i => i.albumID == albumID)
      if (target) {
        this.albumDownQueue.splice(target, 1)
      }
    }
  }

  private onFailed() {
    this.downloadState = AlbumDownState.Failed
    this.updateProgress()
  }

  private onLoading() {
    this.downloadState = AlbumDownState.Loading
    this.updateProgress()
  }

  private onPending() {
    this.downloadState = AlbumDownState.Pending
  }

  private onPause() {
    this.downloadState = AlbumDownState.Paused
    this.updateProgress()
  }

  private joinAlbumLocalPath(filename: string, albumID?: number) {
    return `${this.getAlbumLocalPath(albumID)}/${filename}`
  }

  private getAlbumLocalPath(albumID?: number) {
    const filesDir = getContext().filesDir
    const folder = filesDir + `/albumDownload/ablum_${albumID || this.downloadOptions?.albumID}`
    try {
      fs.statSync(folder).isDirectory()
    } catch (e) {
      fs.mkdirSync(folder, true)
    }
    return folder
  }
}

export const albumDownloadManager = new AlbumDownloadManager()