FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY *.csproj .
RUN dotnet restore

COPY . .
RUN dotnet publish -c Release -r linux-x64 --self-contained false -o /app/publish 

FROM public.ecr.aws/lambda/dotnet:10
WORKDIR /var/task
COPY --from=build /app/publish .

# Define o handler
CMD ["Fibonacci::Fibonacci.Function::FunctionHandler"]