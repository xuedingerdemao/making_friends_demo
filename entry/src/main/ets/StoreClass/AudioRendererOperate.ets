import { audio } from '@kit.AudioKit'
import { fileIo } from '@kit.CoreFileKit';
import { promptAction } from '@kit.ArkUI';
import { Level } from '@ohos/hypium';
import call from '@ohos.telephony.call';

/*function:1*/
//播放pcm音频
export class AudioRendererOperate {
  // 实例
  static renderModel: audio.AudioRenderer
  // 采样配置
  static audioStreamInfo: audio.AudioStreamInfo = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
    channels: audio.AudioChannel.CHANNEL_1,
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
  };
  static audioRendererInfo: audio.AudioRendererInfo = {
    rendererFlags: 0, // 音频渲染器 0 普通  1 低时延 (不支持)
    usage: audio.StreamUsage.STREAM_USAGE_MOVIE
    // 场景
  }
  // 创建播放器的参数
  static audioRendererOptions: audio.AudioRendererOptions = {
    streamInfo: AudioRendererOperate.audioStreamInfo,
    rendererInfo: AudioRendererOperate.audioRendererInfo
  }
  static renderIng: boolean = false // 判断是否正在播放
  // 初始化播放音频示例
  static async init() {
    if (!AudioRendererOperate.renderModel) {
      // 创建实例
      AudioRendererOperate.renderModel = await audio.createAudioRenderer(AudioRendererOperate.audioRendererOptions)
    }
  }

  // 开始语音播放
  static async start(filePath: string, callback?: () => void) {

    //规避模拟器报错
    if (!AudioRendererOperate.renderModel) {
      return
    }
    /* 定义播放状态---->只有暂停 停止 准备状态可播放，
     *不包含上述的情况 此时就不能播了
     */
    let stateList: audio.AudioState [] = [
      audio.AudioState.STATE_PREPARED,
      audio.AudioState.STATE_PAUSED,
      audio.AudioState.STATE_STOPPED
    ]
    if (!stateList.includes(AudioRendererOperate.renderModel.state)) return
    // 开启开关，进行播放操作
    AudioRendererOperate.renderIng = true
    // 启动播放
    await AudioRendererOperate.renderModel.start()
    // 读写文件 filePath的文件 一段段的读取 读完拉到 关闭文件 停止播放
    const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY) // 读这个文件的buffer  一段段的读取 1280
    const stat = fileIo.statSync(file.fd) // 详细信息
    const bufferSize = await AudioRendererOperate.renderModel.getBufferSize() // 获取缓冲区的长度
    let buf = new ArrayBuffer(bufferSize) // 创建一个缓冲区对象 长度是音频采集器长度的长度
    let totalSize = 0 // AudioRendererOperate
    while (totalSize < stat.size && AudioRendererOperate.renderIng) {
      fileIo.readSync(file.fd, buf, {
        offset: totalSize,
        length: bufferSize
      })
      // 往音频采集器写入缓冲区内容  播完再下一段
      await AudioRendererOperate.renderModel.write(buf)
      if (AudioRendererOperate.renderModel!.state.valueOf() === audio.AudioState.STATE_RELEASED) { // 如果渲染器状态为released，关闭资源
        fileIo.close(file);
      }
      // 此时要继续
      totalSize += bufferSize
    }
    // 关闭文件
    fileIo.closeSync(file.fd)
    AudioRendererOperate.stop() // 关闭
    callback && callback()
  }

  // 音频的释放和暂停
  static async stop() {
    if (AudioRendererOperate.renderModel && AudioRendererOperate.renderModel.state === audio.AudioState.STATE_RUNNING) {
      AudioRendererOperate.renderIng = false
      await AudioRendererOperate.renderModel.stop() // 通知方法
      await AudioRendererOperate.renderModel.release() // 释放方法

    }
  }

  // 释放
  static async release() {
    if (AudioRendererOperate.renderModel) {
      await AudioRendererOperate.renderModel.release() // 释放方法
    }
  }
}

/*function:2*/
//播放pcm音频 since:11
export class AudioRenderer {
  static renderIng: boolean = false // 是否正在播放
  // 实例
  static renderModel: audio.AudioRenderer
  // 采样配置
  static audioStreamInfo: audio.AudioStreamInfo = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_44100,
    channels: audio.AudioChannel.CHANNEL_1,
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
  };
  static audioRendererInfo: audio.AudioRendererInfo = {
    rendererFlags: 0, // 音频渲染器 0 普通  1 低时延 (不支持)
    usage: audio.StreamUsage.STREAM_USAGE_VOICE_ASSISTANT
    // 场景
  }
  // 创建播放器的参数
  static audioRendererOptions: audio.AudioRendererOptions = {
    streamInfo: AudioRenderer.audioStreamInfo,
    rendererInfo: AudioRenderer.audioRendererInfo
  }
  static renderFile: fileIo.File // 读取的文件

  static renderSize: number = 0 // 读取的size

  static maxSize: number = 0 // 文件的size
  static renderCallBack: () => void = () => {
  }

  static async init() {
    if (!AudioRenderer.renderModel) {
      AudioRenderer.renderModel = await audio.createAudioRenderer(AudioRenderer.audioRendererOptions)
      /* 4.播放时会触发on事件取读取：
      a.一段段buffer去读，读完后将当前buffer加在前一段后面，循环
      b.直到所有buffer相加的长度>=maxSize时停止播放 ,关闭文件
       */
      AudioRenderer.renderModel.on('writeData', (buffer: ArrayBuffer) => {
        // 停止播放
        if (AudioRenderer.renderSize >= AudioRenderer.maxSize) {
          // 要关闭文件
          fileIo.closeSync(AudioRenderer.renderFile)
          AudioRenderer.stop()
          return
        }
        //a.一段段buffer去读，读完后将当前buffer加在前一段后面
        fileIo.readSync(AudioRenderer.renderFile.fd, buffer, {
          offset: AudioRenderer.renderSize,
          length: buffer.byteLength
        })
        AudioRenderer.renderSize += buffer.byteLength
      })
    }
  }


  // 开始播放
  static async start(filePath: string, startCallback?: () => void, endCallback?: () => void) {
    if (!AudioRenderer.renderModel && !filePath) {
      return
    }
    //每次播放前重置一下
    await AudioRenderer.stop()
    /* 播放步骤：
        1.先读取文件
        2.拿到文件大小，赋值给maxSize
        3.然后播放

        */

    AudioRenderer.renderFile = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY) //拿到文件
    AudioRenderer.maxSize = fileIo.statSync(AudioRenderer.renderFile.fd).size //拿到文件大小（长度）
    startCallback && startCallback()
    if (endCallback) {
      AudioRenderer.renderCallBack = endCallback
    }
    // 开始读
    await AudioRenderer.renderModel.start()
  }


  //停止播放
  static async stop() {
    if (AudioRenderer.renderModel && AudioRenderer.renderModel.state === audio.AudioState.STATE_RUNNING) {
      await AudioRenderer.renderModel.stop()
      AudioRenderer.renderCallBack && AudioRenderer.renderCallBack()
      AudioRenderer.renderSize = 0
      AudioRenderer.maxSize = 0
    }
  }


  // 释放
  static async release() {
    if (AudioRenderer.renderModel) {
      await AudioRenderer.stop() //先停，可能还在播放
      await AudioRenderer.renderModel.release() // 释放
    }
  }
}