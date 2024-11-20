import { common } from '@kit.AbilityKit';
import fs from '@ohos.file.fs';
import { BusinessError, request } from '@kit.BasicServicesKit';
import { buffer } from '@kit.ArkTS';
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
      // 判断文件是否存在，存在就删除
      let path = this.context.filesDir + '/test.png'
      if (fs.accessSync(path)) {
        fs.unlinkSync(path)
      }
      this.listener.onStart?.(url)
      request.downloadFile(this.context, {
        url: url,
        filePath: this.filesDir + '/test.png'
      })
        .then((downloadTask: request.DownloadTask) => {
          downloadTask.on('complete', () => {
            this.listener.onCompleted?.(url)
            let file = fs.openSync(this.filesDir + '/test.png', fs.OpenMode.READ_WRITE)
            let arrayBuffer = new ArrayBuffer(1024)
            let readLen = fs.readSync(file.fd, arrayBuffer)
            let buf = buffer.from(arrayBuffer, 0, readLen)

            fs.closeSync(file)
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




