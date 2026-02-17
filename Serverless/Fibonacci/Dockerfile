FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copia csproj e restaura dependências
COPY *.csproj .
RUN dotnet restore

# Copia o restante do código
COPY . .
RUN dotnet publish -c Release -o /app/publish

FROM public.ecr.aws/lambda/dotnet:10

WORKDIR /var/task
COPY --from=build /app/publish .

# Define o handler
CMD ["Fibonacci::Fibonacci.Function::FunctionHandler"]