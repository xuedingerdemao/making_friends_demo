import { MapComponent } from '@hms.core.map.MapComponent'

@Component
export default struct LocationMap {
  build() {
    Row() {
      MapComponent({
        mapOptions: {
          position: {
            target: {
              latitude: 39.9,
              longitude: 116.4
            },
            zoom: 10
          }
        },
        mapCallback: () => {
        }
      }).width('100%').height('100%')
    }
    .height('100%')
  }
}