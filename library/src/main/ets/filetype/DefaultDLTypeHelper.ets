import { AlbumDownloadManager } from '../api/AlbumDownloadManager';
import { Constants } from '../const/Constants';
import { AlbumDownloadParam } from '../data/AlbumDownloadParam';
import { BaseDLTypeHelper } from './BaseDLTypeHelper';

export class DefaultDLTypeHelper extends BaseDLTypeHelper {
  getDownloadId(param: AlbumDownloadParam): string {
    if (param.id) {
      return param.id
    }
    return ""
  }

  getFilePath(param: AlbumDownloadParam): string {
    if (param.path) {
      return param.path
    }
    return Constants.getCachePath(this.getDownloadId(param));
  }

  getDownloadType(): string {
    return AlbumDownloadManager.DLType.DEFAULT;
  }
}