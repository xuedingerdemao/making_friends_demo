import { promptAction, router, window } from '@kit.ArkUI'
import { getCurrentUserInfoAPI } from '../../api/CurrentUserInfo'
import { getRequestMessageAPI } from '../../api/requestMessage'
import { getUserInfoAPI } from '../../api/UserContactInfo'
import LocationMap from '../../components/LocationMap'
import PreviewImageDialog from '../../components/PreviewImageDialog'
import { CurrentUser_Key } from '../../constant/constantStore'
import { MessageInfo, MessageInfoModel, MessageTypeEnum } from '../../modle/MessageInfoModel'
import { UserInfo } from '../../modle/UserInfoModle'
import { AudioCapturerOperate } from '../../StoreClass/AudioCapturerOperate'
import { AudioRendererOperate } from '../../StoreClass/AudioRendererOperate'
import { AVPlayerPStore } from '../../StoreClass/AVPlayerPStore'
import { contactsStore } from '../../StoreClass/ContactsStore'
import { VoiceTransfer } from '../../StoreClass/VoiceTransferStore'
import ChatInput from './Components/ChatInput'
import Message from './Components/Message'

@Entry
@Component
struct UserChatPage {
  //聊天的用户
  @State
  getSendUserTable: UserInfo = {} as UserInfo
  //获取全局状态当前用户
  @StorageProp(CurrentUser_Key)
  currentUserInfo: UserInfo = {} as UserInfo
  @State
  topSafeHeight: number = 0
  @State
  bottomSafeHeight: number = 0
  @State
  messageLists: MessageInfoModel[] = []
  @State
  isShowCurrentContext: boolean = false
  @State
  isShowMoreDel: boolean = false
  scroller: Scroller = new Scroller()
  player: AVPlayerPStore = new AVPlayerPStore()
  previewUrl: string = ""
  showType: MessageTypeEnum = MessageTypeEnum.IMAGE
  //预览弹窗
  PreviewImageDialogController: CustomDialogController = new CustomDialogController({
    builder: PreviewImageDialog({
      url: this.previewUrl,
      showType: this.showType
    }),
    customStyle: true,
    autoCancel: false,
  })

  aboutToAppear(): void {
    this.setFullFn()
    this.getSendUserTableFn()
    //初始化录音采集
    AudioCapturerOperate.init()
    AudioRendererOperate.init()
    //初始化播放器
    this.player.init()
  }

  aboutToDisappear(): void {
    // 释放录音采集
    AudioCapturerOperate.release()
    AudioRendererOperate.release()
  }

  // 沉浸式设置
  async setFullFn() {

    const win = await window.getLastWindow(getContext())
    // 防止全局没开启，指定页面开启沉浸式
    win.setWindowLayoutFullScreen(true)
    win.setWindowLayoutFullScreen(true)
    // 获取上方安全区高度
    this.topSafeHeight = px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
      .topRect.height)
    // 获取下方安全区高度
    this.bottomSafeHeight = px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
      .bottomRect.height)
  }

  getSendUserTableFn() {
    try {
      this.getSendUserTable = router.getParams() as UserInfo
      this.getRecordMessage()

    } catch (e) {
      promptAction.showDialog({
        message: JSON.stringify(e)
      })
    }
  }

  async getRecordMessage() {
    this.messageLists = await contactsStore.getContactMessageStore(this.getSendUserTable.user_id)
    //等数据拿完后渲染再滚，给个延迟或者使用下面的onAppear，渲染完在滚
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom)
    }, 100)
  }

  onSubmitFn(context: string) {
    if (!context) {
      promptAction.showToast({
        message: '不能发空消息'
      })
      return
    }
    const message = new MessageInfoModel({
      sendUser: this.currentUserInfo,
      connectUser: this.getSendUserTable,
      messageContent: context,
    } as MessageInfo)
    this.messageLists.push(message)
    this.player.play('send.wav')
    //存储聊天记录
    contactsStore.addOneContactMessageStore(this.getSendUserTable.user_id, message)

    this.scroller.scrollEdge(Edge.Bottom)

    /*    // 用小艺播出
        VoiceTransfer.textToVoice(context) // 文本转语音播报
    */

    //请求聊天信息
    this.getRequestMessage(context)

  }

  //获取文本聊天信息
  async getRequestMessage(context: string) {
    this.isShowCurrentContext = true
    const res = await getRequestMessageAPI(context)
    this.isShowCurrentContext = false
    const sendMessage = new MessageInfoModel({
      sendUser: this.getSendUserTable,
      connectUser: this.getSendUserTable,
      messageContent: res.data.info.text,
    } as MessageInfo)
    this.player.play('information.wav')
    this.messageLists.push(sendMessage)
    //存储聊天记录
    this.storageMessageFn(this.getSendUserTable.user_id, sendMessage)

    // 用小艺播出
    VoiceTransfer.textToVoice(res?.data?.info?.text) // 文本转语音播报

  }

  //发送语音
  async sendAudioMessage(mess: MessageInfoModel) {
    this.messageLists.push(mess)
    this.player.play('send.wav')

    //存储聊天记录
    this.storageMessageFn(this.getSendUserTable.user_id, mess)
  }

  // 发送图片
  async sendPhotoMessage(messLists: MessageInfoModel[]) {
    this.messageLists.push(...messLists)
    messLists.forEach(item => {
      this.storageMessageFn(this.getSendUserTable.user_id, item)
    })
    this.scroller.scrollEdge(Edge.Bottom)
    this.player.play('send.wav')
  }

  // 存储和某人的聊天信息
  storageMessageFn(userId: string, mess: MessageInfoModel) {
    contactsStore.addOneContactMessageStore(userId, mess)
    this.scroller.scrollEdge(Edge.Bottom)
  }

  //删除某一条消息
  delMessage(messId: string) {
    let idx = this.messageLists.findIndex(item => item.id === messId)
    if (idx > -1) {
      // 删除内存数据
      this.messageLists.splice(idx, 1)
    }
    // 删除仓库磁盘数据
    contactsStore.delOneContactMessageStore(this.getSendUserTable.user_id, messId)
  }

  //多选删除
  delMoreMessage() {

  }

  @Builder
  showMoreMenuBuilder() {
    Row() {

    }
    .width('100%')

    // .height(60)

    // .backgroundColor($r('app.color.start_window_background'))
  }

  build() {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.Start }) {
          Image($r('app.media.ic_public_arrow_left'))
            .width(30)
            .aspectRatio(1)
            .zIndex(2)
            .onClick(() => {
              promptAction.showToast({
                message: '返回'
              })
              router.back()
            })
          Text(`${this.isShowCurrentContext ? '对方正在输入' : this.getSendUserTable.username}`)
            .width('100%')
            .textAlign(TextAlign.Center)
            .fontSize(17)
            .fontColor($r('app.color.text_primary'))
        }
      }
      .padding({
        left: 10,
        right: 10
      })
      .height(60)

      // 聊天窗口
      List({ space: 20, scroller: this.scroller }) {
        ForEach(this.messageLists, (item: MessageInfoModel) => {
          ListItem() {
            Message({
              getSendUserTable: item,
              isOwnSend: this.currentUserInfo.user_id === item.sendUser.user_id,
              isShowMoreDel: this.isShowMoreDel,
              delMessage: () => {
                this.delMessage(item.id)
              },
              delMoreMessage: () => {
                this.isShowMoreDel = true
                this.delMoreMessage()
              },
              //预览
              previewImageOrVideo: () => {
                this.previewUrl = "file://" + item.sourceFilePath
                this.showType = item.messageType
                this.PreviewImageDialogController.open()
              }
            })
            // .onAppear(() => {
            //   this.scroller.scrollEdge(Edge.Bottom)
            // })
          }
        })

      }
      .layoutWeight(1)
      .width('100%')
      .padding({
        top: 10,
        bottom: 10
      })

      //底部按钮
      ChatInput({
        onSubmitFn: (context) => {
          this.onSubmitFn(context)
        },
        sendAudioMessage: (mess) => {
          this.sendAudioMessage(mess)
        },
        sendPhotoMessage: (list) => {
          this.sendPhotoMessage(list)
        },
        getSendUserTable: this.getSendUserTable,

      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      top: this.topSafeHeight,
      bottom: this.bottomSafeHeight
    })
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.back_color'))
    .bindSheet($$this.isShowMoreDel, this.showMoreMenuBuilder, {
      height: 60,
      showClose: false,
    })

  }
}