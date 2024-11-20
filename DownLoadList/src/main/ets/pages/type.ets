//ToDo.ets
import { util } from '@kit.ArkTS'

@Observed
export class Task implements NameUrl {
  key: string = util.generateRandomUUID(true);
  name: string = ''
  url: string
  downloaded: number = 0
  total: number = -1
  status?: string

  constructor(name: string, url: string) {
    this.name = name;
    this.url = url
  }
}

export interface NameUrl {
  name: string
  url: string
}


export interface DownloaderListener {
  onPending?: (url: string) => void
  onStart?: (url: string) => void
  onProgress?: (downloaded: number, total: number, url: string) => void
  onCompleted?: (url: string) => void
  onFailed?: (error: Error, url: string) => void
}
