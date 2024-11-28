import { IAlbumDownloadListener } from './IAlbumDownloadListener';
import { AlbumDownloadManagerImpl } from '../core/AlbumDownloadManagerImpl'
import { AlbumDownloadManager } from './AlbumDownloadManager';
import { Album, AlbumDownloadParam } from '../data/AlbumDownloadParam';
import { FileUtil } from '@babyohs/download/src/main/ets/utils/FileUtil'

/**
 *
 */
export class AlbumDownloadBuilder {
  private downloadType: string = AlbumDownloadManager.DLType.DEFAULT
  //专辑内容
  private album?: Album
  // private url?: string
  //保存路径
  private filePath?: string;
  //下载监听
  private downloadListener?: IAlbumDownloadListener;
  private priority: number = 0;

  constructor(downloadType: string) {
    if (!downloadType?.trim()) {
      this.downloadType = AlbumDownloadManager.DLType.DEFAULT;
    } else {
      this.downloadType = downloadType;
    }
  }

  /**
   * 设置专辑
   * @param url
   * @returns
   */
  public setAlbum(album: Album): AlbumDownloadBuilder {
    this.album = album
    return this
  }

  /**
   * 设置优先级
   * @param url
   * @returns
   */
  public setPriority(priority: number): AlbumDownloadBuilder {
    this.priority = priority
    return this
  }

  /**
   * 设置保存路径
   * @param path
   * @param fileName
   * @param suffix
   * @returns
   */
  public setDownloadPath(path: string, fileName: string, suffix: string): AlbumDownloadBuilder {
    if (!fileName?.trim()) {
      this.filePath = path;
    } else if (!suffix?.trim()) {
      this.filePath = FileUtil.joinPaths(path, fileName)
    } else {
      this.filePath = FileUtil.joinPaths(path, fileName + "." + suffix)
    }
    return this
  }

  /**
   * 设置下载监听
   * @param downloadListener
   * @returns
   */
  public setDownloadListener(downloadListener: IAlbumDownloadListener): AlbumDownloadBuilder {
    this.downloadListener = downloadListener
    return this
  }

  /**
   * 开始下载
   */
  public start(): void {
    AlbumDownloadManagerImpl.getInstance()
      .download(new AlbumDownloadParam(this.downloadType, this.album?.id!, this.album?.videos!, this.priority,
        this.album?.title, this.filePath), this.downloadListener);
  }
}