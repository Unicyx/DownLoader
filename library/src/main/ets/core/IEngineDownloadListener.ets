import { DownloadError } from '@babyohs/download/src/main/ets/data/DownloadError'

export interface IEngineDownloadListener{
  onStart?:(url:string,totalSize:number) => void
  onProgress?:(url:string,progress:number,totalSize:number,downloadSize:number) => void
  onCompleted:(url:string,totalSize:number) => void
  onFailed?:(url:string,error:DownloadError) => void
  onCanceled?:(url:string) => void
}