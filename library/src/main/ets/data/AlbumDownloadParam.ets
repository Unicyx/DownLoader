export interface Video {
  id: string
  title: string
  url: string
}

export interface Album {
  id: string
  title?: string
  videos: Video[]
}

export class AlbumDownloadParam implements Album {
  downloadType: string
  id: string
  title?: string
  videos: Video[]
  path?: string
  priority: number
  customParam?: object
  finalUrls?: string[]
  finalPath?: string

  constructor(downloadType: string, id: string, videos: Video[], priority: number = 0, title?: string, path?: string,
    customParam?: object) {
    this.downloadType = downloadType
    this.id = id
    this.title = title
    this.videos = videos
    this.priority = priority
    this.customParam = customParam
    this.path = path
  }
}