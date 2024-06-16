import { AddTopCommonList, AppTitle } from '../modle/AppTitleModle'
import { promptAction } from '@kit.ArkUI'

@Preview
@Component
export default struct StartTipsDialog {
  addTopCommonList: AppTitle[] = AddTopCommonList
  // 添加联系人
  addContactsFn: () => void = () => {
  }

  build() {
    Column({ space: 10 }) {
      ForEach(this.addTopCommonList, (item: AppTitle) => {
        Row({ space: 5 }) {
          Image(item.icon)
            .width(20)
            .aspectRatio(1)
            .fillColor($r('app.color.popup_icon'))
          Text(item.title)
            .fontSize(14)
            .fontColor($r('app.color.popup_text'))
        }
        .width('100%')
        .onClick(() => {
          promptAction.showToast({
            message: item.title
          })
        })
      })
    }
    .justifyContent(FlexAlign.Center)
    .padding(10)
    .width(120)
    .borderRadius(8)
    .backgroundColor($r('app.color.popup_back'))
  }
}