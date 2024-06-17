import { VoiceTypeEnum } from '../modle/VoiceTypeModle'
import { emitter } from '@kit.BasicServicesKit'

@Preview
@Component
export default struct VoiceInput {
  @Consume
  voiceState: VoiceTypeEnum
  @Link
  arsString: string
  @State
  list: number[] = [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20]

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
    } else if (this.voiceState === VoiceTypeEnum.RecordIng) {
      // 正在录音
      Row({ space: 2 }) {
        //显示波峰
        ForEach(this.list, (value: number) => {
          Row()
            .height(value)
            .width(2)
            .borderRadius(1)
            .backgroundColor($r("app.color.animate_voice_color"))
        })
      }
      .justifyContent(FlexAlign.Center)
      .width(180)
      .height(80)
      .borderRadius(20)
      .backgroundColor($r("app.color.chat_primary"))
    }
    //语音转文本
    else if (this.voiceState === VoiceTypeEnum.Transfer) {
      Row() {
        Text(this.arsString)
          .fontSize(20)
          .fontColor($r("app.color.text_primary"))
      }
      .alignItems(VerticalAlign.Top)
      .padding(10)
      .height(120)
      .width(280)
      .borderRadius(20)
      .backgroundColor($r('app.color.chat_primary'))
    }
  }

  /*-------------------------function ⬇⬇---------------------------------------------------*/
  aboutToDisappear(): void {
    this.voiceState = VoiceTypeEnum.RecordIng
    emitter.on("onBuffer", (res: emitter.EventData) => {
      this.calcHeight(res.data!.buffer)
    })
  }

  // 计算波峰  算出30个高度给list
  calcHeight(buffer: ArrayBuffer) {
    // buffer的长度不确定 1280 / 30 算出每个份里面的平均值 / 最大值 比例-高度 =》 高度
    // 做一个转化 将buffer转化成DataView类型
    const view = new DataView(buffer) // 转成view类型
    const arr: number[] = []
    const size = Math.floor(buffer.byteLength / 20) // 分二十份，每份的大小
    // 循环三十次
    for (let index = 0; index < buffer.byteLength; index += size) {
      let sum = 0
      // 计算每一份里面的振幅的平均值
      for (let index2 = index; index2 < index + size; index2 += 2) {
        // 每个buffer算做两个字节
        // 取值 16bit值
        const sample = view.getInt16(index2, true) // 只是一份样本 要的样本的综合
        sum += Math.abs(sample)
      }
      const height = 120 * sum / (size / 2) / 32767 // 比例  某一份的高度
      arr.push(height < 10 ? 10 : height) // 最终就是30份的高度
    }
    this.list = arr // 赋值高度


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
                .fillColor(this.voiceState === VoiceTypeEnum.Cancel ? $r('app.color.text_primary') :
                $r('app.color.voice_round_font_color'))

            }
            .backgroundColor(this.voiceState === VoiceTypeEnum.Cancel ? $r('app.color.bottom_color') :
            $r('app.color.voice_round_color'))
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
                .fontColor(this.voiceState === VoiceTypeEnum.Transfer ? $r('app.color.text_primary') :
                $r('app.color.voice_round_font_color'))
            }
            .backgroundColor(this.voiceState === VoiceTypeEnum.Transfer ? $r('app.color.bottom_color') :
            $r('app.color.voice_round_color'))
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
            .fillColor(this.voiceState === VoiceTypeEnum.RecordIng ? $r('app.color.bottom_color') :
            $r('app.color.voice_round_color'))
            .scale({
              x: 1.2
            })
          Image($r('app.media.ic_public_recorder'))
            .width(30)
            .height(30)
            .fillColor(this.voiceState === VoiceTypeEnum.RecordIng ? $r('app.color.bottom_voice_color') :
            $r('app.color.bottom_color'))

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