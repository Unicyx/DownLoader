import { DownloadError, DownloadManager, IDownloadListener } from '@babyohs/download';

import { IAlbumDownloadListener } from './IAlbumDownloadListener';
import { common } from '@kit.AbilityKit';

export class AlbumDownloadManager {
  private listener?: IAlbumDownloadListener;
  private videoListener?: IDownloadListener

  constructor(listener?: IAlbumDownloadListener) {
    this.listener = listener;
  }

  public async downloadAlbum(albumId: string, videoUrls: string[]) {
    this.listener?.onAlbumStart?.(albumId, videoUrls.length);

    for (const videoUrl of videoUrls) {
      try {
        await this.downloadVideo(videoUrl);
        this.listener?.onVideoCompleted?.(videoUrl);
      } catch (error) {
        this.listener?.onAlbumFailed?.(albumId, new DownloadError("-1", "Video download failed"));
        return;
      }
    }

    this.listener?.onAlbumCompleted?.(albumId);
  }

  private async downloadVideo(videoUrl: string) {
    const context = getContext(this) as common.UIAbilityContext
    const urlParts = videoUrl.split('/')
    const fileName = urlParts[urlParts.length - 1] // 获取 URL 的最后一部分作为文件名
    const filePath = context.filesDir + '/' + fileName

    DownloadManager.startDownload(videoUrl, filePath, this.videoListener)
  }
}