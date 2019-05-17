#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform sampler2D CC_Texture0;

uniform mat4 vColor;
uniform vec4 vOffset;
uniform vec4 vMinColor;

void main() {
	vec4 textureColor = texture2D(CC_Texture0, v_texCoord);
    textureColor = max(textureColor, vMinColor);            //avoid division through zero in next step 
    textureColor.xyz = textureColor.xyz / textureColor.www; //restore original (non-PMA) RGB values
	textureColor = textureColor * vColor  + vOffset;                   //multiply color with 4x4 matrix with offset
    textureColor.xyz = textureColor.xyz * textureColor.www; // multiply with alpha again (PMA)
    gl_FragColor = textureColor * v_fragmentColor;
}
