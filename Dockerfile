FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS build
WORKDIR /src

COPY ["mywebapp.csproj", "./"] 
RUN dotnet restore "./mywebapp.csproj" 
COPY . . 
WORKDIR "/src/." 

# To reproduce the bug, uncomment the dotnet build... line #15
# It will result in an error at runtime
#  realpath(): Permission denied
#  realpath(): Permission denied
#  realpath(): Permission denied

# RUN dotnet build "mywebapp.csproj" -c Release -o /app 
RUN dotnet publish "mywebapp.csproj" -c Release -o /app   

FROM mcr.microsoft.com/dotnet/core/aspnet:2.2 AS base 
WORKDIR /app 

ENV ASPNETCORE_URLS http://+:8080 
EXPOSE 8080     

WORKDIR /app 
COPY --from=build /app .   

RUN groupadd -r app &&\
     useradd -r -g app -s /sbin/nologin -c "Docker image user" app  

USER app  

ENTRYPOINT ["dotnet", "mywebapp.dll"]
