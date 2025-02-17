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
    public float radius = 0.5f;

    private static readonly int MainColorID = Shader.PropertyToID("_MainColor");
    private static readonly int EdgeColorID = Shader.PropertyToID("_EdgeColor");
    private static readonly int EdgeWidthID = Shader.PropertyToID("_EdgeWidth");
    private static readonly int RadiusID = Shader.PropertyToID("_Radius");

    private Renderer _renderer;
    private MaterialPropertyBlock _propBlock;

    void Awake()
    {
        InitializeReferences();
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
        _propBlock.SetFloat(RadiusID, radius);

        _renderer.SetPropertyBlock(_propBlock);
    }

    private void Reset()
    {
        mainColor = Color.white;
        edgeColor = Color.black;
        edgeWidth = 0.1f;
        radius = 0.5f;
        UpdateMaterialProperties();
    }
}