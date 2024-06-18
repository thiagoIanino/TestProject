# Fase base
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080

# Fase de construção
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

COPY ["TestingProject.Api/TestingProject.Api.csproj", "TestingProject.Api/"]
COPY ["TestingProject.Infrastructure/TestingProject.Infrastructure.csproj", "TestingProject.Infrastructure/"]

# Restaurar dependências
RUN dotnet restore "TestingProject.Api/TestingProject.Api.csproj"

# Copiar todo o restante do código
COPY . .

ENV PATH="$PATH:/root/.dotnet/tools"
RUN dotnet tool install --global dotnet-ef
# Copiar os arquivos de projeto
RUN dotnet ef migrations add InitialMigrationn --project TestingProject.Infrastructure/TestingProject.Infrastructure.csproj --startup-project TestingProject.Api/TestingProject.Api.csproj 

RUN dotnet ef database update --no-build --project TestingProject.Infrastructure/TestingProject.Infrastructure.csproj --startup-project /src/TestingProject.Api/TestingProject.Api.csproj

# Compilar o projeto
WORKDIR "/src/TestingProject.Api"
RUN dotnet build "TestingProject.Api.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Fase de publicação
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "TestingProject.Api.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Fase final
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

ENTRYPOINT ["dotnet", "TestingProject.Api.dll"]
