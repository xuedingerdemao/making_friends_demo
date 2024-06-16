import { fileIo } from '@kit.CoreFileKit'
import { promptAction } from '@kit.ArkUI'

export class FileOperate {
  //创建一个文件，并返回路径
  static createAudioFile(userId: string) {
    /*先判断有无创建过文件目录
    *1.定义文件路径
    *2.检查该文件是否存在
    */
    let dirPath = getContext().filesDir + '/' + userId
    let statue = fileIo.accessSync(dirPath)
    if (!statue) {
      fileIo.mkdirSync(dirPath) //创建目录
    }
    /*存在则将该文件打开，将要存储的file存入文件目录内
     *1.定义要存储的file路径
     *2.打开文件存储进去
     */
    let filePath = `${dirPath}/${Date.now()}.wav`
    const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE)
    fileIo.closeSync(file)
    return filePath
  }

  //删除某个文件
  static delFilePath(filePath: string) {
    if (filePath) {
      fileIo.unlinkSync(filePath)
    }
  }

  //删除和某人的整个文件目录

  static delAllFilePath(userId: string) {
    if (!userId) {
      promptAction.showToast({ message: '该用户不存在' })
      return
    }
    let dirPath = getContext().filesDir + '/' + userId
    let statue = fileIo.accessSync(dirPath)
    if (statue) {
      fileIo.rmdirSync(dirPath)
    }
  }
}