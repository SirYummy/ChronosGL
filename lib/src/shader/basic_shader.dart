part of chronosgl;

ShaderObject createBasicShader() {
  ShaderObject shaderObject = new ShaderObject();
  
  // TODO: think about multipying uPMatrix and uMVMatrix in Dart code...
  // or maybe cache the result in a static ?
  
  shaderObject.vertexShader = """
        precision mediump float;
        attribute vec3 aVertexPosition;
        attribute vec2 aTextureCoord;
        
        uniform mat4 uMVMatrix;
        uniform mat4 uPMatrix;
        
        varying vec2 vTextureCoord;
        
        void main(void) {
          gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
          vTextureCoord = aTextureCoord;
        }
        """;
  
  shaderObject.fragmentShader = """
        precision mediump float;
        
        varying vec2 vTextureCoord;
        uniform sampler2D uSampler;
        
        void main(void) {
          gl_FragColor = texture2D(uSampler, vTextureCoord);
        }
        """;
  
  shaderObject.vertexPositionAttribute = "aVertexPosition"; 
  shaderObject.textureCoordinatesAttribute = "aTextureCoord";
  shaderObject.modelViewMatrixUniform = "uMVMatrix";
  shaderObject.perpectiveMatrixUniform = "uPMatrix";
  shaderObject.textureSamplerUniform = "uSampler";
  
  return shaderObject;
}

ShaderObject createLightShader() {
  ShaderObject shaderObject = new ShaderObject();
  
  shaderObject.vertexShader = """
        precision mediump float;

        attribute vec3 aVertexPosition;
        attribute vec3 aNormal;
        
        uniform mat4 uMVMatrix;
        uniform mat4 uPMatrix;

        vec3 lightDir = vec3(1.0,0.0,1.0);
        vec3 ambientColor = vec3(0.0,0.0,0.0);
        vec3 directionalColor = vec3(1.0,1.0,1.0);

        vec3 pointLightLocation = vec3( 40, 0, 100);
        
        varying vec3 vLightWeighting;
        varying vec3 vNormal;

        void main(void) {
          gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
          vNormal = (uMVMatrix * vec4(aNormal, 0.0)).xyz;

          vec3 lightDir = normalize(pointLightLocation - aVertexPosition.xyz);

          float directionalLightWeighting = max(dot(vNormal, normalize(lightDir)), 0.0);
          vLightWeighting = ambientColor + directionalColor * directionalLightWeighting;
        }
        """;
  
  shaderObject.fragmentShader = """
        precision mediump float;
        
        varying vec3 vLightWeighting;
        varying vec3 vNormal;

        void main(void) {
          //gl_FragColor = vec4( vNormal * vLightWeighting, 1.0 );
          gl_FragColor = vec4( vLightWeighting, 1.0 );
        }
        """;
  
  shaderObject.vertexPositionAttribute = "aVertexPosition"; 
  shaderObject.normalAttribute = "aNormal";
  shaderObject.modelViewMatrixUniform = "uMVMatrix";
  shaderObject.perpectiveMatrixUniform = "uPMatrix";
  
  return shaderObject;
}

ShaderObject createNormal2ColorShader() {
  ShaderObject shaderObject = new ShaderObject();
  
  shaderObject.vertexShader = """
        precision mediump float;

        attribute vec3 aVertexPosition;
        attribute vec3 aNormal;
        
        uniform mat4 uMVMatrix;
        uniform mat4 uPMatrix;
        
        varying vec3 vColor;

        void main(void) {
          gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
          vColor=normalize( aNormal / 2.0 + vec3(0.5) );
        }
        """;
  
  shaderObject.fragmentShader = """
        precision mediump float;
        
        varying vec3 vColor;

        void main(void) {
          gl_FragColor = vec4( vColor, 1.0 );
        }
        """;
  
  shaderObject.vertexPositionAttribute = "aVertexPosition"; 
  shaderObject.normalAttribute = "aNormal";
  shaderObject.modelViewMatrixUniform = "uMVMatrix";
  shaderObject.perpectiveMatrixUniform = "uPMatrix";
  
  return shaderObject;
}

ShaderObject createPointSpritesShader() {
  ShaderObject shaderObject = new ShaderObject();
  
  shaderObject.vertexShader = """
        precision mediump float;
        attribute vec3 aVertexPosition;
        
        uniform mat4 uMVMatrix;
        uniform mat4 uPMatrix;
        
        void main(void) {
          gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
          gl_PointSize = 1000.0/gl_Position.z;
        }
        """;
  
  shaderObject.fragmentShader = """
        precision mediump float;

        uniform sampler2D uSampler;
        
        void main(void) {
          gl_FragColor = texture2D(uSampler, gl_PointCoord);
          gl_FragColor.a = 0.4;
        }
        """;
  
  shaderObject.vertexPositionAttribute = "aVertexPosition"; 
  shaderObject.modelViewMatrixUniform = "uMVMatrix";
  shaderObject.perpectiveMatrixUniform = "uPMatrix";
  shaderObject.textureSamplerUniform = "uSampler";
  return shaderObject;
}
