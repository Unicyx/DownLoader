@Entry
@Component
struct Index {
  build() {
    Row() {
      RelativeContainer() {
        Row(){Text('row1')}.justifyContent(FlexAlign.Center).width(100).height(100)
        .backgroundColor("#FF3333")
        .alignRules({
          top: {anchor: "__container__", align: VerticalAlign.Top},
          left: {anchor: "__container__", align: HorizontalAlign.Start}
        })
        .id("row1")

        Row(){Text('row2')}.justifyContent(FlexAlign.Center).width(100)
        .backgroundColor("#FFCC00")
        .alignRules({
          top: {anchor: "__container__", align: VerticalAlign.Top},
          right: {anchor: "__container__", align: HorizontalAlign.End},
          bottom: {anchor: "row1", align: VerticalAlign.Center},
        })
        .offset({
          x:-40,
          y:-20
        })
        .id("row2")

        Row(){Text('row3')}.justifyContent(FlexAlign.Center).height(100)
        .backgroundColor("#FF6633")
        .alignRules({
          top: {anchor: "row1", align: VerticalAlign.Bottom},
          left: {anchor: "row1", align: HorizontalAlign.End},
          right: {anchor: "row2", align: HorizontalAlign.Start}
        })
        .offset({
          x:-10,
          y:-20
        })
        .id("row3")

        Row(){Text('row4')}.justifyContent(FlexAlign.Center)
        .backgroundColor("#FF9966")
        .alignRules({
          top: {anchor: "row3", align: VerticalAlign.Bottom},
          bottom: {anchor: "__container__", align: VerticalAlign.Bottom},
          left: {anchor: "__container__", align: HorizontalAlign.Start},
          right: {anchor: "row1", align: HorizontalAlign.End}
        })
        .offset({
          x:-10,
          y:-30
        })
        .id("row4")

        Row(){Text('row5')}.justifyContent(FlexAlign.Center)
        .backgroundColor("#FF66FF")
        .alignRules({
          top: {anchor: "row3", align: VerticalAlign.Bottom},
          bottom: {anchor: "__container__", align: VerticalAlign.Bottom},
          left: {anchor: "row2", align: HorizontalAlign.Start},
          right: {anchor: "row2", align: HorizontalAlign.End}
        })
        .offset({
          x:10,
          y:20
        })
        .id("row5")

        Row(){Text('row6')}.justifyContent(FlexAlign.Center)
        .backgroundColor('#ff33ffb5')
        .alignRules({
          top: {anchor: "row3", align: VerticalAlign.Bottom},
          bottom: {anchor: "row4", align: VerticalAlign.Bottom},
          left: {anchor: "row3", align: HorizontalAlign.Start},
          right: {anchor: "row3", align: HorizontalAlign.End}
        })
        .offset({
          x:-15,
          y:10
        })
        .backgroundImagePosition(Alignment.Bottom)
        .backgroundImageSize(ImageSize.Cover)
        .id("row6")
      }
      .width(300).height(300)
      .margin({left: 50})
      .border({width:2, color: "#6699FF"})
    }
    .height('100%')
  }
}