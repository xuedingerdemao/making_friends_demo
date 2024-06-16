import { pinyin4js } from '@ohos/pinyin4js';
import { UserInfo, UserInfoTable, DefaultUserList } from '../modle/UserInfoModle'
import { promptAction, router } from '@kit.ArkUI';
import { getUserInfoAPI } from '../api/UserContactInfo';
import Loading from '../components/Loading';
import { addFriendsLists, addFirmsLists, AddFriendsType } from '../modle/AddFriendsTypeModle';
import { ifaa } from '@kit.OnlineAuthenticationKit';
import { contactsStore } from '../StoreClass/ContactsStore';
import { Contacts_Key } from '../constant/constantStore';

//联系人组件
@Component
export default struct ContactComponent {
  @State
  userInfoList: UserInfoTable[] = []
  @State
  isLoading: boolean = true
  strValue: string[] = ['↑', '➲', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
    'H', 'I', 'J', 'K', 'L', 'M', 'N',
    'O', 'P', 'Q', 'R', 'S', 'T', 'U',
    'V', 'W', 'X', 'Y', 'Z', '#',]
  zM: string[] = ['A', 'B', 'C', 'D', 'E', 'F', 'G',
    'H', 'I', 'J', 'K', 'L', 'M', 'N',
    'O', 'P', 'Q', 'R', 'S', 'T', 'U',
    'V', 'W', 'X', 'Y', 'Z',]
  scroller: Scroller = new Scroller()
  addFriendsInfo: UserInfo[] = addFriendsLists
  addFirmsInfo: UserInfo[] = addFirmsLists

  // @State
  // currentSelectStr: string = 'A'

  aboutToAppear(): void {
    this.getUserInfo()

    // const aaa = pinyin4js.convertToPinyinString('1', '', pinyin4js.FIRST_LETTER).toUpperCase()
    // let bbb = this.zM.includes(aaa)
    // promptAction.showDialog({ message: bbb + '' })

  }

  async getUserInfo() {
    let res: UserInfo[] = []

    /*
     * 判断是否可以从接口获取：
     * 如果接口可以获取则赋值，更新仓库
     * 如果没有（如网络异常），则从仓库获取
     * */
    // try {
    //   res = await getUserInfoAPI()
    //   contactsStore.setContactInfo(Contacts_Key, res)
    // } catch (e) {
    //   res = contactsStore.getContactInfo(Contacts_Key)
    // }

    //模拟器测试时打开
    res = await getUserInfoAPI()
    this.userInfoList = this.strSortFn(res)
    this.isLoading = false
  }

  strSortFn(list: UserInfo[]) {
    let newArr: UserInfoTable[] = []
    let newList: UserInfo[] = []

    newList = list.map((item: UserInfo) => {

      let firstLetter: string = pinyin4js.convertToPinyinString(item.username, '', pinyin4js.FIRST_LETTER)[0]
        .toUpperCase()
      //名字开头不为中文时，检索不出拼音，所以要单独处理一下
      if (!this.zM.includes(firstLetter)) {
        firstLetter = '#'
      }

      return {
        username: item.username,
        avatar: item.avatar,
        user_id: item.user_id,
        firstLetter: firstLetter
      } as UserInfo
    })


    newList.sort((a, b) => a.firstLetter!.localeCompare(b.firstLetter!))
    // promptAction.showDialog({
    //   message: JSON.stringify(newList)
    // })
    this.strValue.forEach((item: string, index: number) => {
      newArr.push({
        firstLetter: item,
        userInfoTable: [] as UserInfo[]
      } as UserInfoTable)
    })

    newList.forEach((item: UserInfo) => {
      const index = newArr.findIndex((val: UserInfoTable) => {
        return val.firstLetter === item.firstLetter
      })
      newArr[index].userInfoTable.push(item)
    })

    const newAddFriend: UserInfoTable = {
      firstLetter: '',
      userInfoTable: [...this.addFriendsInfo]
    }
    const newAddFirmsInfo: UserInfoTable = {
      firstLetter: '额外的联系人信息',
      userInfoTable: [...this.addFirmsInfo]
    }
    //
    // newArr.unshift(newAddFirmsInfo)
    // newArr.unshift(newAddFriend)
    newArr = newArr.filter((item: UserInfoTable) => {
      return item.userInfoTable.length > 0
    })
    return newArr


  }

  @Builder
  titleHeader(title: string) {
    if (title) {
      Row() {
        Text(title)
          .fontSize(15)
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 10 })
      .margin({ bottom: 10 })
      .height(25)
      .width('100%')
      .backgroundColor($r('app.color.back_color'))
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        Loading()
      } else {

        Stack({ alignContent: Alignment.End }) {
          Column() {
            List({ scroller: this.scroller, }) {

              //添加朋友
              ListItem() {
                Column() {
                  ForEach(this.addFriendsInfo, (item: UserInfo) => {
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
                    .onClick(() => {
                      promptAction.showToast({ message: '待开发' })
                    })
                  })
                }
                .alignItems(HorizontalAlign.Start)
                .width('100%')

              }

              //添加额外联系人
              ListItem() {
                Column() {
                  Row() {
                    Text('额外的联系人信息')
                      .fontSize(15)
                  }
                  .justifyContent(FlexAlign.Start)
                  .alignItems(VerticalAlign.Center)
                  .padding({ left: 10 })
                  .width('100%')
                  .height(25)
                  .backgroundColor($r('app.color.back_color'))
                  .onClick(() => {
                    this.scroller.scrollToIndex(23)
                  })

                  ForEach(this.addFirmsInfo, (item: UserInfo) => {
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
                    .onClick(() => {
                      promptAction.showToast({ message: '待开发' })
                    })
                  })
                }
                .alignItems(HorizontalAlign.Start)
                .width('100%')
              }

              ForEach(this.userInfoList, (item: UserInfoTable, index) => {
                if (item.userInfoTable.length > 0) {
                  ListItemGroup({ header: this.titleHeader(item.firstLetter), space: 10 }) {
                    ForEach(item.userInfoTable, (userTable: UserInfo) => {
                      ListItem() {
                        Row({ space: 10 }) {
                          Image(userTable.avatar)
                            .width(30)
                            .aspectRatio(1)
                            .borderRadius(4)

                          Row() {
                            Text(userTable.username)
                          }
                          .padding({ bottom: 2 })
                          .width('100%')
                          .height(30)
                          .border({
                            width: { bottom: item.userInfoTable.length === 1 ? 0 : 1 },
                            color: $r('app.color.back_color'),
                            style: BorderStyle.Solid,
                          })
                        }
                        .justifyContent(FlexAlign.Start)
                        .width('100%')

                      }
                      .padding({ left: 10 })
                      .onClick(() => {
                        router.pushUrl({
                          url: 'pages/UserChat/UserChatPage',
                          params: userTable
                        })
                      })
                    })
                  }
                  .padding({ bottom: 10 })
                }
              })
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
          }
          .width('100%')
          .height('100%')

          Column() {
            AlphabetIndexer({ arrayValue: this.strValue, selected: 0 })
              .itemSize(25)// 每一项的尺寸大小
              .onSelect((index) => {
                //回到顶部
                if (index === 0) {
                  this.scroller.scrollToIndex(0, true)
                  promptAction.showToast({ message: `点击索引${index}` + '回到顶部' })
                  return
                }
                //跳转至额外联系人
                if (index === 1) {
                  this.scroller.scrollToIndex(1, true)
                  promptAction.showToast({ message: `点击索引${index}` + '跳转至额外联系人' })
                  return
                }
                let currentSelectStr = this.strValue.find((item, idx) => {
                  return idx === index
                }) as string
                let curentIndex = this.userInfoList.findIndex((item: UserInfoTable) => {
                  return currentSelectStr === item.firstLetter
                })
                if (curentIndex > 0) {

                  this.scroller.scrollToIndex(curentIndex, true)
                  promptAction.showToast({
                    message: `点击${currentSelectStr}` + '，索引' + curentIndex.toString() + `，有${this.userInfoList[curentIndex].userInfoTable.length}个联系人`
                  })
                  return
                }
                promptAction.showToast({ message: `点击${currentSelectStr}` + '，没有联系人' })
              })
          }
          .height('80%')
        }

        .width('100%')
        .layoutWeight(1)
        .backgroundColor($r('app.color.start_window_background'))
      }

    }
    .layoutWeight(1)
    .width('100%')
  }
}