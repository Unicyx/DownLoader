import { BasePersist } from '@babyohs/modulebase';

// Filepath --> Id
export class AlbumDownloadFilePathSp extends BasePersist{
  private static INSTANCE:AlbumDownloadFilePathSp

  public static getInstance():AlbumDownloadFilePathSp{
    if(AlbumDownloadFilePathSp.INSTANCE == null){
      AlbumDownloadFilePathSp.INSTANCE = new AlbumDownloadFilePathSp();
    }

    return AlbumDownloadFilePathSp.INSTANCE
  }

  getSpName(): string {
    return "dm_download_info_filePath";
  }
}