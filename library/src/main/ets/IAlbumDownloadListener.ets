import { DownloadError } from '@babyohs/download';

export interface IAlbumDownloadListener {
  onAlbumStart?: (albumId: string, totalTracks: number) => void;
  onVideoCompleted?: (trackUrl: string) => void;
  onAlbumCompleted?: (albumId: string) => void;
  onAlbumFailed?: (albumId: string, error: DownloadError) => void;
}