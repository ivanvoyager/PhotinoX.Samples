using System.Drawing;
using System.Text;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;
using Photino.NET;

namespace HelloPhotino.GRpc;

//https://github.com/grpc/grpc-web/tree/master/net/grpc/gateway/examples/helloworld#write-client-code
internal static class Program
{
    [STAThread]
    private static void Main(string[] args)
    {
        _ = CreateHostBuilder(args).Build().RunAsync();

        const string windowTitle = "PhotinoX, gRPC enabled";

        var app = new PhotinoApplication();

        var window = new PhotinoWindow()
            .SetTitle(windowTitle)
            .SetUseOsDefaultSize(false)
            .SetSize(new Size(800, 400))
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

        app.Run(window);
    }

    private static IHostBuilder CreateHostBuilder(string[] args)
    {
        return Host.CreateDefaultBuilder(args)
            .ConfigureWebHostDefaults(webBuilder =>
            {
                webBuilder.UseStartup<Startup>();
            });
    }
}
