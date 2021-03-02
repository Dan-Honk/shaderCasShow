using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TransparentControl : MonoBehaviour
{
    // Start is called before the first frame update
    public class TransparentParm
    {
        public Material[] materials = null;
        public Material[] shaderMats = null;
        public float currentFadeTime = 0;
        public bool isTransparent = true;
    }

    public Transform targetObject = null;
    public float height = 3.0f;
    public float destTransparent = 0.2f;
    public float fadeInTime = 1.0f;
    private int transparentLayer;
    private Dictionary<Renderer, TransparentParm> transparentDic = new Dictionary<Renderer, TransparentParm>();
    private List<Renderer> clearList = new List<Renderer>();

    private void Start()
    {
        transparentLayer = 1 << LayerMask.NameToLayer("OcclusionTran");
    }

    // Update is called once per frame
    void Update()
    {
        if (targetObject == null)
            return;
        UpdateTransparentObject();

    }

    public void UpdateTransparentObject()
    {
        var var = transparentDic.GetEnumerator();
        while(var.MoveNext())
        {
            TransparentParm param = var.Current.Value;
            param.isTransparent = false;
            foreach (var mat in param.materials)
            {
                Color col = mat.GetColor("_Color");
                param.currentFadeTime += Time.deltaTime;
                float t = param.currentFadeTime / fadeInTime;
                col.a = Mathf.Lerp(1, destTransparent, t);
                mat.SetColor("_Color", col);
            }
        }
    }

    public void UpdateRayCastHit()
    {
        RaycastHit[] rayHits = null;
        Vector3 targetPos = targetObject.position + new Vector3(0, height, 0);
        Vector3 viewDir = (targetPos - transform.position).normalized;
        Vector3 oriPos = transform.position;
        float distance = Vector3.Distance(oriPos, targetPos);
        Ray ray = new Ray(oriPos, viewDir);
        rayHits = Physics.RaycastAll(ray, distance, transparentLayer);
        Debug.DrawLine(oriPos, viewDir);
        foreach (var hit in rayHits)
        {
            Renderer[] renderers = hit.collider.GetComponentsInChildren<Renderer>();
            foreach (Renderer r in renderers)
            {
                AddTransparent(r);
            }
        }
    }

    public void RemoveUnuseTransparent()
    {
        clearList.Clear();
        var var = transparentDic.GetEnumerator();
        while(var.MoveNext())
        {
            if(var.Current.Value.isTransparent == false)
            {
                var.Current.Key.materials = var.Current.Value.shaderMats;
                clearList.Add(var.Current.Key);
            }
        }
        foreach (var v in clearList)
            transparentDic.Remove(v);
    }

    void AddTransparent(Renderer renderer)
    {
        TransparentParm param = null;
        transparentDic.TryGetValue(renderer, out param);
        if(param == null)
        {
            param = new TransparentParm();
            transparentDic.Add(renderer, param);
            param.shaderMats = renderer.sharedMaterials;

        }    
    }
}
