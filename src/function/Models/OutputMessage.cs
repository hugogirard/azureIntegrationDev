using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;

namespace Contoso;

public class OutputMessage
{
    [CosmosDBOutput("%CosmosDb%", "%CosmosContainerOut%", Connection = "CosmosDBConnection", CreateIfNotExists = false)]
    public InformationMessage CosmosRecord { get; set; }

    [ServiceBusOutput("%outputTopic%", Connection = "ServiceBusConnection")]
    public InformationMessage ServiceBusRecord { get; set; }

    public HttpResponseData HttpResponseData { get; set; }
}