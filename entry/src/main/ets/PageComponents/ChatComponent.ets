import { MessageInfoModel } from '../modle/MessageInfoModel'
import { transTime } from '../utils/common'
import { contactsStore } from '../StoreClass/ContactsStore'
import { promptAction, router } from '@kit.ArkUI'
import { emitter } from '@kit.BasicServicesKit'
import { Record_Update_Name } from '../constant/constantStore'

interface menuType {
  menu: string
  id: string
}

@Component
export default struct ChatComponent {
  @State
  chatUserList: MessageInfoModel[] = []
  @State
  menuLists: menuType[] = [
    {
      menu: '未读',
      id: 'unread'
    }, {
    menu: '已读',
    id: 'read'
  }, {
    menu: '删除',
    id: 'del'
  },
  ]

  aboutToAppear(): void {
    this.getAllContactMessage()
  }

  async getAllContactMessage() {
    this.chatUserList = await contactsStore.getAllContactMessageStore()
    // 接收线程数据
    emitter.on(Record_Update_Name, async () => {
      this.chatUserList = await contactsStore.getAllContactMessageStore()
    })
  }

  // 二级弹窗
  showAlertDialogFn(userId: string) {
    AlertDialog.show(
      {
        message: '删除后，将情况情况该聊天的所有记录',
        autoCancel: true,
        alignment: DialogAlignment.Center,

        primaryButton: {
          value: '确认清空',
          fontColor: Color.Black,
          action: () => {

            let index = this.chatUserList.findIndex(item => item.connectUser.user_id === userId)
            if (index > -1) {
              this.chatUserList.splice(index, 1)
            }
            //删除磁盘
            contactsStore.delAllChatMessage(userId)
            promptAction.showToast({ message: '清空' })
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

  @Builder
  getDelList(userId: string) {
    Row() {
      Text("删除")
        .fontColor($r('app.color.white'))
        .width(70)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.showAlertDialogFn(userId)

        })
    }
    .padding({
      left: 20,
      right: 20
    })
    .height(50)
    .backgroundColor($r('app.color.danger'))
  }

  @Builder
  MenuBuilder(userId: string) {
    Column() {
      ForEach(this.menuLists, (item: menuType) => {
        Text(item.menu)
          .fontSize(18)
          .height(50)
          .width(100)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            if (item.id === 'del') {
              this.showAlertDialogFn(userId)
              return
            }
            promptAction.showToast({ message: ' 待完善' })
          })
      })
    }

  }

  build() {
    Column() {
      List({ space: 5 }) {
        ForEach(this.chatUserList, (item: MessageInfoModel) => {
          ListItem() {
            Row({ space: 10 }) {
              Image(item.connectUser.avatar)
                .width(50)
                .height(50)
                .borderRadius(4)

              Column({ space: 10 }) {
                Row() {
                  Text(item.connectUser.username + item.sendTime)
                    .fontColor($r('app.color.text_primary'))
                    .fontSize(16)
                  Text(transTime(item.sendTime))
                    .fontSize(12)
                    .fontColor($r('app.color.text_second'))
                    .margin({
                      top: 10
                    })
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .width('100%')

                Text(item.messageContent)
                  .fontColor($r('app.color.text_second'))
                  .fontSize(14)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(HorizontalAlign.Start)
              .height(50)
              .layoutWeight(1)
              .padding({
                top: 3,
                bottom: 3
              })
              .border({ width: { bottom: 1 }, style: BorderStyle.Solid, color: $r('app.color.back_color') })
            }
            .stateStyles({
              normal: {
                .backgroundColor($r('app.color.white'))
              },
              pressed: {
                .backgroundColor($r('app.color.back_color'))
              }
            })
          }
          .padding({
            top: 10,
            bottom: 10
          })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/UserChat/UserChatPage',
              params: item.connectUser
            })
          })
          .swipeAction({
            end: this.getDelList(item.connectUser.user_id),
            edgeEffect: SwipeEdgeEffect.None
          })
          .bindContextMenu(this.MenuBuilder(item.connectUser.user_id), ResponseType.LongPress)

        })

      }
      .layoutWeight(1)
      .padding({ left: 10, right: 10 })
      .backgroundColor($r('app.color.start_window_background'))
    }
    .height('100%')
    .width('100%')
    .border({ width: { top: 1 }, style: BorderStyle.Solid, color: $r('app.color.back_color') })

  }
}