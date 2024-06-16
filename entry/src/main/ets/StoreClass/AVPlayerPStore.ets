import { media } from '@kit.MediaKit'

enum PlayType {
  Message,
  Video,
  Notice
}

class AVPlayerPStore {
  avplayer: media.AVPlayer | null = null // 初始属性

  async init() {
    this.avplayer = await media.createAVPlayer() // 创建avplayer
    this.watchCallBack()
  }

  // 监听状态变化
  watchCallBack() {
    this.avplayer?.on("stateChange", (state: string) => {
      switch (state) {
      // 只要给avplayer的url或者fdsrc赋值就可以触发初始化
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          console.info('AVPlayer state initialized called.');
          this.avplayer?.prepare(); // 准备播放
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          console.info('AVPlayer state prepared called.');
          this.avplayer?.play(); // 调用播放接口开始播放
          break;
        case 'playing': // play成功调用后触发该状态机上报
          console.info('AVPlayer state playing called.');
          break;
        case 'paused': // pause成功调用后触发该状态机上报
          console.info('AVPlayer state paused called.');
          break;
        case 'completed': // 播放结束后触发该状态机上报
          console.info('AVPlayer state completed called.');
          this.avplayer?.reset() // 重置
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          console.info('AVPlayer state stopped called.');
          this.avplayer?.reset() // 重置
          break;
        case 'released':
          console.info('AVPlayer state released called.');
          this.avplayer?.reset() // 重置
          break;
        case 'error':
          console.info('AVPlayer state released called.');
          this.avplayer?.reset() // 重置
          break;
        default:
          console.info('AVPlayer state unknown called.');
          break;
      }
    })
  }

  // play播放方法
  async play(fileName: string) {
    // 资源管理器获取文件的方法
    const fileDes = await getContext().resourceManager.getRawFd(fileName)
    this.avplayer!.fdSrc = fileDes // 赋值url或者fdsrc会造成
  }
}

export { PlayType, AVPlayerPStore }