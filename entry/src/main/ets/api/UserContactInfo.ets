import axios, { AxiosResponse } from '@ohos/axios'
import { UserInfo, DefaultUserList } from '../modle/UserInfoModle'

//获取用户信息
const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVC'

const getUserInfoAPI = () => {
  return new Promise<UserInfo[]>((resolve, reject) => {
    setTimeout(() => {
      // 模拟异步请求返回的数据
      const data = DefaultUserList;
      resolve(data);
    }, 1000);
  });
}

export { getUserInfoAPI }