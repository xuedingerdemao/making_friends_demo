import { preferences } from '@kit.ArkData'
import { Link_Man, Contacts_Key, Record_Update_Name } from '../constant/constantStore'
import { CurrentUser } from '../modle/CurrentUserModle'
import { MessageInfoModel } from '../modle/MessageInfoModel'
import { DefaultUserList, UserInfo } from '../modle/UserInfoModle'
import { promptAction } from '@kit.ArkUI'
import { emitter } from '@kit.BasicServicesKit'
import { FileOperate } from './FileOperate'


//首选项
export class contactsStore {
  static context: Context

  //初始化仓库
  static initContactsStore() {
    return preferences.getPreferencesSync(contactsStore.context || getContext(), {
      name: Link_Man,
    })
  }

  //获取和某个人的聊天记录仓库
  static getChatMessageStore(userId: string) {
    return preferences.getPreferencesSync(contactsStore.context, {
      name: `${Contacts_Key}_${userId}`
    })
  }

  //存储联系人
  static setContactInfo(key: string, val: UserInfo[]) {
    const store = contactsStore.initContactsStore() // 获取仓库
    store.putSync(key, JSON.stringify(val)) //添加信息
  }

  //获取联系人
  static getContactInfo(key: string) {
    const store = contactsStore.initContactsStore()
    return JSON.parse(store.getSync(key, JSON.stringify(DefaultUserList)) as string) as UserInfo[]
  }

  //获取当前用户
  static getCurrentUserInfoStore(key: string) {
    const store = contactsStore.initContactsStore()
    return JSON.parse(store.getSync(key, JSON.stringify(CurrentUser)) as string) as UserInfo
  }

  //存储当前
  static setCurrentUserInfoStore(key: string, val: UserInfo) {
    const store = contactsStore.initContactsStore() // 获取仓库
    store.putSync(key, JSON.stringify(val)) //添加信息
  }

  // 删除某个人整个的聊天记录
  static async delAllChatMessage(userId: string) {

    //判断是否有引用文件，有则全部删除
    FileOperate.delAllFilePath(userId)

    preferences.deletePreferences(getContext(), {
      name: `${Contacts_Key}_${userId}`
    })

  }


  //获取和某个人所有的聊天记录
  static getContactMessageStore(userId: string) {
    const store = contactsStore.getChatMessageStore(userId)
    const allRecord = store.getAllSync() as object
    if (allRecord) {
      const list = Object.values(allRecord).map((item: string) => JSON.parse(item) as MessageInfoModel)
      list.sort((a, b) => a.sendTime - b.sendTime)
      return list
    }
    return []

  }

  //添加一条和某人的聊天
  static async addOneContactMessageStore(userId: string, message: MessageInfoModel) {
    const store = contactsStore.getChatMessageStore(userId)
    store.putSync(`${message.id}`, JSON.stringify(message))

    //写入磁盘
    await store.flush()
    //事件总线,触发线程间的通信
    emitter.emit(Record_Update_Name)
  }


  // 删除和某人的某一条记录
  static async delOneContactMessageStore(userId: string, messageId: string) {
    const store = contactsStore.getChatMessageStore(userId)
    store.deleteSync(`${messageId}`)
    //写入磁盘
    await store.flush()
    //事件总线,触发线程间的通信
    emitter.emit(Record_Update_Name)
  }

  //获取近期所有聊天记录(每个聊天记录的最后一条)
  static getAllContactMessageStore() {
    const users = contactsStore.getContactInfo(Contacts_Key)
    let list: MessageInfoModel[] = []
    users.forEach((user) => {
      const messList = contactsStore.getContactMessageStore(user.user_id)
      if (messList && messList.length) {
        list.push(messList[messList.length - 1])
      }
    })
    // 对list进行排序
    list.sort((a: MessageInfoModel, b: MessageInfoModel) => {
      return b.sendTime - a.sendTime
    })
    return list
  }
}