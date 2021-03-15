using System.Collections;
using System.Collections.Generic;
using UnityEngine;

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

    }
}
