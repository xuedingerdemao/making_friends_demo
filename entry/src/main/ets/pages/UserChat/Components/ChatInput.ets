import { display, promptAction } from '@kit.ArkUI';
import VoiceInput from '../../../components/VoiceInput';
import { VoiceTypeEnum } from '../../../modle/VoiceTypeModle';
import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import { FileOperate } from '../../../StoreClass/FileOperate';
import { CurrentUser_Key } from '../../../constant/constantStore';
import { UserInfo } from '../../../modle/UserInfoModle';
import { AudioCapturerOperate } from '../../../StoreClass/AudioCapturerOperate';
import { MessageInfo, MessageInfoModel, MessageTypeEnum } from '../../../modle/MessageInfoModel';
import { bottomPopup, PopupItem } from '../../../modle/PopupModle';
import { fileIo, picker } from '@kit.CoreFileKit';
import cameraPicker from '@ohos.multimedia.cameraPicker'
import camera from '@ohos.multimedia.camera'
import LocationMap from '../../../components/LocationMap';

@Preview
@Component
export default struct ChatInput {
  @State
  isShowKeyBoard: boolean = false
  @State
  context: string = ''
  @State
  isShowPopup: boolean = false
  @State
  isShowVoiceInput: boolean = false
  @State
  screenWidth: number = 0
  @State
  screenHeight: number = 0
  @Provide
  voiceState: VoiceTypeEnum = VoiceTypeEnum.RecordIng
  //录音蒙层高度
  recordHeight: number = 120
  @State
  audioFilePath: string = '' //录音路径
  @State
  duration: number = 0 //记录录音时长
  @State
  audioTimer: number = -1
  @StorageProp(CurrentUser_Key)
  currentUserInfo: UserInfo = {} as UserInfo
  @Prop
  getSendUserTable: UserInfo = {} as UserInfo //和当前聊天的用户
  @State
  bottomPopup: PopupItem[] = bottomPopup //底部弹窗变量
  @State
  isShowBottomPopup: boolean = false //控制底部弹窗显示
  textController: TextInputController = new TextInputController() // 文本的控制器
  @State
  isShowLocationMap: boolean = false //控制展示地图开关
  //传递调用的方法
  onSubmitFn: (context: string) => void = () => {
  }
  //新建一个发送语音信息的方法
  sendAudioMessage: (mess: MessageInfoModel) => void = () => {
  }
  //发送图片消息
  sendPhotoMessage: (messLists: MessageInfoModel[]) => void = () => {
  }

  @Builder
  getVoiceBuilder() {
    Column() {
      VoiceInput()
    }
  }

  //底部弹层
  @Builder
  getBottomCard(item: PopupItem) {
    Column() {
      Column() {
        Image(item.icon)
          .width(30)
          .height(30)
          .fillColor("#4c4c4c")
      }
      .backgroundColor(Color.White)
      .width(56)
      .aspectRatio(1)
      .borderRadius(10)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Text(item.title)
        .fontSize(12)
        .fontColor($r('app.color.text_second'))
        .margin({
          top: 10
        })
    }.layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      if (item.id === 'photo') {
        this.sendPhoto()
      } else if (item.id === 'camera') {
        this.openCamera()
      } else if (item.id === 'location') {
        const requestPermission: Permissions[] = [
          "ohos.permission.LOCATION",
          "ohos.permission.APPROXIMATELY_LOCATION"
        ]
        const permission: Permissions = 'ohos.permission.LOCATION'
        const mess = '使用定位需要申请定位风权限'

        const callback = () => {
          this.isShowLocationMap = true
        }

        this.checkPermission(requestPermission, permission, mess, () => {
          callback()
        })
      }
    })
  }

  // 地图
  @Builder
  getLocationContent() {
    Stack({ alignContent: Alignment.Top }) {
      LocationMap()
      Row() {
        Text("取消")
          .fontColor($r("app.color.text_second"))
          .fontWeight(FontWeight.Bold)
        Button("发送")
          .type(ButtonType.Normal)
          .borderRadius(4)
          .backgroundColor($r("app.color.pay_back"))
          .fontColor($r("app.color.white"))
          .height(30)
          .width(60)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left: 20,
        right: 20
      })
      .width('100%')
      .height(60)
      .margin({
        top: 50
      })
    }
    .width('100%')
  }

  /*-----------------function ⬇⬇⬇⬇ -----------------------------*/
  aboutToAppear(): void {
    this.getScreenWidthOrHeight()
  }

  // 获取屏幕宽高
  getScreenWidthOrHeight() {
    this.screenWidth = px2vp(display.getDefaultDisplaySync().width)
    this.screenHeight = px2vp(display.getDefaultDisplaySync().height)
  }

  // 检查麦克风权限
  /*  async checkMICROPHONEPermission() {
      try {
        const manager = abilityAccessCtrl.createAtManager() // 创建程序控制管理器
        // 获取应用信息
        const buildInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
        const status = manager.checkAccessTokenSync(buildInfo.appInfo?.accessTokenId, "ohos.permission.MICROPHONE")
        if (status === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
          AlertDialog.show(
            {
              message: '语音输入需要申请麦克风权限',
              autoCancel: true,
              alignment: DialogAlignment.Center,
              primaryButton: {
                value: '去申请',
                fontColor: Color.Black,
                action: () => {
                  promptAction.showToast({ message: '确认' })
                  // 不被允许
                  const context = getContext() as common.UIAbilityContext
                  context.startAbility({
                    bundleName: 'com.huawei.hmos.settings',
                    abilityName: 'com.huawei.hmos.settings.MainAbility',
                    uri: "application_info_entry",
                    parameters: {
                      pushParams: buildInfo.name
                    }
                  })
                }
              },
              secondaryButton: {
                value: '取消申请',
                fontColor: Color.Red,
                action: () => {
                  promptAction.showToast({ message: '取消' })
                }
              },
            })
        } else {
          this.isShowVoiceInput = true
          this.beginCollectVoiceOperate()
        }
      } catch (error) {

      }
    }*/

  /* 抽离检查获取系统信息权限
   *@param requestPermission:需要申请的权限
   *@param permission：表示获取哪个权限状态的参数
   *@param mess:二级弹窗标题
   *@param callback：检查成功后的回调
    */
  async checkPermission(requestPermission: Permissions[], permission: Permissions, mess: string, callback: () => void) {
    /*  [
        'ohos.permission.MICROPHONE',
        "ohos.permission.LOCATION",
        "ohos.permission.APPROXIMATELY_LOCATION"

      ]
      */
    try {
      const manager = abilityAccessCtrl.createAtManager() // 创建程序控制管理器
      await manager.requestPermissionsFromUser(getContext(), requestPermission) //申请权限
      // 获取应用信息
      const buildInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
      const status = manager.checkAccessTokenSync(buildInfo.appInfo?.accessTokenId, permission)
      // promptAction.showDialog({ message: JSON.stringify(abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) })
      if (status === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
        AlertDialog.show(
          {
            message: mess,
            autoCancel: true,
            alignment: DialogAlignment.Center,
            primaryButton: {
              value: '去申请',
              fontColor: Color.Black,
              action: () => {
                promptAction.showToast({ message: '确认' })
                // 不被允许
                const context = getContext() as common.UIAbilityContext
                context.startAbility({
                  bundleName: 'com.huawei.hmos.settings',
                  abilityName: 'com.huawei.hmos.settings.MainAbility',
                  uri: "application_info_entry",
                  parameters: {
                    pushParams: buildInfo.name
                  }
                })
              }
            },
            secondaryButton: {
              value: '取消申请',
              fontColor: Color.Red,
              action: () => {
                promptAction.showToast({ message: '取消' })
              }
            },
          })
      } else {
        callback && callback()

      }
    } catch (error) {

    }
  }

  //开始录音
  beginCollectVoiceOperate() {
    this.audioFilePath = FileOperate.createAudioFile(this.getSendUserTable.user_id)
    AudioCapturerOperate.start(this.audioFilePath)
    this.startTime()
  }

  // 停止语音收集
  stopCollectVoiceOperate() {
    AudioCapturerOperate.stop()
    this.endTime()
  }

  // 松手停止录音判断逻辑
  releaseFingerOperate() {
    this.isShowVoiceInput = false
    this.stopCollectVoiceOperate()
    if (this.voiceState === VoiceTypeEnum.Cancel) {
      // 如果松手时，是取消状态 不管录的语音怎么样 直接删除
      FileOperate.delFilePath(this.audioFilePath) // 删除路径
      this.duration = 0 //录音时长清0
    }
    // 如果是转化文本类
    else if (this.voiceState === VoiceTypeEnum.Transfer) {

    }
    // 如果是正常录音 发送语音信息
    else if (this.voiceState === VoiceTypeEnum.RecordIng) {

      // 限制最新录制时长
      if (this.duration < 1) {
        promptAction.showToast({ message: '录制声音时间太短' })
        FileOperate.delFilePath(this.audioFilePath) // 删除路径
        return
      }
      //  发送语音信息
      this.sendAudio()
    }
    this.voiceState = VoiceTypeEnum.RecordIng


  }

  //计算录音时长
  startTime() {
    this.audioTimer = setInterval(() => {
      this.duration++

    }, 1000)
  }

  // 结束录音计时
  endTime() {
    clearInterval(this.audioTimer)
  }

  //发送语音
  sendAudio() {
    let mess = new MessageInfoModel({
      sourceDuration: this.duration,
      messageContent: `[语音]${this.duration}"`,
      connectUser: this.getSendUserTable,
      sendUser: this.currentUserInfo,
      messageType: MessageTypeEnum.AUDIO,
      sourceFilePath: this.audioFilePath
    } as MessageInfo)
    this.sendAudioMessage(mess)
    this.audioFilePath = ''
    this.duration = 0
  }

  //打开相册发送消息
  /*  1.打开相册，读取相册内选择的照片
    2.在沙箱中定义对应的文件，将选择好的照片copy到沙箱中
    3.完成后发送下消息
   */
  async sendPhoto() {
    const photo = new picker.PhotoViewPicker() //实例化相册
    const res = await photo.select({
      //设置最大选择数量，选择类型
      maxSelectNumber: 9,
      MIMEType: picker.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE
    })
    let imgLists: MessageInfoModel[] = []
    const suffix = '.jpg'
    const mess = "[图片]"
    const messageType = MessageTypeEnum.IMAGE
    res.photoUris.forEach((item) => {
      imgLists.push(this.copyFilePathFn(item, suffix, mess, messageType))
    })
    this.sendPhotoMessage(imgLists)
    // 关闭底部
    animateTo({ duration: 200 }, () => {
      this.isShowBottomPopup = false
    })

  }

  //打开相机
  async openCamera() {
    try {
      let pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      };
      let pickerResult: cameraPicker.PickerResult = await cameraPicker.pick(getContext(),
        [cameraPicker.PickerMediaType.PHOTO, cameraPicker.PickerMediaType.VIDEO], pickerProfile);
      //定义变量
      let sendLists: MessageInfoModel[] = []
      let messType = MessageTypeEnum.IMAGE
      let suffix = ''
      let mess = ''
      if (pickerResult.mediaType === cameraPicker.PickerMediaType.PHOTO) {
        /* 判断若不成立，试一下
            if (pickerResult.mediaType === 'photo')
         */
        messType = MessageTypeEnum.IMAGE
        suffix = '.jpg'
        mess = "[图片]"
      } else {
        messType = MessageTypeEnum.VIDEO
        suffix = '.mp4'
        mess = "[视频]"
      }
      //发送
      sendLists.push(this.copyFilePathFn(pickerResult.resultUri, suffix, mess, messType))
      this.sendPhotoMessage(sendLists)
      // 关闭底部
      animateTo({ duration: 200 }, () => {
        this.isShowBottomPopup = false
      })
    } catch (error) {
      promptAction.showToast({
        message: '相机打开异常'
      })
    }
  }

  //抽取copy照片路径的方法
  copyFilePathFn(itemFile: string, suffix: string, mess: string, messageType: MessageTypeEnum) {

    //创建沙箱路径,读取图片路径
    let filePath = getContext().filesDir + '/' + Date.now() + suffix
    let file = fileIo.openSync(itemFile, fileIo.OpenMode.READ_ONLY)
    let data: MessageInfoModel = new MessageInfoModel({
      connectUser: this.getSendUserTable,
      sendUser: this.currentUserInfo,
      sourceFilePath: filePath, // 图片来源
      messageType,
      messageContent: mess,
    } as MessageInfo)
    // copy图片
    fileIo.copyFileSync(file.fd, filePath)
    fileIo.closeSync(file.fd) // 关闭文件读取
    return data
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Image(this.isShowKeyBoard ? $r('app.media.ic_public_keyboard') : $r('app.media.ic_public_sound'))
          .width(25)
          .aspectRatio(1)
          .onClick(async () => {
            //先获取麦克风权限
            const manager = abilityAccessCtrl.createAtManager() // 创建程序控制管理器
            // 创建程序控制管理器
            let permissions = await manager.requestPermissionsFromUser(getContext(),
              [
                "ohos.permission.MICROPHONE"
              ])
            //获取到麦克风权限后才打开语音输入法
            this.isShowKeyBoard = !this.isShowKeyBoard

            if (this.isShowKeyBoard) {
              animateTo({ duration: 200 }, () => {
                this.isShowBottomPopup = false
              })
            }
          })
        if (this.isShowKeyBoard) {
          Button("按住 说话", { type: ButtonType.Normal })
            .backgroundColor(Color.White)
            .layoutWeight(1)
            .borderRadius(2)
            .fontColor($r('app.color.text_primary'))
            .gesture(
              GestureGroup(GestureMode.Parallel,
                //长按
                LongPressGesture()
                  .onAction(() => {
                    promptAction.showToast({ message: '按压' })
                    const requestPermission: Permissions[] = ['ohos.permission.MICROPHONE']
                    const permission: Permissions = 'ohos.permission.MICROPHONE'
                    const mess = '语音输入需要申请麦克风权限'
                    const callback = () => {
                      this.isShowVoiceInput = true
                      this.beginCollectVoiceOperate()
                    }

                    this.checkPermission(requestPermission, permission, mess, () => {
                      callback()
                    })
                  })
                  .onActionEnd(() => {

                    this.releaseFingerOperate()
                  }),
                //拖拽
                PanGesture()
                  .onActionUpdate((event) => {
                    const sW = this.screenWidth / 2
                    if (event.fingerList[0].globalY > this.screenHeight - this.recordHeight) {
                      this.voiceState = VoiceTypeEnum.RecordIng
                      return
                    }
                    event.fingerList[0].globalX < sW ? (this.voiceState = VoiceTypeEnum.Cancel) : (this.voiceState = VoiceTypeEnum.Transfer)
                  })
              )
            )
        } else {
          TextInput({ text: $$this.context, controller: this.textController })
            .layoutWeight(1)
            .height(40)
            .backgroundColor($r('app.color.start_window_background'))
            .borderRadius(2)
            .focusable(true)//聚焦
            .defaultFocus(true)//聚焦
            .id('input')
            .onSubmit(() => {
              this.onSubmitFn(this.context)
              focusControl.requestFocus('input')
              this.context = ''
            })
            .onClick(() => {
              //点击编辑时关闭弹窗
              animateTo({ duration: 200 }, () => {
                this.isShowBottomPopup = false
              })
            })
        }

        Image($r('app.media.ic_public_add_norm'))
          .width(25)
          .aspectRatio(1)
          .onClick(() => {
            animateTo({ duration: 200 }, () => {

              this.isShowBottomPopup = !this.isShowBottomPopup
              if (this.isShowBottomPopup) {
                //关闭编辑器
                this.textController.stopEditing()
              }
            })
          })
      }
      .padding({
        left: 10,
        right: 10
      })
      .height(60)
      .width('100%')
      .bindContentCover($$this.isShowVoiceInput, this.getVoiceBuilder, {
        modalTransition: ModalTransition.NONE
      })

      // 底部弹窗
      if (this.isShowBottomPopup) {
        // 底部结构
        GridRow({ columns: 4 }) {
          ForEach(this.bottomPopup, (item: PopupItem) => {
            GridCol() {
              this.getBottomCard(item)
            }.height(100)
          })
        }
        .width('100%')

      }
    }
    .bindContentCover($$this.isShowLocationMap, this.getLocationContent, {
      modalTransition: ModalTransition.NONE
    })
  }
}