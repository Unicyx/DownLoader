import { common } from '@kit.AbilityKit';
import fs from '@ohos.file.fs';
import { BusinessError, request } from '@kit.BasicServicesKit';
import { DownloaderListener } from './type';

export class DownLoader {
  context = getContext(this) as common.UIAbilityContext
  filesDir = this.context.filesDir
  listener: DownloaderListener

  constructor(listener: DownloaderListener) {
    this.listener = listener
  }

  downloadFile(url: string): void {
    try {
      this.listener.onPending?.(url)
      const urlParts = url.split('/')
      const fileName = urlParts[urlParts.length - 1] // 获取 URL 的最后一部分作为文件名
      const path = this.context.filesDir + '/' + fileName

      // 判断文件是否存在，存在就删除
      if (fs.accessSync(path)) {
        fs.unlinkSync(path)
      }
      this.listener.onStart?.(url)
      request.downloadFile(this.context, {
        url: url,
        filePath: path
      })
        .then((downloadTask: request.DownloadTask) => {
          downloadTask.on('complete', () => {
            this.listener.onCompleted?.(url)
          })
          downloadTask.on('progress', (downloaded, total) => {
            this.listener.onProgress?.(downloaded, total, url)
          })
        })
        .catch((err: BusinessError) => {
          console.error(`Invoke downloadTask failed, code is ${err.code}, message is ${err.message}`)
        })
    } catch (error) {
      let err: BusinessError = error as BusinessError
      this.listener.onFailed?.(err, url)
    }
  }
}




