using System.Drawing;
using System.Text;
using Photino.NET;
using Photino.NET.Server;

namespace HelloPhotino.Vue;

internal static class Program
{
#if DEBUG
    private static readonly bool IsDebugMode = true;
#else
    private static readonly bool IsDebugMode = false;
#endif

    [STAThread]
    private static void Main(string[] args)
    {
        string appUrl;

        if (IsDebugMode)
        {
            appUrl = "http://localhost:5173";
            Console.WriteLine($"Debug mode: make sure the local development server is running at {appUrl}.");
        }
        else
        {
            _ = PhotinoServer
                .CreateStaticFileServer(args, out var baseUrl)
                .RunAsync();

            appUrl = $"{baseUrl}/index.html";
        }

        Console.WriteLine($"Serving Vue app at {appUrl}");

        const string windowTitle = "PhotinoX.Vue Demo App";

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
