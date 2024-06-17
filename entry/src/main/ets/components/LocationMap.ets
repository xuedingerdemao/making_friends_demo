import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';

@Component
struct Location {
  @Link
  currentAddress: string
  // 初始化地图的属性
  private mapOption: mapCommon.MapOptions = {
    position: {
      target: {
        latitude: 39.9,
        longitude: 116.4
      },
      zoom: 12
    }
  };
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;

  aboutToAppear(): void {
    // 地图初始化的回调
    this.callback = (err, mapController) => {
      if (!err) {
        // 获取地图的控制器类，用来操作地图
        this.mapController = mapController;
        this.mapController.setMyLocationEnabled(true) // 允许我的定位
        this.mapController.setMyLocationControlsEnabled(true) // 允许我的定位组件显示
        // 此时此刻 可以拿定位了
        this.getLocation()
      }
    };
  }

  async getLocation() {
    try {
      const result = await geoLocationManager.getCurrentLocation()
      // result.latitude
      //设置经纬度
      this.mapController?.setMyLocation({
        latitude: result.latitude,
        longitude: result.longitude,
        altitude: 0,
        accuracy: 0,
        speed: 0,
        timeStamp: 0,
        direction: 0,
        timeSinceBoot: 0,
        speedAccuracy: 0,
        directionAccuracy: 0,
        uncertaintyOfTimeSinceBoot: 0,
        sourceType: geoLocationManager.LocationSourceType.GNSS,
        altitudeAccuracy: 0
      })
      // 地图上你所看到的东西 实际上是照相机对象的镜头位置
      let cameraUpdate: map.CameraUpdate = map.newCameraPosition({
        target: {
          longitude: result.longitude,
          latitude: result.latitude
        },
        zoom: 16 // 缩放级别
      }) // 新照相机的位置
      this.mapController?.moveCamera(cameraUpdate)

      // 看到具体的位置
      // 利用花瓣地图的浮层
      this.mapController?.addMarker({
        position: {
          longitude: result.longitude,
          latitude: result.latitude
        },
        title: '您当前的位置',
        clickable: true
      })
      // 在以定位的位置画个圈
      this.mapController?.addCircle({
        radius: 500,
        center: {
          longitude: result.longitude,
          latitude: result.latitude
        },
        fillColor: 0XFF00FFFF
      })
      // 要拿经纬度点的具体的街道位置
      const res = await geoLocationManager.getAddressesFromLocation({
        latitude: result.latitude,
        longitude: result.longitude
      })
      if (res.length) {
        this.currentAddress = res[0].placeName as string
      }

    } catch (error) {
      AlertDialog.show({ message: error.message })
    }
  }

  build() {
    MapComponent({
      mapOptions: this.mapOption,
      mapCallback: this.callback // 地图初始化完成 会调用回调函数
    })
      .width('100%')
      .height("100%")
  }
}

export default Location