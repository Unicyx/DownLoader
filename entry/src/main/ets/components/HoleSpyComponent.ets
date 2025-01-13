import { BuilderNode, ComponentContent, FrameNode, NodeController, window } from "@kit.ArkUI"

interface Controller {
  open: () => void
  close: () => void
}

function getPromptActionDialogController<T extends Object>(builder: WrappedBuilder<[T]>, args: T,
  cancel: Function): Controller {
  let controller: Controller = {
    open: () => void 0,
    close: () => void 0
  }
  controller!.open = () => window.getLastWindow(getContext()).then((windowclass) => {
    const uiContext = windowclass.getUIContext()
    let promptAction = uiContext.getPromptAction();
    let contentNode = new ComponentContent(uiContext, builder, args);

    promptAction.openCustomDialog(contentNode, {
      maskColor: "rgba(0,0,0,0)",
      autoCancel: true,
      transition: TransitionEffect.OPACITY,
      alignment: DialogAlignment.Center,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        cancel()
        dismissDialogAction.dismiss()
      }
    })
    controller.close = () => {
      controller.close = () => void 0
      promptAction.closeCustomDialog(contentNode)
      contentNode.dispose()
    }
  })
  return controller
}

interface PosInfo {
  x_pos: number
  y_pos: number
  radius: number
}

interface Options {
  wrapBuilder?: WrappedBuilder<[]>
  speed?: number
  bgColor?: string
  FPS?: number
}

interface Param extends PosInfo, Options {}

export class HoleSpyController {
  protected controller?: Controller

  open(posInfo: PosInfo, options?: Options) {
    let p = new Promise<boolean>((r, j) => {
      let node = wrapBuilder(Index)
      let param: Param = {
        x_pos: posInfo.x_pos,
        y_pos: posInfo.y_pos,
        radius: posInfo.radius,
      }
      if (options) {
        param.wrapBuilder = options.wrapBuilder
        param.speed = options.speed
        param.bgColor = options.bgColor
        param.FPS = options.FPS
      }
      const cancel = () => {
        // 关闭回调
        r(true)
      }
      this.controller = getPromptActionDialogController(node, param, cancel)
      this.controller.open()
    })
    p.then(() => {
      this.close()
    })
    return p
  }

  close() {
    this.controller?.close()
    this.controller = undefined
  }
}

@Builder
function Index(param: Param) {
  HoleSpyComponent(param)
}

class MyNodeController extends NodeController {
  private rootNode: BuilderNode<[]> | null = null;
  private wrapBuilder: WrappedBuilder<[]>

  constructor(wrapBuilder: WrappedBuilder<[]>) {
    super()
    this.wrapBuilder = wrapBuilder
  }

  makeNode(uiContext: UIContext): FrameNode | null {
    if (this.rootNode === null) {
      this.rootNode = new BuilderNode(uiContext);
      this.rootNode.build(this.wrapBuilder)
    }
    return this.rootNode.getFrameNode();
  }
}

@Component
struct HoleSpyComponent {
  private x_pos: number = 0
  private y_pos: number = 0
  private radius: number = 0
  private wrapBuilder?: WrappedBuilder<[]>
  private speed?: number = 3
  private bgColor?: string | number | CanvasGradient | CanvasPattern = 'rgba(0, 0, 0, 0.3)'
  private FPS?: number = 240
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  //用来创建CanvasRenderingContext2D对象，通过在canvas中调用CanvasRenderingContext2D对象来绘制。
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  build() {
    RelativeContainer() {
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .onReady(() => {
          // 自动适配起始半径
          let i = Math.max(this.context.width - this.x_pos, this.context.height - this.y_pos)
          const fn = () => {
            // 清空画布
            this.context.clearRect(0, 0, this.context.width, this.context.height)
            // 设置回默认属性'source-over'（非常重要）
            this.context.globalCompositeOperation = 'source-over'
            // 绘制底色
            this.context.beginPath()
            this.context.rect(0, 0, this.context.width, this.context.height)
            this.context.fillStyle = this.bgColor!; // 半透明灰色
            this.context.fill()
            // 挖去圆
            this.context.globalCompositeOperation = 'destination-out'
            this.context.beginPath()
            this.context.arc(this.x_pos, this.y_pos, i, 0, Math.PI * 2)
            this.context.fillStyle = 'rgba(0, 0, 0, 1)'
            this.context.fill()
          }
          // 间隔绘制
          let intervalID = setInterval(() => {
            fn()
            i -= this.speed!
            if (i <= this.radius) {
              clearInterval(intervalID)
            }
          }, 1000 / this.FPS!)
        })

      if (this.wrapBuilder) {
        NodeContainer(new MyNodeController(this.wrapBuilder))
          .zIndex(999)
      }
    }
    .width('100%')
    .height('100%')
  }
}