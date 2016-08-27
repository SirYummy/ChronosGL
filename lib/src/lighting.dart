part of chronosgl;

int typeLightNone = 1;
int typeLightSpot = 2;
int typeLightPoint = 3;
int typeLightHemi = 4;
int typeLightDir = 5;

class Light {
  int _type;
  VM.Vector3 _pos = new VM.Vector3.zero();
  VM.Vector3 _dir = new VM.Vector3.zero();
  VM.Vector3 _colDiffuse = new VM.Vector3.zero();
  VM.Vector3 _colSpecular = new VM.Vector3.zero();
  VM.Vector3 _colGround = new VM.Vector3.zero(); // for Hemisperical
  double _range = 0.0; // for spot and point
  double _spotCutoff = 0.0; // for spot
  double _spotFocus = 0.0; // for spot

  // Light eminating from a point in all directions.
  // Light gets "weaker" with increased distance.
  Light.Point(this._pos, this._colDiffuse, this._colSpecular, this._range) {
    _type = typeLightPoint;
  }

  // Light cone eminating from a point.
  // As the cone widens light gets "weaker"
  Light.Spot(this._pos, this._dir, this._colDiffuse, this._colSpecular,
      this._spotCutoff, this._spotFocus) {
    _type = typeLightSpot;
  }

  // Coming from one direction at infinite distance - e.g. the sun
  Light.Directional(this._dir, this._colDiffuse, this._colSpecular) {
    _type = typeLightDir;
  }

  Light.Hemispherical(
      this._dir, this._colDiffuse, this._colGround, this._colSpecular) {
    _type = typeLightHemi;
  }

  // This needs to stay in sync with UnpackLightSourceInfo
  // in the shader
  VM.Matrix4 PackInfo() {
    VM.Matrix4 m = new VM.Matrix4.zero();
    // do pos or ground
    if (_type == typeLightHemi) {
      m[0] = _colGround.x;
      m[1] = _colGround.y;
      m[2] = _colGround.z;
    } else {
      // do position
      m[0] = _pos.x;
      m[1] = _pos.y;
      m[2] = _pos.z;
    }
    // do dir
    m[4] = _dir.x;
    m[5] = _dir.y;
    m[6] = _dir.z;
    //
    m[8] = _colDiffuse.x;
    m[9] = _colDiffuse.y;
    m[10] = _colDiffuse.z;
    //
    m[12] = _colSpecular.x;
    m[13] = _colSpecular.y;
    m[14] = _colSpecular.z;
    //
    //
    m[3] = _type + 0.0;
    m[7] = _range;
    m[11] = _spotCutoff;
    m[15] = _spotFocus;
    return m;
  }
}
