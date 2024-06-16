import axios, { AxiosResponse } from '@ohos/axios'
import { ChatResponse } from '../modle/chatMessageModle'
import { promptAction } from '@kit.ArkUI'
import http from '@ohos.net.http'

const req = http.createHttp()

const getRequestMessageAPI = async (content: string) => {

  let url = `https://api.ownthink.com/bot?appid=xiaosi&userid=user&spoken=${encodeURIComponent(content)}`
  try {
    const res = await req.request(url)
    const result = JSON.parse(res.result as string) as ChatResponse
    return result
  } catch (error) {
    return Promise.reject(error)
  }

}

export { getRequestMessageAPI }