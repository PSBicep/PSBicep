namespace PSBicep.LoadContext;

public static class BicepLoader
{
    private static Core.PSBicep _psBicep;
    private static readonly object _initLock = new object();

    public static Core.PSBicep PSBicep
    {
        get
        {
            if (_psBicep == null)
            {
                lock (_initLock)
                {
                    _psBicep ??= new Core.PSBicep();
                }
            }
            return _psBicep;
        }
        set => _psBicep = value;
    }
}
