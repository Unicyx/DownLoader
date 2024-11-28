import { BasePersist } from '@babyohs/modulebase';

export class AlbumDownloadInfoSp extends BasePersist{
  private static INSTANCE:AlbumDownloadInfoSp

  public static getInstance():AlbumDownloadInfoSp{
    if(AlbumDownloadInfoSp.INSTANCE == null){
      AlbumDownloadInfoSp.INSTANCE = new AlbumDownloadInfoSp();
    }

    return AlbumDownloadInfoSp.INSTANCE
  }

  getSpName(): string {
    return "dm_download_info";
  }
}