using UnityEngine;
using System.Collections;

public class MrtRenderHelper : MonoBehaviour {
	public RenderTexture colorTex;
	public RenderTexture argbFloatTex;
	public RenderTexture rFloatTex;

	// Use this for initialization
	void Start () {
		Camera cam = GetComponent<Camera>();
		if (cam == null){
			return;
		}
		if ((argbFloatTex == null) || (rFloatTex == null)){
			return;
		}

		RenderBuffer[] buffers = {colorTex.colorBuffer, argbFloatTex.colorBuffer, rFloatTex.colorBuffer};

		cam.SetTargetBuffers(buffers, colorTex.depthBuffer);
	}

	void OnPreRender(){
		var old = RenderTexture.active;

		if (argbFloatTex != null){
			RenderTexture.active = argbFloatTex;
			GL.Clear(false, true, new Color(0.0f, 0.0f, 0.0f, 0.0f));
		}
		if (rFloatTex != null){
			RenderTexture.active = rFloatTex;
			GL.Clear(false, true, new Color(1.0f, 0.0f, 0.0f, 1.0f));
		}
		if (colorTex != null){
			RenderTexture.active = colorTex;
			GL.ClearWithSkybox(true, GetComponent<Camera>());
		}

		RenderTexture.active = old;
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
