using System.Drawing;
using System.Text;
using Photino.NET;
using Photino.NET.Server;

namespace HelloPhotino.React;

internal static class Program
{
#if DEBUG
    private const bool IsDebugMode = true;
#else
    private const bool IsDebugMode = false;
#endif

    [STAThread]
    private static void Main(string[] args)
    {
        _ = PhotinoServer
            .CreateStaticFileServer(args, out var baseUrl)
            .RunAsync();

        var appUrl = IsDebugMode
            ? "http://localhost:3000"
            : $"{baseUrl}/index.html";

        Console.WriteLine($"Serving React app at {appUrl}");

        const string windowTitle = "PhotinoX.React Demo App";

        var app = new PhotinoApplication();

        var window = new PhotinoWindow()
            .SetTitle(windowTitle)
            .SetUseOsDefaultSize(false)
            .SetSize(new Size(800, 600))
            .Center()
            .SetResizable(true)
            .RegisterCustomSchemeHandler("app", (_, _, _, out contentType) =>
            {
                contentType = "text/javascript";

                return new MemoryStream(Encoding.UTF8.GetBytes("""
                    (() => {
                        window.setTimeout(() => {
                            alert(`🎉 Dynamically inserted JavaScript.`);
                        }, 1000);
                    })();
                    """));
            })
            .RegisterWebMessageReceivedHandler((sender, message) =>
            {
                var window = (PhotinoWindow)sender!;
                var response = $"Received message: \"{message}\"";

                window.SendWebMessage(response);
            })
            .Load(appUrl);

        app.Run(window);
    }
}
