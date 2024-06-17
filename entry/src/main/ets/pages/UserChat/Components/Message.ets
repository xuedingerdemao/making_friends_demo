import { CurrentUser_Key } from '../../../constant/constantStore'
import { MessageInfo, MessageInfoModel, MessageTypeEnum } from '../../../modle/MessageInfoModel'
import { UserInfo } from '../../../modle/UserInfoModle'
import { promptAction } from '@kit.ArkUI'
import { PopupItem, popupList } from '../../../modle/PopupModle'
import { AudioRendererOperate } from '../../../StoreClass/AudioRendererOperate'
import { FileOperate } from '../../../StoreClass/FileOperate'
import { AVPlayerPStore } from '../../../StoreClass/AVPlayerPStore'
import { VoiceTransfer } from '../../../StoreClass/VoiceTransferStore'

@Preview
@Component
export default struct Message {
  @StorageProp(CurrentUser_Key)
  currentUserInfo: UserInfo = {} as UserInfo
  getSendUserTable: MessageInfoModel = new MessageInfoModel({} as MessageInfo)
  isOwnSend: boolean = false
  @State
  isShowPopup: boolean = false
  @State
  popupLists: PopupItem[] = popupList
  @Link
  isShowMoreDel: boolean
  @State
  isSelectMore: boolean = false
  audioState: AnimationStatus = AnimationStatus.Initial
  videoController: VideoController = new VideoController() // 视频controllergetAudioContent
  @State
  transferResult: string = "" // 用来记录语音变量转化的文字
  delMessage: () => void = () => {
  }
  delMoreMessage: () => void = () => {
  }
  previewImageOrVideo: () => void = () => {
  }

  @Builder
  popupBuilder() {
    GridRow({ columns: 5 }) {
      ForEach(this.popupLists, (item: PopupItem) => {
        GridCol() {
          Column({ space: 6 }) {
            Image(item.icon)
              .fillColor($r("app.color.white"))
              .width(18)
              .height(18)
            Text(item.title)
              .fontColor($r("app.color.white"))
              .fontSize(14)
          }
          .height(60)
        }
        .onClick(() => {
          if (item.id === 'del') {
            this.showAlertDialogFn()
            return
          }
          if (item.id === 'more') {

            this.delMoreMessage()
          }
          if (item.id === 'literal') {
            VoiceTransfer.VoiceToText(this.getSendUserTable.sourceFilePath, (res) => {
              this.transferResult = res.result // 拿到转化的文字
            })
          }
        })
      })
    }
    .width(300)
    .padding({
      top: 15,
      left: 10
    })
  }

  // 二级弹窗
  showAlertDialogFn() {
    this.isShowPopup = false
    AlertDialog.show(
      {
        message: '确定删除？',
        autoCancel: true,
        alignment: DialogAlignment.Center,

        primaryButton: {
          value: '确认',
          fontColor: Color.Black,
          action: () => {
            promptAction.showToast({ message: '确认' })
            if (this.getSendUserTable.sourceFilePath) {
              FileOperate.delFilePath(this.getSendUserTable.sourceFilePath)
            }
            this.delMessage()


          }
        },
        secondaryButton: {
          value: '取消',
          fontColor: Color.Red,
          action: () => {
            promptAction.showToast({ message: '取消' })
          }
        },
      })

  }

  // 获取语音宽度
  getAudioWidth() {
    let minWidth: number = 20
    let maxWidth: number = 90
    let calWidth: number = minWidth + (100 * this.getSendUserTable.sourceDuration / 60)
    if (calWidth > maxWidth) return maxWidth + "%"
    return calWidth + "%"
  }

  // 获取文本消息
  @Builder
  getTextContent() {
    Row() {
      Text(this.getSendUserTable.messageContent)
        .backgroundColor(this.isOwnSend ? $r('app.color.second_primary') : $r('app.color.white'))
        .fontColor($r('app.color.text_primary'))
        .padding(10)
        .lineHeight(24)
        .margin({
          left: 10,
          right: 10
        })
        .borderRadius(5)
    }
  }

  // 获取语音显示
  @Builder
  getAudioContent() {
    Row({ space: 5 }) {
      Text(`${this.getSendUserTable.sourceDuration}'`)
        .textAlign(TextAlign.Center)
      ImageAnimator()
        .images([
          {
            src: $r("app.media.ic_public_voice3")
          },
          {
            src: $r("app.media.ic_public_voice1")
          },
          {
            src: $r("app.media.ic_public_voice2")
          },
          {
            src: $r("app.media.ic_public_voice3")
          }
        ])
        .iterations(-1)
        .state(this.audioState)
        .fillMode(FillMode.None)
        .width(20)
        .height(20)
        .rotate({
          angle: this.currentUserInfo.user_id === this.getSendUserTable.sendUser.user_id ? 180 : 0
        })
    }
    .width(this.getAudioWidth())
    .backgroundColor(this.currentUserInfo.user_id === this.getSendUserTable.sendUser.user_id ? $r('app.color.chat_primary') : $r('app.color.white'))
    .justifyContent(this.currentUserInfo.user_id === this.getSendUserTable.sendUser.user_id ? FlexAlign.End : FlexAlign.Start)
    .height(40)
    .padding({
      left: 10,
      right: 10
    })
    .margin({
      left: 10,
      right: 10
    })
    .borderRadius(4)
    .direction(this.currentUserInfo.user_id === this.getSendUserTable.sendUser.user_id ? Direction.Ltr : Direction.Rtl)
    .onClick(() => {
      AudioRendererOperate.start(this.getSendUserTable.sourceFilePath, () => {
        this.audioState = AnimationStatus.Stopped
      })
      this.audioState = AnimationStatus.Running
    })

    if (this.transferResult) {
      Text(this.transferResult)
        .backgroundColor(this.currentUserInfo.user_id === this.getSendUserTable.sendUser.user_id ? $r("app.color.second_primary") : $r("app.color.white"))
        .fontColor($r("app.color.text_primary"))
        .padding(10)
        .margin({
          left: 10,
          right: 10
        })
        .borderRadius(4)

    }
  }

  // 获取图片显示
  @Builder
  getImageContent() {
    Column() {
      Image("file://" + this.getSendUserTable.sourceFilePath)
        .borderRadius(4)
        .width('100%')
        .enabled(false) //处理图片的一些动效，防止Popup出不来的情况
    }
    .width('40%')
    .margin({
      left: 10,
      right: 10
    })
    .onClick(() => {
      this.previewImageOrVideo()
    })

  }

  @Builder
  getVideoContent() {
    Column() {
      Stack() {
        Video({
          src: "file://" + this.getSendUserTable.sourceFilePath,
          controller: this.videoController
        })
          .id(this.getSendUserTable.id)
          .width(100)
          .height(150)
          .controls(false)
          .borderRadius(4)
          .onPrepared(() => {
            this.videoController.setCurrentTime(0.1) // 拨到0.1的位置  出现首帧图片了
            // 截图能力
            // HMS的解析封面
            // componentSnapshot.get(this.getSendUserTable.id)
          })

        Image($r("app.media.ic_public_play"))
          .width(30)
          .height(30)
          .fillColor($r("app.color.back_color"))
      }
    }
    .margin({
      left: 10,
      right: 10
    })
    .onClick(() => {
      this.previewImageOrVideo()
    })
  }

  build() {
    Row() {
      if (this.isShowMoreDel) {
        Checkbox()
          .select($$this.isSelectMore)
          .selectedColor('#75a143')
      }
      Image(this.getSendUserTable.sendUser.avatar)
        .height(40)
        .width(40)
        .borderRadius(6)
      //消息
      Row() {
        Column() {
          if (this.getSendUserTable.messageType === MessageTypeEnum.TEXT) {
            // 文字
            this.getTextContent()
          }
          else if (this.getSendUserTable.messageType === MessageTypeEnum.AUDIO) {
            // 语音
            this.getAudioContent()
          }
          else if (this.getSendUserTable.messageType === MessageTypeEnum.IMAGE) {
            //图片
            this.getImageContent()
          }
          else if (this.getSendUserTable.messageType === MessageTypeEnum.VIDEO) {
            // 视频
            this.getVideoContent()
          }
        }
        .bindPopup(this.isShowPopup, {
          builder: this.popupBuilder,
          popupColor: $r("app.color.popup_back"),
          placementOnTop: true, //是否在组件上方显示，默认false
          backgroundBlurStyle: BlurStyle.NONE,
          onStateChange: (event) => {
            // 当手指点了其他位置 关闭状态
            this.isShowPopup = event.isVisible
          }
        })

      }.layoutWeight(6)
      .justifyContent(this.isOwnSend ? FlexAlign.End : FlexAlign.Start)
      .gesture(
        LongPressGesture()
          .onAction(() => {
            this.isShowPopup = true
          })
      )

      Text().layoutWeight(1)
    }
    .width('100%')
    .padding({
      left: 20,
      right: 20
    })
    .alignItems(VerticalAlign.Top)
    .direction(this.isOwnSend ? Direction.Rtl : Direction.Ltr)
  }
}