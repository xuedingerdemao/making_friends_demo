import { audio } from '@kit.AudioKit'
import { promptAction } from '@kit.ArkUI'
import { fileIo } from '@kit.CoreFileKit'

//录制pcm音频
interface FileOptions {
  offset: number
  length: number
}

export class AudioCapturerOperate {
  static audioCapturer: audio.AudioCapturer //定义全局采集器
  static audioStreamInfo: audio.AudioStreamInfo = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
    channels: audio.AudioChannel.CHANNEL_1,
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
  }
  static audioCapturerInfo: audio.AudioCapturerInfo = {
    source: audio.SourceType.SOURCE_TYPE_MIC, // 音源类型
    capturerFlags: 0 // 音频采集器标志
  }
  static audioCapturerOptions: audio.AudioCapturerOptions = {
    streamInfo: AudioCapturerOperate.audioStreamInfo,
    capturerInfo: AudioCapturerOperate.audioCapturerInfo
  }
  static recordIng: boolean = false //控制录音录制的开关

  static async init() {
    AudioCapturerOperate.audioCapturer = await audio.createAudioCapturer(AudioCapturerOperate.audioCapturerOptions)
  }


  //开始录音方法
  static async start(filePath: string) {

    try {
      //规避模拟器报错
      if (!AudioCapturerOperate.audioCapturer) {
        promptAction.showToast({ message: '设备不支持录音' })
        return
      }

      await AudioCapturerOperate.audioCapturer.start() //开始录音
      AudioCapturerOperate.recordIng = true
      let file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
      let fd = file.fd; //文件标识
      let bufferSize: number = fileIo.statSync(fd).size
      while (AudioCapturerOperate.recordIng) {
        // 获取缓冲区的长度
        let size = AudioCapturerOperate.audioCapturer.getBufferSizeSync()
        // 读这个每个录音切片
        let buffer = await AudioCapturerOperate.audioCapturer.read(size, true)
        if (buffer) {
          // buffer就是当前这一段的录音的内容
          fileIo.writeSync(fd, buffer, {
            offset: bufferSize, // 偏移量
            length: buffer.byteLength
          })
          bufferSize += buffer.byteLength
        }
      }
    } catch (err) {
      promptAction.showToast({ message: '录制失败' })
      AudioCapturerOperate.stop()
    }

  }


  // 停止录音
  static async stop() {
    //规避模拟器报错
    if (!AudioCapturerOperate.audioCapturer) {
      return
    }
    // // 在录制时停止采集，并且将控制开关关掉
    // if (AudioCapturerOperate.audioCapturer.state === audio.AudioState.STATE_RUNNING ||
    //   AudioCapturerOperate.audioCapturer.state === audio.AudioState.STATE_PAUSED
    // ) {
    //   AudioCapturerOperate.recordIng = false
    //   await AudioCapturerOperate.audioCapturer.stop(); // 停止采集
    // }

    // 一般在长按抬起时结束
    AudioCapturerOperate.recordIng = false
    await AudioCapturerOperate.audioCapturer.stop(); // 停止采集
  }

  //释放录音资源
  static async release() {
    //规避模拟器报错
    if (AudioCapturerOperate.audioCapturer) {
      await AudioCapturerOperate.audioCapturer.release()
    }
  }
}