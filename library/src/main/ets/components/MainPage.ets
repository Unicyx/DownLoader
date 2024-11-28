import { AlbumDownloadManager } from '../AlbumDownloadManager';

const albumManager = new AlbumDownloadManager({
  onAlbumStart: (albumId, totalVideos) => {
    console.log(`Starting download for album ${albumId} with ${totalVideos} videos.`);
  },
  onVideoCompleted: (videoUrl) => {
    console.log(`Video completed: ${videoUrl}`);
  },
  onAlbumCompleted: (albumId) => {
    console.log(`Album download completed: ${albumId}`);
  },
  onAlbumFailed: (albumId, error) => {
    console.error(`Album download failed: ${albumId}`, error);
  },
});

albumManager.downloadAlbum("album_1", ["video1_url", "video2_url", "video3_url"]);
