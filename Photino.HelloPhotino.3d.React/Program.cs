using System.Drawing;
using Photino.NET;

namespace HelloPhotinoReact3D;

internal static class Program
{
    [STAThread]
    private static void Main()
    {
        const string windowTitle = "PhotinoX.React 3D App";

        var window = new PhotinoWindow()
            .SetTitle(windowTitle)
            .SetUseOsDefaultSize(false)
            .SetSize(new Size(2048, 1024))
            .Center()
            .SetResizable(false)
            .Load("wwwroot/index.html");

        window.Show();
    }
}
