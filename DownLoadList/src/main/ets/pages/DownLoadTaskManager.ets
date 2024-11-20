import { Task } from './type';

export class DownloadTaskManager {
  tasks: Task[] = [];

  addTask(name: string, url: string) {
    this.tasks.push(new Task(name, url))
  }

  updateProgress(url: string, downloaded: number, total: number) {
    const task = this.tasks.find(task => task.url === url)
    if (task) {
      task.downloaded = downloaded
      task.total = total
      task.status = 'progress'
    }
  }

  completeTask(url: string) {
    const task = this.tasks.find(task => task.url === url)
    if (task) {
      task.status = 'completed'
    }
  }

  failTask(url: string) {
    const task = this.tasks.find(task => task.url === url)
    if (task) {
      task.status = 'failed'
    }
  }

  removeTask(url: string) {
    const task = this.tasks.find(task => task.url === url)
    let index = this.tasks.indexOf(task!)
    if (index !== -1) {
      this.tasks.splice(index, 1)
    }
  }

  getTasks() {
    return this.tasks
  }
}