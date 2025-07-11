using UnityEngine;

[RequireComponent(typeof(Renderer))]
public class SdfBox : MonoBehaviour
{
    [Header("SDF Parameters")]
    [ColorUsage(true, true)]
    public Color mainColor = Color.white;
    [ColorUsage(true, true)]
    public Color edgeColor = Color.black;
    [Range(0, 0.5f)]
    public float edgeWidth = 0.1f;
    [Range(0, 1)]
    public float lengthX = 1f;
    [Range(0, 1)]
    public float lengthY = 1f;

    private static readonly int MainColorID = Shader.PropertyToID("_MainColor");
    private static readonly int EdgeColorID = Shader.PropertyToID("_EdgeColor");
    private static readonly int EdgeWidthID = Shader.PropertyToID("_EdgeWidth");
    private static readonly int LengthXID = Shader.PropertyToID("_Length_X");
    private static readonly int LengthYID = Shader.PropertyToID("_Length_Y");

    private Renderer _renderer;
    private MaterialPropertyBlock _propBlock;

    void Awake()
    {
        InitializeReferences();
        UpdateMaterialProperties();
    }

    void OnValidate()
    {
        InitializeReferences();
        UpdateMaterialProperties();
    }

    void Update()
    {
#if UNITY_EDITOR
        if (!Application.isPlaying)
        {
            UpdateMaterialProperties();
        }
#endif
    } 

    private void InitializeReferences()
    {
        if (_renderer == null)
            _renderer = GetComponent<Renderer>();

        if (_propBlock == null)
            _propBlock = new MaterialPropertyBlock();
    }

    private void UpdateMaterialProperties()
    {
        if (_renderer == null || _propBlock == null)
            return;

        _renderer.GetPropertyBlock(_propBlock);

        _propBlock.SetColor(MainColorID, mainColor);
        _propBlock.SetColor(EdgeColorID, edgeColor);
        _propBlock.SetFloat(EdgeWidthID, edgeWidth);
        _propBlock.SetFloat(LengthXID, lengthX);
        _propBlock.SetFloat(LengthYID, lengthY);

        _renderer.SetPropertyBlock(_propBlock);
    }

    private void Reset()
    {
        mainColor = Color.white;
        edgeColor = Color.black;
        edgeWidth = 0.1f;
        lengthX = 1.0f;
        lengthY = 1.0f;
        UpdateMaterialProperties();
    }
}