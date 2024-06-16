import { UserInfo } from './UserInfoModle'

export interface AddFriendsType {
  username: string // 用户昵称
  avatar: ResourceStr // 用户头像
}


export class AddFriendsTypeModel implements AddFriendsType {
  username: string = ''
  avatar: ResourceStr = ''

  constructor(model: AddFriendsType) {
    this.username = model.username
    this.avatar = model.avatar
  }
}

export const addFriendsLists: UserInfo[] = [
  {

    username: '添加好友',
    avatar: $r('app.media.addFriend'),
    user_id: '1',
  },
  {
    username: '群里',
    avatar: $r('app.media.addFriend'),
    user_id: '2',
  },
  {
    username: '标签',
    avatar: $r('app.media.addFriend'),
    user_id: '3',
  },
  {
    username: '文章',
    avatar: $r('app.media.addFriend'),
    user_id: '4',
  },
]

export const addFirmsLists: UserInfo[] = [
  {
    username: '企业联系人',
    avatar: $r('app.media.addFriend'),
    user_id: '1',
  },
  {
    username: '通知',
    avatar: $r('app.media.addFriend'),
    user_id: '2',
  },
]