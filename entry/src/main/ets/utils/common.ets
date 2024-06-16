import { UserInfo } from '../modle/UserInfoModle'
import { window } from '@kit.ArkUI'

interface safeHeight {
  topSafeHeight: number
  bottomSafeHeight: number
}

/* 中文排序
*
 */
const strSortFn = (list: UserInfo[]) => {
  list.sort((a, b) => {
    return a.username.localeCompare(b.username)
  })
}

// 沉浸式设置
const setFullFn = async () => {
  const win = await window.getLastWindow(getContext())
  // 防止全局没开启，指定页面开启沉浸式
  win.setWindowLayoutFullScreen(true)
  win.setWindowLayoutFullScreen(true)
  // 获取上方安全区高度
  let topSafeHeight = px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
    .topRect.height)
  // 获取下方安全区高度
  let bottomSafeHeight = px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
    .bottomRect.height)
  let obj: safeHeight = {
    topSafeHeight,
    bottomSafeHeight,
  }
  return obj
}


//生成时间戳id
const generateRandomUUID = () => {
  const timestampId = `${Date.now()}`;
  return timestampId
}
// 转化时间
const transTime = (time: number) => {
  const dateObj = new Date(time)
  const year = dateObj.getFullYear()
  const month = dateObj.getMonth()
  const date = dateObj.getDate()
  const hours = dateObj.getHours();
  const minutes = dateObj.getMinutes();
  if (date === new Date().getDate()) {
    // 当天的消息
    return `${hours.toString().padStart(2, "0")}:${minutes.toString().padStart(2, "0")}`
  } else if (year === new Date().getFullYear()) {
    return `${(month + 1).toString()}月${date}日`
  } else {
    return `${year}年${(month + 1).toString()}月${date}日`
  }
}

export { strSortFn, setFullFn, generateRandomUUID, transTime }