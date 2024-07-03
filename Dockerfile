# Use the appropriate .NET runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
RUN apt update -y && apt upgrade -y && apt install -y procps && apt -y install bash && apt -y install mc
EXPOSE 80

# Use the .NET SDK 8.0 for building the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

ARG GITHUB_ORG
ARG GITHUB_REPO
ARG GITHUB_BRANCH
ARG GITHUB_USER
ARG GITHUB_PAT
ARG BUILD_CONFIGURATION=Release

WORKDIR /src

RUN apt-get update && apt-get install -y git
RUN git clone --branch ${GITHUB_BRANCH} https://${GITHUB_USER}:${GITHUB_PAT}@github.com/${GITHUB_ORG}/${GITHUB_REPO}.git .
RUN dotnet restore "./RSI.Reporting.Api/RSI.Reporting.Api.csproj"

# Copy the remaining files and build the project
COPY . .
WORKDIR "/src/RSI.Reporting.Api"
RUN dotnet build "./RSI.Reporting.Api.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./RSI.Reporting.Api.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "RSI.Reporting.Api.dll"]
