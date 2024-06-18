# Fase base
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS base

USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Fase de construção
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copiar os arquivos de projeto
COPY ["TestingProject.Api/TestingProject.Api.csproj", "TestingProject.Api/"]
COPY ["TestingProject.Infrastructure/TestingProject.Infrastructure.csproj", "TestingProject.Infrastructure/"]

# Restaurar dependências
RUN dotnet restore "TestingProject.Api/TestingProject.Api.csproj"

ENV PATH="$PATH:/root/.dotnet/tools"
RUN printenv
RUN dotnet tool install --global dotnet-ef



# Copiar todo o restante do código
COPY . .

RUN dotnet ef --version
RUN dotnet ef migrations add InitialMigration --project TestingProject.Infrastructure/TestingProject.Infrastructure.csproj --startup-project TestingProject.Api/TestingProject.Api.csproj
RUN dotnet dotnet ef database update --project TestingProject.Infrastructure/TestingProject.Infrastructure.csproj --startup-project TestingProject.Api/TestingProject.Api.csproj
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
