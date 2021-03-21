using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class GrassManage : MonoBehaviour
{
    [Header("最大绘制数量")]
    public int maxCount = 100000;
    [Header("绘制模型")]
    public Mesh GrassMesh;
    [Header("绘制材质")]
    public Material GrassMaterial;
    private ComputeBuffer grassComputeBuffer;
    private uint[] args = new uint[5] { 0, 0, 0, 0, 0 };
    private ComputeBuffer argsComputeBuffer;
    private Bounds drawBounds = new Bounds(Vector3.zero, new Vector3(500.0f, 100.0f, 500.0f));
    private MaterialPropertyBlock mpb;
    private Camera _camera;

    [Header("草数量")]
    public int grassCount = 10000;
    private GrassInfo[] grassArr;
    [Header("填充范围")]
    public float fillRange = 500;
    [Header("发射高度")]
    public float SendHeight = 500;

    [Header("中心偏移")]
    public Vector3 GrassCenter;

    //[Header("脚印")]
    //public Stamp stamp;

    [Header("压低程度")]
    [Range(0, 1)]
    public float stampMin = .1f;

    public struct GrassInfo
    {
        public Vector4 position;
    }

    // Start is called before the first frame update
    void Start()
    {
        Init();
    }

    // Update is called once per frame
    void Init()
    {
        _camera = Camera.main;
        mpb = new MaterialPropertyBlock();
        grassComputeBuffer = new ComputeBuffer(maxCount, 16);
        argsComputeBuffer = new ComputeBuffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);

        args[0] = GrassMesh.GetIndexCount(0);
        args[1] = 0;
        args[2] = GrassMesh.GetIndexStart(0);
        args[3] = GrassMesh.GetBaseVertex(0);
    }

    void FillGrass()
    {
        grassArr = new GrassInfo[grassCount];
        float half = fillRange / 2;
        int i = grassCount - 1;
        int maxCount = grassCount * 2;
        while(i > 0 &&maxCount > 0)
        {
            Vector3 p = new Vector3();
            p.x = Random.Range(-half, half);
            p.y = SendHeight;
            p.z = Random.Range(-half, half);
            p += GrassCenter;
            if(GetGround(ref p))
            {
                grassArr[i].position = new Vector4(p.x, p.y, p.z, Random.Range(.5f, 1f));
                i--;
            }
            maxCount++;
        }
        //
        grassComputeBuffer.SetData(grassArr);
        GrassMaterial.SetBuffer("positionBuffer", grassComputeBuffer);
        args[1] = (uint)grassCount;
        argsComputeBuffer.SetData(args);
    }

    bool GetGround(ref Vector3 p)
    {
        Ray ray = new Ray(p, Vector3.down);
        RaycastHit hit;
        if(Physics.Raycast(ray,out hit,p.y + 10))
        {
            p = hit.point;
            return true;
        }
        return false;
    }

    private void Update()
    {
        DrawGrass();
        if(Input.GetKeyDown(KeyCode.G))
        {
            FillGrass();
        }
    }

    void DrawGrass()
    {
        if (GrassMesh == null || GrassMaterial == null)
            return;
        //if(stamp != null)
        //{
        //GrassMaterial.SetVector("_StampVector", new Vector4(stamp.Center.x, stampMin, stamp.Center.z, stamp.Size));
        //}   
        
        Graphics.DrawMeshInstancedIndirect(GrassMesh, 0, GrassMaterial, drawBounds, argsComputeBuffer, 0,
            mpb, ShadowCastingMode.Off, true, 0, _camera);
    }
}
