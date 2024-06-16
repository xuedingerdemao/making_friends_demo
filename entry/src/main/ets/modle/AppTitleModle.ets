interface AppTitle {
  title: string,
  icon: ResourceStr,
  selectIcon?: ResourceStr,
  name?: string,
}

const AppTitleLists: AppTitle[] = [{
  icon: $r("app.media.ic_public_message"),
  selectIcon: $r('app.media.ic_public_message_filled'),
  name: 'chat',
  title: '聊天页面',
}, {
  icon: $r('app.media.ic_public_contacts_group'),
  selectIcon: $r('app.media.ic_public_contacts_group_filled'),
  name: 'connect',
  title: '联系人',
}, {
  icon: $r('app.media.ic_gallery_discover'),
  selectIcon: $r('app.media.ic_gallery_discover_filled'),
  name: 'discover',
  title: '发现',
}, {
  icon: $r('app.media.ic_public_contacts'),
  selectIcon: $r('app.media.ic_public_contacts_filled'),
  name: 'my',
  title: '我的',
}]

const AddTopCommonList: AppTitle[] = [
  {
    icon: $r('app.media.ic_public_contacts_group'),
    title: '添加联系人'
  },
  {
    icon: $r('app.media.ic_public_groupChat'),
    title: '加入群组'
  },
  {
    icon: $r('app.media.ic_public_creatGroup'),
    title: '创建群组'
  },
  {
    icon: $r('app.media.ic_public_creatVideo'),
    title: '视频会议'
  },
  {
    icon: $r('app.media.ic_public_scan'),
    title: '扫一扫'
  },
]

export { AppTitle, AppTitleLists,AddTopCommonList }