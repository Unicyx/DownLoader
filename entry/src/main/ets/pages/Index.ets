import { HoleSpyController } from '../components/HoleSpyComponent'
import { promptAction } from '@kit.ArkUI'
import { AlignCenterRight, AlignTopRight } from '@babyohs/globaldata'

const holeSpyController = new HoleSpyController()

@Builder
function builder() {
  RelativeContainer() {
    Button('X')
      .type(ButtonType.Circle)
      .alignRules(AlignCenterRight)
      .onClick(() => {
        holeSpyController.close()
      })
  }
  .width('100%')
  .height('100%')
}

@Entry
@Component
struct Index {
  build() {
    Column() {
      Text('test')
        .onClick(() => {
          holeSpyController.open({
            x_pos: 200,
            y_pos: 200,
            radius: 50
          },
            {
              wrapBuilder: wrapBuilder(builder),
              bgColor: 'rgba(0,0,0,0.7)',
              speed: 10
            })
        })
        .textAlign(TextAlign.Center)
        .width('100%')
        .fontSize(30)
      Button('能否点击')
        .onClick(() => {
          promptAction.showToast({ message: '点击成功' })
        })
      Text('test`')
        .onClick(() => {
          holeSpyController.open({
            x_pos: 200,
            y_pos: 300,
            radius: 150
          }, {
            wrapBuilder: wrapBuilder(builder)
          })
        })
        .textAlign(TextAlign.Center)
        .width('100%')
        .fontSize(30)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Gray)
    .justifyContent(FlexAlign.SpaceEvenly)
  }
}