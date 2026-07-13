using System.Drawing;
using System.Text;
using Photino.NET;

namespace HelloPhotinoX;

internal static class Program
{
    [STAThread]
    private static void Main()
    {
        const string windowTitle = "PhotinoX Demo App";

        var window = new PhotinoWindow()
            .SetTitle(windowTitle)
            .SetUseOsDefaultSize(false)
            .SetSize(new Size(1024, 800))
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
            .Load("wwwroot/index.html");

        window.Show();
    }
}
