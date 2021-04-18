using UnityEngine;
[ExecuteAlways]
public class GaussBlurCtrl : MonoBehaviour
{
    public Material curMaterial;
    // 采样率
    public int samplerScale = 1;
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        // 申请两块RT，并且分辨率按照downSample降低
        RenderTexture temp1 = RenderTexture.GetTemporary(1080,720);

        // 高斯模糊，两次模糊，横向纵向，使用pass1进行高斯模糊
        curMaterial.SetVector("_offsets", new Vector4(0, samplerScale, 0, 0));
        Graphics.Blit(src, temp1, curMaterial);
        curMaterial.SetVector("_offsets", new Vector4(samplerScale, 0, 0, 0));
        Graphics.Blit(temp1, dest, curMaterial);

        // 释放申请的RT
        RenderTexture.ReleaseTemporary(temp1);
    }
}