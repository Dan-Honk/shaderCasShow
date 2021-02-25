using UnityEngine;
using System.Collections;
using UnityEngine.Rendering;

public class OutLineEffect : MonoBehaviour
{
    private RenderTexture renderTexture = null;
    private CommandBuffer commandBuffer = null;

    public float samplerScale = 1;

    public int downSample = 1;

    public int iteration = 2;

    public Material _Material;

    [Range(0.0f,10.0f)]
    public float outLineStrength = 3.0f;

    public GameObject targetObject = null;

    void OnEnable()
    {
        Renderer[] renderes = targetObject.GetComponentsInChildren<Renderer>();
        if(renderTexture == null)
            renderTexture = RenderTexture.GetTemporary(Screen.width >> downSample, Screen.height >> downSample);
        commandBuffer = new CommandBuffer();
        commandBuffer.SetRenderTarget(renderTexture);
        commandBuffer.ClearRenderTarget(true,true,Color.black);
        foreach (Renderer r in renderes)
	        commandBuffer.DrawRenderer(r,r.sharedMaterial);
    }

    void OnDisable()
    {
        if(renderTexture)
        {
            RenderTexture.ReleaseTemporary(renderTexture);
            renderTexture = null;
        }
        if(commandBuffer != null)
        {
            commandBuffer.Release();
            commandBuffer = null;
        }
    }

    void OnRenderImage(RenderTexture source,RenderTexture destination)
    {
        if(_Material && renderTexture &&commandBuffer !=null)
        {
            Graphics.ExecuteCommandBuffer(commandBuffer);

            RenderTexture temp1 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0);
            RenderTexture temp2 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0);
            
            //高斯模糊
            _Material.SetVector("_offset",new Vector4(0,samplerScale,0,0));
            Graphics.Blit(renderTexture,temp1,_Material,0);
            _Material.SetVector("_offset",new Vector4(samplerScale,0,0,0));
            Graphics.Blit(temp1,temp2,_Material,0);

            for(int i = 0;i<iteration;i++)
            {
                _Material.SetVector("_offset",new Vector4(0,samplerScale,0,0));
                Graphics.Blit(temp2,temp1,_Material,0);
                _Material.SetVector("_offset",new Vector4(samplerScale,0,0,0));
                Graphics.Blit(temp1,temp2,_Material,0);
            }
            _Material.SetTexture("_BlurTex",temp1);
            _Material.SetFloat("_OutlineStrength",outLineStrength);
            Graphics.Blit(source,destination,_Material,2);

            RenderTexture.ReleaseTemporary(temp1);
            RenderTexture.ReleaseTemporary(temp2);
        }
        else
        {
            Graphics.Blit(source,destination);
        }
    }
}
