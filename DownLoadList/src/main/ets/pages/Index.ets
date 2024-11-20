import { DownLoader } from './Downloader';
import { DownloadTaskManager } from './DownLoadTaskManager';
import { DownloaderListener, NameUrl, Task } from './type';
import { ToDoListItem } from './ToDoListItem';
import { promptAction } from '@kit.ArkUI';

const downloadManager = new DownloadTaskManager()

@Entry
@Component
export struct ToDoList {
  @State tasks: Task[] = []
  @Watch('onEditModeChange') @State isEditMode: boolean = false
  @State selectedItems: Task[] = []
  downLoadUrl: NameUrl[] = [{ name: '450*450', url: 'https://via.placeholder.com/450' },
    { name: 'pdf', url: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf' },
    { name: 'zip', url: 'https://www.sample-videos.com/zip/10mb.zip' },
    { name: 'mp3', url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3' }]

  onEditModeChange() {
    if (!this.isEditMode) {
      this.selectedItems = []
    }
  }

  listener: DownloaderListener = {
    onPending: (url) => console.log(`Download pending for ${url}`),
    onStart: (url) => console.log(`Download started for ${url}`),
    onProgress: (downloaded, total, url) => {
      downloadManager.updateProgress(url, downloaded, total)
      this.renderTasks()
    },
    onCompleted: (url) => {
      console.log(`Download completed for ${url}`)
      downloadManager.completeTask(url);
      this.renderTasks()
    },
    onFailed: (error, url) => {
      console.error(`Download failed for ${url}: ${error.message}`)
      downloadManager.failTask(url)
      this.renderTasks()
    }
  }

  renderTasks() {
    this.tasks = downloadManager.getTasks()
    this.tasks.forEach(task => {
      console.log(`URL: ${task.url}, Progress: ${(task.downloaded / task.total *
        100).toFixed(2)}%, Status: ${task.status}`)
    })
  }

  build() {
    Column() {
      Row() {
        if (this.isEditMode) {
          Text('X')
            .fontSize(20)
            .onClick(() => {
              this.isEditMode = false;
            })
            .margin({ left: 20, right: 20 })
          Blank()
          Button('删除')
            .onClick(() => {
              let delData = this.tasks.filter((item) => {
                return !this.selectedItems.find((selectedItem) => selectedItem == item);
              })
              for (let i of delData) {
                downloadManager.removeTask(i.url)
              }
              this.renderTasks()
              this.isEditMode = false;
            })
        } else {
          Text('下载')
            .fontSize(36)
            .margin({ left: 40 })
          Blank()
          Text('+')
            .fontSize(36)
            .margin({ right: 40 })
            .onClick(() => {
              this.getUIContext().showTextPickerDialog({
                range: this.downLoadUrl.map(tmp => tmp.name),
                onAccept: (value: TextPickerResult) => {
                  let arr = Array.isArray(value.index) ? value.index : [value.index];
                  for (let i = 0; i < arr.length; i++) {

                    const task = this.tasks.find(task => task.url === this.downLoadUrl[arr[i]].url)
                    if (task) {
                      promptAction.showToast({
                        message: '任务已存在'
                      })
                    } else {
                      downloadManager.addTask(this.downLoadUrl[arr[i]].name, this.downLoadUrl[arr[i]].url)
                      const downloader = new DownLoader(this.listener)
                      downloader.downloadFile(this.downLoadUrl[arr[i]].url)
                      this.renderTasks()
                    }
                    // 废弃的
                    // this.tasks.push(new Task(this.downLoadUrl[arr[i]].name, this.downLoadUrl[arr[i]].url));
                    // const downloader = new DownLoader(listener)
                    // downloader.downloadFile(this.downLoadUrl[arr[i]].url)
                  }
                },
              })
            })
        }
      }
      .width("100%")

      List({ space: 10 }) {
        ForEach(this.tasks, (task: Task) => {
          ListItem() {
            ToDoListItem({
              isEditMode: this.isEditMode,
              taskItem: task,
              selectedItems: this.selectedItems
            })
          }
        }, (toDoItem: Task) => toDoItem.key.toString())
      }
      .height("100%")
      .width('100%')
    }
  }
}