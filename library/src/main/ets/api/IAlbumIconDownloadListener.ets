export interface IAlbumIconDownloadListener {
  onStart: () => void
  onCompleted: (success: boolean) => void
}