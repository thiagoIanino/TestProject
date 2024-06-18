﻿# Fase base
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

# Copiar todo o restante do código
COPY . .

# Verificar a versão do dotnet-ef
RUN dotnet ef --version

# Compilar o projeto
WORKDIR "/src/TestingProject.Api"
RUN dotnet build "TestingProject.Api.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Fase de publicação
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "TestingProject.Api.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Fase para instalar dotnet-ef
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS tools
RUN dotnet tool install --global dotnet-ef
ENV PATH="/root/.dotnet/tools:${PATH}"

# Fase final
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY --from=tools /root/.dotnet /root/.dotnet
COPY --from=tools /usr/share/dotnet/sdk /usr/share/dotnet/sdk

# Copiar as migrações
COPY --from=build /src /src

ENTRYPOINT ["sh", "-c", "dotnet ef migrations add InitialMigration --project TestingProject.Infrastructure/TestingProject.Infrastructure.csproj --startup-project TestingProject.Api/TestingProject.Api.csproj && dotnet ef database update --no-build --project TestingProject.Infrastructure/TestingProject.Infrastructure.csproj --startup-project /src/TestingProject.Api/TestingProject.Api.csproj && dotnet TestingProject.Api.dll"]
