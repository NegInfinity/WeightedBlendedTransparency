using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class TransparentRender : MonoBehaviour{
	public Shader combinePass;
	RenderTexture baseColor = null;
	RenderTexture mrtARGB = null;
	RenderTexture mrtR = null;

	GameObject transparencyCamObj = null;
	Material combinePassMaterial = null;

	void releaseTex(ref RenderTexture tex){
		if(tex == null)
			return;
		RenderTexture.ReleaseTemporary(tex);
		tex = null;
	}

	void cleanup(){
		releaseTex(ref baseColor);
		releaseTex(ref mrtARGB);
		releaseTex(ref mrtR);
	}

	Material createMaterialForShader(Shader s, Material mat){
		if (!s){
			Debug.LogErrorFormat("Missing shader");
			return null;
		}
		if ((mat != null) && (mat.shader == s))
			return mat;
		var result = new Material(s);
		result.hideFlags = HideFlags.DontSave;
		return result;
	}

	// Use this for initialization
	void Start(){
		combinePassMaterial = createMaterialForShader(combinePass, combinePassMaterial);
	}

	void OnRenderImage(RenderTexture src, RenderTexture dst){
		if(!enabled || !gameObject.activeSelf)
			return;
		cleanup();
		
		Camera cam = GetComponent<Camera>();
		if (cam == null){
			Debug.LogErrorFormat("No camera attached");
			return;
		}

		baseColor = RenderTexture.GetTemporary(cam.pixelWidth, cam.pixelHeight, 16, RenderTextureFormat.ARGB32);
		mrtARGB = RenderTexture.GetTemporary(cam.pixelWidth, cam.pixelHeight, 0, RenderTextureFormat.ARGBFloat);
		mrtR = RenderTexture.GetTemporary(cam.pixelWidth, cam.pixelHeight, 0, RenderTextureFormat.ARGBFloat);

		if (!transparencyCamObj){
			transparencyCamObj = new GameObject("Transparency Camera");
			transparencyCamObj.hideFlags = HideFlags.DontSave;
			var newCam = transparencyCamObj.AddComponent<Camera>();
			newCam.enabled = false;
			newCam.hideFlags = HideFlags.HideAndDontSave;
		}
		
		var transparencyCam = transparencyCamObj.GetComponent<Camera>();

		var oldTex = RenderTexture.active;
		RenderTexture.active = mrtARGB;
		GL.Clear(false, true, new Color(0.0f, 0.0f, 0.0f, 0.0f));
		RenderTexture.active = mrtR;
		GL.Clear(false, true, new Color(1.0f, 0.0f, 0.0f, 1.0f));
		RenderTexture.active = baseColor;
		GL.ClearWithSkybox(true, transparencyCam);
		RenderTexture.active = oldTex;


		transparencyCam.CopyFrom(cam);

		RenderBuffer[] targetBuffers = {baseColor.colorBuffer, mrtARGB.colorBuffer, mrtR.colorBuffer};
		transparencyCam.clearFlags = CameraClearFlags.Nothing;
		transparencyCam.SetTargetBuffers(targetBuffers, baseColor.depthBuffer);
		transparencyCam.Render();

		transparencyCam.depthTextureMode = DepthTextureMode.Depth;

		combinePassMaterial.SetTexture("_Pass1Tex", mrtARGB);
		combinePassMaterial.SetTexture("_Pass2Tex", mrtR);
		combinePassMaterial.SetTexture("_ColorTex", baseColor);
		combinePassMaterial.SetTexture("_MainTex", src);

		Graphics.Blit(src, dst, combinePassMaterial);
	}

	void OnDisable(){
		if (transparencyCamObj){
			DestroyImmediate(transparencyCamObj);
			transparencyCamObj = null;
		}
	}

	// Update is called once per frame
	void Update(){
	
	}
}
