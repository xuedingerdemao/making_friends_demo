import { MessageTypeEnum } from '../modle/MessageInfoModel'

@CustomDialog
export default struct PreviewImageDialog {
  controller: CustomDialogController
  url: string = ""
  showType: MessageTypeEnum = MessageTypeEnum.IMAGE

  build() {
    Column() {
      if (this.showType === MessageTypeEnum.IMAGE) {
        Image(this.url)
          .width('100%')
      }
      if (this.showType === MessageTypeEnum.VIDEO) {
        Video({ src: this.url })
          .autoPlay(true)
          .loop(true)
          .controls(false)
          .width('100%')
          .height("100%")
      }
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height("100%")
    .onClick(() => {
      this.controller.close()
    })
    .backgroundColor($r("app.color.black"))
  }
}