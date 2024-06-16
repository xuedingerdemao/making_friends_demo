import { promptAction, router } from '@kit.ArkUI'
import { AddTopCommonList, AppTitle } from '../modle/AppTitleModle'

@Component
export default struct CommonTop {
  titleName: string = ''
  @State
  addTopCommonList: AppTitle[] = AddTopCommonList
  handleClickAdd: () => void = () => {
  }
  openSearchFn: () => void = () => {
  }

  @Builder
  topMenuBuilder() {
    Column() {
      ForEach(this.addTopCommonList, (item: AppTitle, index) => {
        Row() {
          Image(item.icon).width(20).height(20).margin({ right: 5 })
          Text(item.title).fontSize(20)
        }
        .width('100%')
        .height(30)
        .justifyContent(FlexAlign.Start)
        .align(Alignment.Center)
        .onClick(() => {
          promptAction.showToast({ message: `Menu${index as number + 1} ` })
        })

        if (index != this.addTopCommonList.length - 1) {
          Divider().height(10).width('80%').color('#ccc')
        }

      })
    }

    .padding(5)
    .width(140)
  }

  build() {
    Row() {
      // Blank()
      Stack() {
        Row() {
          Text(this.titleName)
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')

        Row() {
          Blank()
          Image($r('app.media.ic_public_search'))
            .margin({ right: 10 })
            .width(20)
            .aspectRatio(1)
            .onClick(() => {
              this.openSearchFn()
            })
          Image($r('app.media.ic_public_topadd'))
            .width(20)
            .aspectRatio(1)
            .onClick(() => {
              this.handleClickAdd()
            })
            .bindMenu(this.topMenuBuilder, {})
        }
        .justifyContent(FlexAlign.End)
        .width('100%')

      }

    }

    .padding(10)
    .width('100%')
    .backgroundColor($r('app.color.back_color'))
  }
}