interface PopupItem {
  id: string,
  title: string
  icon: ResourceStr
  itemClick?: () => void
}


const popupList: PopupItem[] = [
  {
    id: 'tell',
    title: '听筒播放',
    icon: $r("app.media.ic_public_ears")
  },
  {
    id: 'coll',
    title: '收藏',
    icon: $r("app.media.ic_public_cube")
  }, {
  id: 'literal',
  title: '转文字',
  icon: $r("app.media.ic_public_trans_text")
}, {
  id: 'del',
  title: '删除',
  icon: $r("app.media.ic_public_cancel")
}, {
  id: 'more',
  title: '多选',
  icon: $r("app.media.ic_public_multi_select")
}, {
  id: 'cite',
  title: '引用',
  icon: $r("app.media.ic_public_link")
}, {
  id: 'tips',
  title: '提醒',
  icon: $r("app.media.ic_public_warin")
}]

const bottomPopup: PopupItem[] = [
  {
    id: 'photo',
    icon: $r('app.media.ic_public_photo'),
    title: '照片',
  },

  {
    id: 'camera',
    icon: $r('app.media.ic_public_carema'),
    title: '拍摄',

  },
  {
    id: 'location',
    icon: $r('app.media.ic_statusbar_gps'),
    title: '位置',

  },
  {
    id: 'phone',
    icon: $r('app.media.ic_public_voice'),
    title: '语音输入',

  },
  {
    id: 'collect',
    icon: $r("app.media.ic_public_collect"),
    title: '收藏',

  },
  {
    id: 'card',
    icon: $r("app.media.ic_public_contacts_filled"),
    title: '个人名片',

  },
  {
    id: 'file',
    icon: $r("app.media.ic_public_folder_filled"),
    title: '文件',

  },
  {
    id: 'music',
    icon: $r("app.media.ic_public_music_filled"),
    title: '音乐',
  }
]

// 首页弹层提示
const homePagePopup: PopupItem[] = [
  {
    id: 'groupChat',
    title: '发起群聊',
    icon: $r('app.media.ic_public_message')
  },
  {
    id: 'addFriends',
    title: '添加朋友',
    icon: $r('app.media.ic_public_add_friend')
  },
  {
    id: 'scan',
    title: '扫一扫',
    icon: $r('app.media.ic_public_scan')
  },
  {
    id: 'pay',
    title: '收付款',
    icon: $r('app.media.ic_public_receive')
  }
]

export { PopupItem, popupList, bottomPopup, homePagePopup }