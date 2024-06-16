import { UserInfo } from '../modle/UserInfoModle'
import { router } from '@kit.ArkUI'
import { getCurrentUserInfoAPI } from '../api/CurrentUserInfo'

@Component
export default struct CurrentUser {
  @State
  getUserTable: UserInfo = {} as UserInfo

  aboutToAppear(): void {
    this.getCurrentUserInfoFn()
  }

  // 获取联系人列表
  async getCurrentUserInfoFn() {
    let res: UserInfo
    this.getUserTable = await getCurrentUserInfoAPI()
    // try {
    //   res = await getCurrentUserInfoAPI()
    //   this.currentUserInfo = res
    //   contactsStore.setCurrentUserInfoStore(CurrentUser_Key, res)
    // } catch (e) {
    //   res = contactsStore.getCurrentUserInfoStore(CurrentUser_Key)
    // }

  }

  build() {
    Column() {
      Row() {
        Image(this.getUserTable.avatar)
          .width(60)
          .aspectRatio(1)
          .borderRadius(4)
          .objectFit(ImageFit.Cover)
        Column() {
          Text(this.getUserTable.username)
          Text(this.getUserTable.user_id)
        }
      }
      .width('100%')
      .height(200)
      .backgroundColor($r('app.color.start_window_background'))
    }
    .width('100%')
    .height('100%')
  }
}