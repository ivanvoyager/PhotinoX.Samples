using Photino.NET;

namespace HelloPhotino.MultiWindow;

internal static class Program
{
    private static readonly Random s_random = new();
    private static int s_childCount;

    [STAThread]
    private static void Main()
    {
        new PhotinoWindow()
            .SetTitle("Main Window")
            .RegisterWebMessageReceivedHandler(CloseWindowMessageDelegate)
            .RegisterWebMessageReceivedHandler(NewWindowMessageDelegate)
            .SetUseOsDefaultSize(false)
            .SetWidth(600)
            .SetHeight(400)
            .Center()
            .Load("wwwroot/main.html")
            .Show();
    }

    private static void CloseWindowMessageDelegate(object? sender, string message)
    {
        if (message != "close-window")
            return;

        var window = (PhotinoWindow)sender!;

        Console.WriteLine($"Closing \"{window.Title}\".");
        window.Close();
    }

    private static void NewWindowMessageDelegate(object? sender, string message)
    {
        if (message != "random-window")
            return;

        var parent = (PhotinoWindow)sender!;

        var workAreaWidth = parent.MainMonitor.WorkArea.Width;
        var workAreaHeight = parent.MainMonitor.WorkArea.Height;

        var width = s_random.Next(400, 800);
        var height = (int)Math.Round(width * 0.625, 0);

        const int offset = 20;
        var left = s_random.Next(offset, workAreaWidth - width - offset);
        var top = s_random.Next(offset, workAreaHeight - height - offset);

        s_childCount++;

        new PhotinoWindow(parent)
            .SetTitle($"Random Window ({s_childCount})")
            .SetUseOsDefaultSize(false)
            .SetHeight(height)
            .SetWidth(width)
            .SetUseOsDefaultLocation(false)
            .SetTop(top)
            .SetLeft(left)
            .RegisterWebMessageReceivedHandler(CloseWindowMessageDelegate)
            .Load("wwwroot/random.html")
            .Show();
    }
}
