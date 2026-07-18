using System.Drawing;
using System.Text;
using Photino.NET;
using Photino.NET.Server;

namespace HelloPhotino.StaticFileServer;

internal static class Program
{
    [STAThread]
    private static void Main(string[] args)
    {
        _ = PhotinoServer
            .CreateStaticFileServer(args, out var baseUrl)
            .RunAsync();

        const string windowTitle = "PhotinoX StaticFileServer";

        var app = new PhotinoApplication();

        var window = new PhotinoWindow()
            .SetTitle(windowTitle)
            .SetUseOsDefaultSize(false)
            .SetSize(new Size(800, 600))
            .Center()
            .SetResizable(false)
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
            .Load($"{baseUrl}/index.html");

        app.Run(window);
    }
}
