import 'dart:html' as HTML;
import 'dart:async';

import 'package:vector_math/vector_math.dart' as VM;

import 'package:chronosgl/chronosgl.dart';

const String meshFile = "../asset/dragon/dragon.obj";

HTML.InputElement gShowNormals =
    HTML.document.querySelector('#normals') as HTML.InputElement;

HTML.InputElement gShowWires =
    HTML.document.querySelector('#wires') as HTML.InputElement;

void main() {
  StatsFps fps =
      new StatsFps(HTML.document.getElementById("stats"), "blue", "gray");

  HTML.CanvasElement canvas = HTML.document.querySelector('#webgl-canvas');
  ChronosGL chronosGL = new ChronosGL(canvas, faceCulling: true);

  OrbitCamera orbit = new OrbitCamera(25.0, 10.0, 0.0, canvas);
  Perspective perspective = new Perspective(orbit, 0.1, 1000.0);
  RenderPhase phase = new RenderPhase("main", chronosGL);
  Scene scene = new Scene(
      "solid",
      new RenderProgram(
          "solid", chronosGL, solidColorVertexShader, solidColorFragmentShader),
      [perspective]);
  phase.add(scene);

  final Material matWire = new Material("wire")
    ..SetUniform(uColor, ColorYellow);
  final Material matNorm = new Material("normal")
    ..SetUniform(uColor, ColorBlue);

  Node nodeWire;
  Node nodeNorm;

  void resolutionChange(HTML.Event ev) {
    int w = canvas.clientWidth;
    int h = canvas.clientHeight;
    canvas.width = w;
    canvas.height = h;
    print("size change $w $h");
    perspective.AdjustAspect(w, h);
    phase.viewPortW = w;
    phase.viewPortH = h;
  }

  resolutionChange(null);
  HTML.window.onResize.listen(resolutionChange);

  double _lastTimeMs = 0.0;
  void animate(num timeMs) {
    double elapsed = timeMs - _lastTimeMs;
    _lastTimeMs = timeMs + 0.0;
    orbit.azimuth += 0.001;
    orbit.animate(elapsed);
    nodeNorm.enabled = gShowNormals.checked;
    nodeWire.enabled = gShowWires.checked;
    phase.Draw();

    HTML.window.animationFrame.then(animate);
    fps.UpdateFrameCount(timeMs);
  }

  List<Future<Object>> futures = [
    LoadRaw(meshFile),
  ];

  Future.wait(futures).then((List list) {
    GeometryBuilder gb = ImportGeometryFromWavefront(list[0]);
    print(gb);
    MeshData mdWire =
        GeometryBuilderToMeshDataWireframe(meshFile, scene.program, gb);
    print(mdWire);

    nodeWire = new Node(mdWire.name, mdWire, matWire);
    nodeWire.lookAt(new VM.Vector3(100.0, 0.0, 0.0));
    scene.add(nodeWire);

    MeshData mdNorm =
        GeometryBuilderToWireframeNormals(scene.program, gb, 0.05);
    nodeNorm = new Node(mdNorm.name, mdNorm, matNorm);
    nodeNorm.lookAt(new VM.Vector3(100.0, 0.0, 0.0));
    scene.add(nodeNorm);

    // Start
    animate(0.0);
  });
}
