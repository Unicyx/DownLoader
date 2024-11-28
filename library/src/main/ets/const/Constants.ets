import { FileUtils, Md5, PathUtils } from '@babyohs/utils'
import { FileUtil } from '@babyohs/download/src/main/ets/utils/FileUtil'
import { BBHelper } from '@babyohs/modulebase';

export namespace Constants {

  let CachePath: string
  /**
   * 下载缓存路径
   * @param id
   * @returns
   */
  export function getCachePath(id: string) {
    let rootPath = BBHelper.getContext().getApplicationContext().cacheDir
    if (!CachePath) {
      CachePath = FileUtil.joinPaths(rootPath, "BBDownload/Cache/")
    }
    if (!FileUtils.getInstance().existFolder(CachePath)) {
      FileUtils.getInstance().createFolder(FileUtil.joinPaths(rootPath, "BBDownload/"))
      FileUtils.getInstance().createFolder(CachePath)
    }
    let suffix = getSuffix(id)
    return FileUtil.joinPaths(CachePath, Md5.hashStr(id)) + suffix
  }

  function getSuffix(id: string): string {
    // 用 '/' 将路径分割成段
    const segments = id.split('/');

    // 获取最后一个段（文件名）
    const fileName = segments[segments.length - 1];

    // 使用 '.' 将文件名分割成段并提取扩展名
    const fileSegments = fileName.split('.');

    // 获取并返回扩展名
    let suffix = fileSegments[fileSegments.length - 1];
    if (suffix.length > 4) {
      return ""
    }
    return "." + suffix;
  }
}