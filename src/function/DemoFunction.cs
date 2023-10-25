using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using FromBodyAttribute = Microsoft.Azure.Functions.Worker.Http.FromBodyAttribute;

namespace Contoso
{
    public class DemoFunction
    {
        private readonly ILogger _logger;

        public DemoFunction(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<DemoFunction>();
        }

        [Function("DemoFunction")]        
        public OutputMessage Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequestData req,
                                                     [FromBody] InputPayload payload)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");
            HttpResponseData response;
            try
            {
                response = req.CreateResponse(HttpStatusCode.OK);
                response.Headers.Add("Content-Type", "text/plain; charset=utf-8");
                response.WriteString("Welcome to Azure Functions!"); 

                InformationMessage record = new(payload.message,payload.by,"Azure Functions");

                return new OutputMessage
                {
                    CosmosRecord = record,
                    ServiceBusRecord = record,
                    HttpResponseData = response
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);                
            }        

            response = req.CreateResponse(HttpStatusCode.BadRequest);
            response.Headers.Add("Content-Type", "text/plain; charset=utf-8");
            response.WriteString("Something went wrong!"); 

            return new OutputMessage
            {
                HttpResponseData = response
            };

        }
    }
}
