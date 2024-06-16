@Preview
@Component
export default struct Loading {
  Count: number = 4
  @State
  widthSize: number = 50
  @State rotateAngle: number = 0

  aboutToAppear(): void {
    this.showRotateFn()
  }

  showRotateFn() {
    animateTo({ duration: this.Count * 100, iterations: -1, curve: Curve.Linear }, () => {
      this.rotateAngle = 360
    })
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.loading'))
          .width(this.widthSize)
          .aspectRatio(1)
      }
      .rotate({ angle: this.rotateAngle })

    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .layoutWeight(1)
  }
}