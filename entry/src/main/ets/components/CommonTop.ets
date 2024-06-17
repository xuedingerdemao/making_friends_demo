import { promptAction, router } from '@kit.ArkUI'
import { AddTopCommonList, AppTitle } from '../modle/AppTitleModle'
import { homePagePopup, PopupItem } from '../modle/PopupModle'
import { scanBarcode, scanCore, } from '@kit.ScanKit';

@Component
export default struct CommonTop {
  titleName: string = ''
  @State
  addTopCommonList: AppTitle[] = AddTopCommonList
  @State
  popList: PopupItem[] = homePagePopup
  @State
  isShowDropDown: boolean = false // 显示底部浮层
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

  //弹层指示
  @Builder
  getDropDown() {
    Column() {
      ForEach(this.popList, (item: PopupItem) => {
        Row() {
          Image(item.icon)
            .fillColor($r('app.color.white'))
            .width(20)
            .height(20)
          Text(item.title)
            .fontColor(Color.White)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }
        .width('90%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .padding({
          left: 10,
          right: 10
        })
        .onClick(() => {
          if (item.id === 'scan') {
            this.scan()
          } else if (item.id === 'pay') {
            router.pushUrl({
              url: 'PageComponents/PayQrCodePage'
            })
          }
        })

      })
    }
    .width(150)
  }

  // 扫码
  async scan() {
    // 定义扫码参数options
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: true,
      enableAlbum: true
    };
    // 启动扫码，拉起扫码界面
    try {
      const result = await scanBarcode.startScanForResult(getContext(this), options)
      // 判断值 网址 参数
      AlertDialog.show({
        message: result.originalValue
      })
    } catch (error) {
      promptAction.showToast({ message: error.message })
    }
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
            .margin({ right: 12 })
            .width(20)
            .aspectRatio(1)
            .onClick(() => {
              this.handleClickAdd()
            })//弹层
            .bindPopup(this.isShowDropDown, {
              builder: this.getDropDown,
              placement: Placement.Bottom,
              arrowPointPosition: ArrowPointPosition.END,
              onStateChange: (event) => {
                this.isShowDropDown = event.isVisible
              },
              popupColor: $r("app.color.popup_back"),
              backgroundBlurStyle: BlurStyle.NONE
            })
            .onClick(() => {
              this.isShowDropDown = true
            })
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