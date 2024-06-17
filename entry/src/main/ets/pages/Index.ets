import CommonTop from '../components/CommonTop'
import StartTipsDialog from '../components/StartTipsDialog'
import { AppTitle, AppTitleLists } from '../modle/AppTitleModle'
import { UserInfo, DefaultUserList } from '../modle/UserInfoModle'
import ContactComponent from '../PageComponents/ContactComponent'
import { display, promptAction, window } from '@kit.ArkUI'
import { contactsStore } from '../StoreClass/ContactsStore'
import { Contacts_Key, CurrentUser_Key } from '../constant/constantStore'
import { getUserInfoAPI } from '../api/UserContactInfo'
import { pinyin4js } from '@ohos/pinyin4js'
import { getCurrentUserInfoAPI } from '../api/CurrentUserInfo'
import CurrentUser from '../components/CurrentUser'
import ChatComponent from '../PageComponents/ChatComponent'
import { homePagePopup, PopupItem } from '../modle/PopupModle'
import Discover from '../components/DiscoverPage'


@Entry
@Component
struct Index {
  @State
  app_titleLists: AppTitle[] = AppTitleLists
  @State
  currentTabBarIndex: number = 0
  @State
  isShowAddVisible: boolean = false
  @State
  isShowInitVisible: boolean = false //控制进入初始化广告页
  @State
  topSafeHeight: number = 0
  @State
  bottomSafeHeight: number = 0
  @State
  moveX: Length = 240
  @State
  moveY: Length = 80
  @State
  scaleNum: number = 0
  @State
  isOpenSearch: boolean = false
  @State
  contactInfo: UserInfo[] = [] //联系人信息
  @State
  currentUserInfo: UserInfo = {} as UserInfo //当前用户信息
  @State
  searchInfo: UserInfo[] = []
  @State
  @Watch('upDateSearch')
  searchName: string = ''
  @State
  isShowContactInfoList: boolean = false
  @State
  timeCount: number = 5
  @State
  timer: number = -1 //首页转场动画

  @Builder
  titleTabBar(item: AppTitle, index: number) {
    Column() {
      Image(this.currentTabBarIndex === index ? item.selectIcon : item.icon)
        .width(20)
        .aspectRatio(1)

      Text(item.title)
        .fontSize(12)
        .fontColor(this.currentTabBarIndex === index ? "#1AAD19" : "#2A2929")//"#1AAD19": "#2A2929"
        .margin({
          top: 5
        })
    }

  }

  aboutToAppear(): void {
    this.setFullFn()
    // this.initBindIcon()
    this.getCurrentUserInfoFn()
    this.getContactInfoFn()

  }

  aboutToDisappear(): void {
    clearInterval(this.timer)
  }

  // 获取联系人列表
  async getContactInfoFn() {
    const res = await getUserInfoAPI()
    this.contactInfo = res

  }

  // 获取联系人列表
  async getCurrentUserInfoFn() {
    let res: UserInfo

    // try {
    //   res = await getCurrentUserInfoAPI()
    //   this.currentUserInfo = res
    //   contactsStore.setCurrentUserInfoStore(CurrentUser_Key, res)
    // } catch (e) {
    //   res = contactsStore.getCurrentUserInfoStore(CurrentUser_Key)
    // }

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

  upDateSearch() {
    if (this.searchName) {


      this.searchInfo = this.contactInfo.filter((item: UserInfo) => {
        const username: string = pinyin4js.convertToPinyinString(item.username, '#', pinyin4js.WITHOUT_TONE)

        let judge = username.split('#').some((item) => {
          return item.indexOf(this.searchName) > -1
        })

        return judge
      })
      this.isShowContactInfoList = true
      return
    }
    this.isShowAddVisible = false
  }

  initBindIcon() {
    this.isShowInitVisible = true
    this.timer = setInterval(() => {
      if (this.timeCount === 0) {
        clearInterval(this.timer)
        this.timeCount = 5 // 归位
        this.isShowInitVisible = false // 关闭弹层
        return
      }
      this.timeCount--
    }, 1000)
  }

  @Builder
  searchBuilder() {
    Column() {
      Row({ space: 5 }) {

        Row() {
          Search({ placeholder: '搜索', value: $$this.searchName })
            .onChange((val) => {
              if (!val) {
                this.searchInfo = []
                this.isShowContactInfoList = false
              }
            })
        }
        .layoutWeight(1)

        Row() {
          Text('取消')
            .fontColor('#2569a4')
        }
        .onClick(() => {
          this.searchName = ''
          this.isShowAddVisible = false
          this.isOpenSearch = false
          this.searchInfo = []
        })
      }
      .padding({ left: 10, right: 10 })

      if (this.isShowContactInfoList) {
        Column() {
          Row() {
            Text('联系人')
          }
          .padding({ left: 10 })
          .width('100%')
          .border({ width: { bottom: 1 }, color: $r('app.color.back_color'), style: BorderStyle.Solid, })

          List() {
            ForEach(this.searchInfo, (item: UserInfo) => {
              ListItem() {
                Row({ space: 10 }) {
                  Image(item.avatar)
                    .width(30)
                    .aspectRatio(1)
                    .borderRadius(4)
                  Row() {
                    Text(item.username)
                  }
                  .padding({ bottom: 2 })
                  .width('100%')
                  .height(30)
                  .border({ width: { bottom: 1 }, color: $r('app.color.back_color'), style: BorderStyle.Solid, })
                }
                .justifyContent(FlexAlign.Start)
                .padding({ left: 10 })
                .height(50)
                .width('100%')
              }
            })
          }
          .layoutWeight(1)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }

    }
    .padding({
      top: this.topSafeHeight,
      bottom: this.bottomSafeHeight
    })
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.start_window_background'))
  }

  @Builder
  initBuilder() {
    Column() {
      Row() {
        Text(`还剩${this.timeCount}秒`)
          .fontColor(Color.White)
          .onClick(() => {
            clearInterval(this.timer)
            this.isShowInitVisible = false
            this.timeCount = 5
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding(10)

    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.initIcon'))
    .backgroundImageSize({ width: '100%', height: '100%' })
  }

  build() {
    Stack() {

      Tabs({ index: $$this.currentTabBarIndex, barPosition: BarPosition.End }) {
        ForEach(this.app_titleLists, (item: AppTitle, index: number) => {
          TabContent() {
            Column() {
              if (item.name !== 'my') {
                CommonTop({
                  titleName: item.title,
                  handleClickAdd: () => {
                    this.isShowAddVisible = !this.isShowAddVisible
                    animateTo({ duration: 100 }, () => {
                      this.scaleNum = 1
                    })
                  },
                  openSearchFn: () => {
                    this.isOpenSearch = true

                  }
                })
              }
              if (item.name === 'my') {
                CurrentUser()
                  .padding({
                    top: this.topSafeHeight
                  })
              }
              else if (item.name === 'chat') {
                ChatComponent()
              }
              else if (item.name === 'connect') {
                ContactComponent()
              }
              else if (item.name === 'discover') {
                Discover()
              }
            }
            .padding({
              top: this.topSafeHeight,
            })
            .height('100%')
          }
          .tabBar(this.titleTabBar(item, index))
          .backgroundColor($r('app.color.back_color'))
        })
      }
      .padding({
        bottom: this.bottomSafeHeight
      })
      .bindContentCover($$this.isOpenSearch, this.searchBuilder, {
        modalTransition: ModalTransition.NONE
      })

      // if (this.isShowAddVisible) {
      //   Stack() {
      //     Column() {
      //     }
      //     .width('100%')
      //     .height('100%')
      //
      //     .onClick(() => {
      //       this.isShowAddVisible = false
      //       animateTo({ duration: 100 }, () => {
      //         this.scaleNum = 0
      //       })
      //     })
      //     .backgroundColor(Color.Transparent)
      //
      //     StartTipsDialog()
      //       .position({
      //         x: this.moveX,
      //         y: this.moveY,
      //         // x: 220,
      //         // y: 70
      //       })
      //       .scale({ x: this.scaleNum, y: this.scaleNum })
      //   }
      //
      // }


    }
    .backgroundColor($r('app.color.start_window_background'))
    .bindContentCover($$this.isShowInitVisible, this.initBuilder, {
      modalTransition: ModalTransition.NONE
    })
  }
}

function getCurrentUserInfo() {
  throw new Error('Function not implemented.')
}
