import 'package:chronosgl/chronosgl.dart';
import 'dart:html' as HTML;
import 'dart:math' as Math;

import 'package:vector_math/vector_math.dart' as VM;


const double kShadowBias1 = 0.001;
const double kShadowBias2 = 0.001;

final ShaderObject lightVertexShaderBlinnPhongWithShadow =
    new ShaderObject("LightBlinnPhongShadowV")
      ..AddAttributeVars([aPosition, aNormal])
      ..AddVaryingVars([vPosition, vNormal, vPositionFromLight])
      ..AddUniformVars([
        uPerspectiveViewMatrix,
        uLightPerspectiveViewMatrix,
        uModelMatrix,
        uNormalMatrix
      ])
      ..SetBodyWithMain([
        """
        vec4 pos = ${uModelMatrix} * vec4(${aPosition}, 1.0);
        ${vPositionFromLight} = ${uLightPerspectiveViewMatrix} * pos;
        gl_Position = ${uPerspectiveViewMatrix} * pos;
        ${vPosition} = pos.xyz;
        ${vNormal} = ${uNormalMatrix} * ${aNormal};
        """
      ]);

final ShaderObject lightFragmentShaderBlinnPhongWithShadow =
    new ShaderObject("LightBlinnPhongShadowF")
      ..AddVaryingVars([vPosition, vNormal, vPositionFromLight])
      ..AddUniformVars([uLightDescs, uLightTypes, uShininess])
      ..AddUniformVars([uShadowMap, uEyePosition, uColor, uShadowBias])
      ..SetBodyWithMain([
        """

    vec3 depth = ${vPositionFromLight}.xyz / ${vPositionFromLight}.w;
		// depth is in [-1, 1] but we want [0, 1] for the texture lookup
		depth = 0.5 * depth + vec3(0.5);

    float shadow = GetShadow(depth, ${uShadowMap}, ${kShadowBias1}, ${kShadowBias2});

    ColorComponents acc = ColorComponents(vec3(0.0), vec3(0.0));
    if (shadow > 0.0) {
        acc = CombinedLight(${vPosition}, ${vNormal}, ${uEyePosition},
                            ${uLightDescs}, ${uLightTypes}, ${uShininess});
    }

    ${oFragColor}.rgb = shadow * acc.diffuse +
                       shadow * acc.specular +
                       uColor;
    ${oFragColor}.a = 1.0;
    // if ( ${oFragColor}.r != 66.0)  gl_FragColor.rgb = vec3(shadow);

      """
      ], prolog: [
        "",
        StdLibShader,
        ShadowMapShaderLib,
      ]);

final VM.Vector3 posLight = new VM.Vector3(11.0, 20.0, 0.0);
final VM.Vector3 dirLight = new VM.Vector3(0.0, -30.0, 0.0);

final double range = 40.0;
final double angle = Math.PI / 6.0;
final double glossiness = 10.0;

// These must be in-sync with the .html file
final String idPoint = "idPoint";
final String idSpot = "idSpot";
final String idDirectional = "idDirectional";

final Map<String, Light> lightSources = {
  idDirectional:
      new DirectionalLight("dir", dirLight, ColorBlue, ColorBlack, 40.0),
  idSpot: new SpotLight("spot", posLight, dirLight, ColorBlue, ColorBlack,
      range, angle, 0.5, 0.5, range * 1.1),
  idPoint: new PointLight("point", posLight, ColorLiteBlue, ColorBlue, range),
};

Light gActiveLight;

void EventRadioChanged(String name) {
  print("${name} toggle ");
  gActiveLight = lightSources[name];
  lightSources[name].enabled = true;
  for (String n in lightSources.keys) {
    if (n != name) lightSources[n].enabled = false;
  }
}

void EventPositionChanged(String name, double value) {
  print("EventPositionChanged ${name} ${value}");
  switch (name) {
    case "posx":
      (lightSources[idSpot] as SpotLight).pos.x = value;
      (lightSources[idPoint] as PointLight).pos.x = value;
      break;
    case "posy":
      (lightSources[idSpot] as SpotLight).pos.y = value;
      (lightSources[idPoint] as PointLight).pos.y = value;
      break;
    case "posz":
      (lightSources[idSpot] as SpotLight).pos.z = value;
      (lightSources[idPoint] as PointLight).pos.z = value;
      break;
  }
}

void EventDirectionChanged(String name, double value) {
  print("EventDirectionChanged ${name} ${value}");
  switch (name) {
    case "dirx":
      (lightSources[idSpot] as SpotLight).dir.x = value;
      (lightSources[idDirectional] as DirectionalLight).dir.x = value;
      break;
      break;
    case "diry":
      (lightSources[idSpot] as SpotLight).dir.y = value;
      (lightSources[idDirectional] as DirectionalLight).dir.y = value;
      break;
    case "dirz":
      (lightSources[idSpot] as SpotLight).dir.z = value;
      (lightSources[idDirectional] as DirectionalLight).dir.z = value;
      break;
  }
}

double GetInputValue(HTML.InputElement e) {
  return double.parse(e.value);
}

void SwallowEvent(HTML.Event e) {
  e.stopPropagation();
}

final Material matGray = new Material("matGray")
  ..SetUniform(uColor, ColorGray4)
  ..SetUniform(uShininess, glossiness);

final Material matObjects = new Material("objects")
  ..SetUniform(uColor, ColorGray2)
  ..SetUniform(uShininess, glossiness);

final Material matNormals = new Material("normals")
  ..SetUniform(uColor, ColorRed)
  ..SetUniform(uShininess, glossiness);

final Material lightSourceMat = new Material("light")
  ..SetUniform(uColor, ColorYellow);

void AddShapesToScene(Scene scene) {
  scene.add(new Node("sphere", ShapeIcosahedron(scene.program, 3), matObjects)
    ..setPos(0.0, 0.0, 0.0));

  scene.add(new Node("cube", ShapeCube(scene.program), matObjects)
    ..setPos(-5.0, 0.0, -5.0));

  scene.add(new Node(
      "cylinder", ShapeCylinder(scene.program, 3.0, 6.0, 2.0, 32), matObjects)
    ..setPos(5.0, 0.0, -5.0));

  scene.add(new Node(
      "torusknot", ShapeTorusKnot(scene.program, radius: 1.0, tube: 0.4), matObjects)
    ..setPos(5.0, 0.0, 5.0));

  scene.add(new Node(
      "plane", ShapeCube(scene.program, x: 30.0, y: 0.1, z: 30.0), matGray)
    ..setPos(0.0, -10.0, 0.0));
}

double kNear = 0.1;
double kFar = 50.0;

void main() {
  StatsFps fps =
      new StatsFps(HTML.document.getElementById("stats"), "blue", "gray");
  HTML.CanvasElement canvas = HTML.document.querySelector('#webgl-canvas');
  ChronosGL chronosGL = new ChronosGL(canvas, faceCulling: false);

  OrbitCamera orbit = new OrbitCamera(25.0, 10.0, 0.0, canvas);

  canvas.width = canvas.clientWidth;
  canvas.height = canvas.clientHeight;

  final Perspective perspective = new Perspective(orbit, kNear, kFar);

  Illumination illumination = new Illumination();
  for (Light l in lightSources.values) {
    illumination.AddLight(l);
  }

  ShadowMap shadowMap = new ShadowMap(chronosGL, 512, 512, 0.5, 20.0);

  UniformGroup uniforms = new UniformGroup("plain")
    ..SetUniform(uShadowMap, shadowMap.GetMapTexture())
    ..SetUniform(uCanvasSize, shadowMap.GetMapSize())
    ..SetUniform(uShadowBias, 0.03);

  // display scene with shadow on left part of screen.
  RenderPhase phaseMain = new RenderPhase("main", chronosGL);
  Scene sceneBasic = new Scene(
      "solid",
      new RenderProgram(
          "solid",
          chronosGL,
          lightVertexShaderBlinnPhongWithShadow,
          lightFragmentShaderBlinnPhongWithShadow),
      [perspective, illumination, uniforms]);
  phaseMain.add(sceneBasic);

  Scene sceneFixed = new Scene(
      "solid",
      new RenderProgram(
          "solid", chronosGL, solidColorVertexShader, solidColorFragmentShader),
      [perspective, illumination]);
  phaseMain.add(sceneFixed);

  assert(
      sceneFixed.program.HasDownwardCompatibleAttributesTo(sceneBasic.program));
  AddShapesToScene(sceneBasic);
  for (Node n in sceneBasic.nodes) {
    shadowMap.AddShadowCaster(n);
  }

  // Same order as lightSources
  MeshData mdLight = EmptyLightVisualizer(sceneFixed.program, "light");
  sceneFixed.add(new Node("light", mdLight, lightSourceMat));

  // Event Handling
  for (HTML.Element input in HTML.document.getElementsByTagName("input")) {
    input.onChange.listen((HTML.Event e) {
      HTML.InputElement input = e.target as HTML.InputElement;
      if (input.type == "radio") {
        EventRadioChanged(input.id);
      }
    });

    input.onInput.listen((HTML.Event e) {
      HTML.InputElement input = e.target as HTML.InputElement;
      if (input.type == "range") {
        String name = input.id;
        double value = GetInputValue(input);
        if (name.startsWith("pos")) {
          EventPositionChanged(name, value);
        } else if (name.startsWith("dir")) {
          EventDirectionChanged(name, value);
        } else if (name == "cutoff") {
          print("set cutoff ${value}");
          //copyToScreen.ForceInput(uCutOff, value);
        }
      }
    });

    input.onMouseMove.listen(SwallowEvent);
  }

  for (HTML.Element e in HTML.document.getElementsByTagName("input")) {
    print("initialize inputs ${e.id}");
    e.dispatchEvent(new HTML.Event("change"));
    e.dispatchEvent(new HTML.Event("input"));
  }

  void resolutionChange(HTML.Event ev) {
    int w = canvas.clientWidth;
    int h = canvas.clientHeight;
    canvas.width = w;
    canvas.height = h;
    print("size change $w $h");
    w = w ~/ 2;
    perspective.AdjustAspect(w, h);
    phaseMain.viewPortW = w;
    phaseMain.viewPortH = h;
    // display shadowmap on right part of screen.
    shadowMap.SetVisualizationViewPort(phaseMain.viewPortW, 0, w, h);
  }

  resolutionChange(null);
  HTML.window.onResize.listen(resolutionChange);

  double _lastTimeMs = 0.0;

  //HTML.document.getElementById("posx").onChange.listen((HTML.Event ev) =>
  //light.pos.x = GetInputValue(ev));

  void animate(num timeMs) {
    double elapsed = timeMs - _lastTimeMs;
    _lastTimeMs = timeMs + 0.0;
    //orbit.azimuth += 0.001;
    orbit.animate(elapsed);

    VM.Matrix4 lm = gActiveLight.ExtractShadowProjViewMatrix();
    UpdateLightVisualizer(mdLight, gActiveLight);
    fps.ChangeExtra("${gActiveLight}");

    shadowMap.Compute(lm);
    uniforms.ForceUniform(uLightPerspectiveViewMatrix, lm);
    // render scene utilizing shadow map
    phaseMain.Draw();
    shadowMap.Visualize();

    HTML.window.animationFrame.then(animate);
    fps.UpdateFrameCount(timeMs);
  }

  animate(0.0);
}
