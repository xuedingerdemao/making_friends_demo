import { router } from '@kit.ArkUI'
import { generateBarcode, scanCore } from '@kit.ScanKit'

@Entry
@Component
struct PayQrCode {
  @State
  payParams: string = Math.random().toString()
  timer: number = -1 // 用来记录伦序
  @State
  barCodeImage: PixelMap | null = null // 条形码的图形对象

  aboutToAppear(): void {
    this.createQrCodeValue() // 二维码
    this.createBarCode() // 条形码
  }

  aboutToDisappear(): void {
    clearInterval(this.timer)
  }

  createQrCodeValue() {
    this.timer = setInterval(() => {
      this.payParams = Math.random().toString()
    }, 10000)
  }

  async createBarCode() {
    // 创建二维码也可以
    this.barCodeImage = await generateBarcode.createBarcode(this.payParams, {
      scanType: scanCore.ScanType.CODE128_CODE,
      height: 200, // 像素值
      width: 800 // 像素值
    })
  }

  build() {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.Start }) {
          Image($r('app.media.ic_public_arrow_left'))
            .width(30)
            .height(30)
            .fillColor($r("app.color.white"))
            .onClick(() => {
              router.back()
            })
            .zIndex(2)

          Text("收付款")
            .width('100%')
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .fontColor($r('app.color.white'))
        }
        .height(50)
      }
      .padding({
        left: 10,
        right: 10
      })

      Row() {
        Column() {
          Row({ space: 10 }) {
            Image($r("app.media.ic_public_scan"))
              .width(20)
              .height(20)
              .fillColor($r("app.color.pay_back"))
            Text("付款码")
              .fontColor($r("app.color.pay_back"))
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .height(60)
          .border({
            width: {
              bottom: 0.5
            },
            color: $r("app.color.border_color")
          })

          // PixelMap可以显示在Image组件上
          Image(this.barCodeImage)
            .width(280)
            .height(100)
          // 显示码
          Column({ space: 20 }) {
            Text("优先使用xx银行储蓄卡付款")
              .fontColor($r("app.color.text_second"))
              .fontSize(12)

            Image($r('app.media.QRcode'))
              .width(140)
              .aspectRatio(1)
            // QRCode(this.payParams)
            //   .width(140)
            //   .height(140)
          }
          .margin({
            top: 10,
            bottom: 10
          })
        }
        .padding(10)
        .borderRadius(4)
        .width("100%")
        .backgroundColor($r("app.color.white"))
      }
      .padding({
        left: 10,
        right: 20
      })

    }
    .width('100%')
    .height('100%')
    .backgroundColor($r("app.color.pay_back"))
  }
}
