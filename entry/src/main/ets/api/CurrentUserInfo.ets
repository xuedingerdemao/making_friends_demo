import { CurrentUser } from '../modle/CurrentUserModle';
import { UserInfo } from '../modle/UserInfoModle';


//获取当前用户信息
export const getCurrentUserInfoAPI = () => {
  return new Promise<UserInfo>((resolve, reject) => {
    setTimeout(() => {
      // 模拟异步请求返回的数据
      const data = CurrentUser;
      resolve(data);
    }, 1000);
  });
}