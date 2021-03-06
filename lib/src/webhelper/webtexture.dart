part of webhelper;

Future<HTML.VideoElement> MakeVideoElementFromCamera() {
  Completer<HTML.VideoElement> c = new Completer();
  // TODO: come up with better error handling signaling
  HTML.window.navigator
      .getUserMedia(video: true)
      .then((HTML.MediaStream stream) {
    HTML.VideoElement video = new HTML.VideoElement()..autoplay = true;
    video.onPlaying.first.then((_) => c.complete(video));
    video.src = HTML.Url.createObjectUrl(stream);
  }).catchError((Object error) {
    c.complete(null);
  });
  return c.future;
}

HTML.CanvasElement MakeSolidColorCanvas(String fillStyle) {
  HTML.CanvasElement canvas = new HTML.CanvasElement(width: 2, height: 2);
  HTML.CanvasRenderingContext2D ctx = canvas.getContext('2d');
  ctx.fillStyle = fillStyle;
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  return canvas;
}

Texture MakeSolidColorTexture(ChronosGL cgl, String url, String fillStyle) {
  return new ImageTexture(cgl, url, MakeSolidColorCanvas(fillStyle));
}

Texture MakeSolidColorTextureRGB(ChronosGL cgl, String url, VM.Vector3 rgb) {
  int r = (255.0 * rgb.r).round();
  int g = (255.0 * rgb.g).round();
  int b = (255.0 * rgb.b).round();
  return new ImageTexture(cgl, url, MakeSolidColorCanvas("rgb($r, $g, $b)"));
}

Texture MakeSolidColorTextureRGBA(ChronosGL cgl, String url, VM.Vector4 rgba) {
  int r = (255.0 * rgba.r).round();
  int g = (255.0 * rgba.g).round();
  int b = (255.0 * rgba.b).round();
  return new ImageTexture(cgl, url, MakeSolidColorCanvas("rgba($r, $g, $b, ${rgba.a})"));
}