FROM mcr.microsoft.com/dotnet/aspnet:10.0 as base
WORKDIR /app

EXPOSE 8080
EXPOSE 8081
EXPOSE 80

ENV ASPNETCORE_URLS=http://+:8080

FROM mcr.microsoft.com/dotnet/sdk:10.0 as build
ARG BUILD_CONFIGURATION=Release

WORKDIR /src

COPY ["src/MasterNet.WebApi/MasterNet.WebApi.csproj", "src/MasterNet.WebApi/"]
COPY ["src/MasterNet.Application/MasterNet.Application.csproj", "src/MasterNet.Application/"]
COPY ["src/MasterNet.Infrastructure/MasterNet.Infrastructure.csproj", "src/MasterNet.Infrastructure/"]
COPY ["src/MasterNet.Domain/MasterNet.Domain.csproj", "src/MasterNet.Domain/"]
COPY ["src/MasterNet.Persistence/MasterNet.Persistence.csproj", "src/MasterNet.Persistence/"]

RUN dotnet restore "src/MasterNet.WebApi/MasterNet.WebApi.csproj"

COPY . .

WORKDIR "/src/src/MasterNet.WebApi"
RUN dotnet build "MasterNet.WebApi.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "MasterNet.WebApi.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false


FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT [ "dotnet", "MasterNet.WebApi.dll" ]





