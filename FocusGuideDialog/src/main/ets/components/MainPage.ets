import { promptAction } from '@kit.ArkUI'

@Builder
function customDialogBuilder(x: number, y: number, radius: number) {
  Column() {

  }
  .width('100%')
  .height('100%')
  .backgroundColor(Color.Gray)
}


export class FocusGuideDialog {
  x: number = 0
  y: number = 0
  radius: number = 0
  customDialogId: number = 0

  // customDialogComponent() {
  //   customDialogBuilder(this.x, this.y, this.radius)
  // }

  show() {
    promptAction.openCustomDialog({
      builder: () => {
        // this.customDialogComponent()
        customDialogBuilder(this.x, this.y, this.radius)
      },
      width: '100%',
      height: '100%',
    }).then((dialogId: number) => {
      this.customDialogId = dialogId
    })
  }

  close() {
    promptAction.closeCustomDialog(this.customDialogId)
  }
}