import { VoiceTypeEnum } from '../modle/VoiceTypeModle'

@Component
export default struct VoiceInput {
  @Consume
  voiceState: VoiceTypeEnum

  aboutToDisappear(): void {
    this.voiceState = VoiceTypeEnum.RecordIng
  }

  @Builder
  VoiceTipsBuilder() {
    if (this.voiceState === VoiceTypeEnum.Cancel) {
      Row()
        .height(80)
        .width(100)
        .borderRadius(20)
        .backgroundColor($r('app.color.danger'))
        .margin({
          left: 30
        })
    }
    if (this.voiceState === VoiceTypeEnum.RecordIng) {
      Row()
        .height(80)
        .width(180)
        .borderRadius(20)
        .backgroundColor($r('app.color.chat_primary'))
    }

    if (this.voiceState === VoiceTypeEnum.Transfer) {
      Row()
        .height(120)
        .width('100%')
        .borderRadius(20)
        .backgroundColor($r('app.color.chat_primary'))
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {

      Column() {
        this.VoiceTipsBuilder()
        Row() {
          // 上面转换部分
          Column() {
            if (this.voiceState === VoiceTypeEnum.Cancel) {
              Text('松开取消')
                .margin({
                  bottom: 20
                })
                .fontColor($r('app.color.bottom_color'))
            }
            Row() {
              Image($r('app.media.ic_public_cancel'))
                .width(30)
                .height(30)
                .fillColor(this.voiceState === VoiceTypeEnum.Cancel ? $r('app.color.text_primary') : $r('app.color.voice_round_font_color'))

            }
            .backgroundColor(this.voiceState === VoiceTypeEnum.Cancel ? $r('app.color.bottom_color') : $r('app.color.voice_round_color'))
            .width(70)
            .height(70)
            .borderRadius(35)
            .justifyContent(FlexAlign.Center)
            .rotate({
              angle: -10
            })
            .scale({
              x: this.voiceState === VoiceTypeEnum.Cancel ? 1.2 : 1,
              y: this.voiceState === VoiceTypeEnum.Cancel ? 1.2 : 1
            })

          }

          Column() {
            if (this.voiceState === VoiceTypeEnum.Transfer) {
              Text('转文本')
                .margin({
                  bottom: 20
                })
                .fontColor($r('app.color.bottom_color'))
            }
            Row() {
              Text("文")
                .textAlign(TextAlign.Center)
                .fontSize(24)
                .fontColor(this.voiceState === VoiceTypeEnum.Transfer ? $r('app.color.text_primary') : $r('app.color.voice_round_font_color'))
            }
            .backgroundColor(this.voiceState === VoiceTypeEnum.Transfer ? $r('app.color.bottom_color') : $r('app.color.voice_round_color'))
            .width(70)
            .height(70)
            .borderRadius(35)
            .justifyContent(FlexAlign.Center)
            .rotate({
              angle: 10
            })
            .scale({
              x: this.voiceState === VoiceTypeEnum.Transfer ? 1.2 : 1,
              y: this.voiceState === VoiceTypeEnum.Transfer ? 1.2 : 1
            })
          }

        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({
          left: 40,
          right: 40
        })
        .margin({
          top: 30,
          bottom: 30
        })

        Stack() {
          // 底部图片
          Image($r('app.media.ic_public_output'))
            .width('100%')
            .height(120)
            .fillColor(this.voiceState === VoiceTypeEnum.RecordIng ? $r('app.color.bottom_color') : $r('app.color.voice_round_color'))
            .scale({
              x: 1.2
            })
          Image($r('app.media.ic_public_recorder'))
            .width(30)
            .height(30)
            .fillColor(this.voiceState === VoiceTypeEnum.RecordIng ? $r('app.color.bottom_voice_color') : $r('app.color.bottom_color'))

        }
        .height(120)
        .width('100%')
      }
      .justifyContent(FlexAlign.End)
      .alignItems(this.voiceState === VoiceTypeEnum.Cancel ? HorizontalAlign.Start : HorizontalAlign.Center)
      .width('100%')
      .height('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.voice_back_color'))
  }
}