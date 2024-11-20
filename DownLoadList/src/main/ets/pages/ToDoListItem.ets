//ToDoListItem.ets
import { Task } from './type';

@Component
export struct ToDoListItem {
  @Link isEditMode: boolean
  @Link selectedItems: Task[]
  @Prop taskItem: Task

  build() {
    Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      if (this.isEditMode) {
        Checkbox()
          .onChange((isSelected) => {
            if (isSelected) {
              this.selectedItems.push(this.taskItem) // this.selectedItems为勾选时，记录选中的列表项，可根据实际场景构造
            } else {
              let index = this.selectedItems.indexOf(this.taskItem)
              if (index !== -1) {
                this.selectedItems.splice(index, 1) // 取消勾选时，则将此项从selectedItems中删除
              }
            }
          })
      }
      // todo:  展示toDoItem，下载进度
      Text(this.taskItem.name)
      Text(` progress: ${!this.taskItem.total ? '连接中...' :
        `${(this.taskItem.downloaded / this.taskItem.total *
          100).toFixed(2)}% (${this.taskItem.downloaded}/${this.taskItem.total})`}`)
    }
    // .width('100%')
    .height(60)
    .borderRadius(24)
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        LongPressGesture()
          .onAction(() => {
            if (!this.isEditMode) {
              this.isEditMode = true; //进入编辑模式
            }
          })
      )
    )
  }
}