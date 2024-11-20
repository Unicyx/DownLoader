//ToDoList.ets
import { ToDoListItem, ToDo } from './ToDoListItem';

@Entry
@Component
struct ToDoList {
  @State toDoData: ToDo[] = []
  @Watch('onEditModeChange') @State isEditMode: boolean = false
  @State selectedItems: ToDo[] = []
  private availableThings: string[] = ['读书', '运动', '旅游', '听音乐', '看电影', '唱歌']

  onEditModeChange() {
    if (!this.isEditMode) {
      this.selectedItems = []
    }
  }




  build() {

  }
}