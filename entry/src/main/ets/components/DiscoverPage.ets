@Component
export default struct Discover {
  renderList: string[] = ["朋友圈", "视频号", "直播", "扫一扫", "摇一摇", "看一看", "搜一搜", "附近", "购物", "游戏", "小程序"]

  @Builder
  getRenderItem(left: string, rightClick?: () => void) {
    Row() {
      Row({ space: 5 }) {
        Image($r("app.media.ic_public_contacts_group"))
          .width(16)
          .height(16)
        Text(left)
      }

      Image($r("app.media.ic_public_right"))
        .width(16)
        .height(16)
    }
    .width('100%')
    .padding({
      left: 20,
      right: 20
    })
    .backgroundColor($r("app.color.white"))
    .height(60)
    .justifyContent(FlexAlign.SpaceBetween)
    .border({
      color: $r("app.color.border_color"),
      width: {
        bottom: 0.5
      }
    })
  }

  build() {
    Column() {

      Scroll() {
        Column() {
          // 顶部
          ForEach(this.renderList, (item: string, index) => {
            this.getRenderItem(item)
            if (index === 1 || index === 7) {
              Row().height(10)
            }
          })

        }
      }
      .layoutWeight(1)

    }
    .layoutWeight(1)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.back_color'))
  }
}

