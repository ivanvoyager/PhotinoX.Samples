using System.Drawing;
using Photino.NET;

namespace HelloPhotino.ThreeD;

internal static class Program
{
    [STAThread]
    private static void Main()
    {
        const string windowTitle = "PhotinoX 3D Pong";

        var window = new PhotinoWindow()
            .SetTitle(windowTitle)
            .SetUseOsDefaultSize(false)
            .SetSize(new Size(1024, 800))
            .Center()
            .SetResizable(false)
            .Load("wwwroot/index.html");

        window.Show();
    }
}
