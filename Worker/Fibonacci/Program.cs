using Amazon.SQS;

var builder = Host.CreateApplicationBuilder(args);
builder.Services.AddDefaultAWSOptions(builder.Configuration.GetAWSOptions());
builder.Services.AddAWSService<IAmazonSQS>();

var host = builder.Build();
host.Run();
