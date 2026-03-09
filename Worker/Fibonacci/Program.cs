using Amazon.SQS;
using Fibonacci;

var builder = Host.CreateApplicationBuilder(args);
builder.Services.AddDefaultAWSOptions(builder.Configuration.GetAWSOptions());
builder.Services.AddAWSService<IAmazonSQS>();

builder.Services.AddHostedService<Worker>();

var host = builder.Build();
host.Run();
