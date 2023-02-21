# Use Alpine sdk Core 3.1 and set name 'build-env'
FROM mcr.microsoft.com/dotnet/core/sdk:3.1.201-alpine AS build-env  
RUN apk add --no-cache openssh-client

# Export 80 port
EXPOSE 80 				
									
# Change working Directory
WORKDIR /app 		
										
# copy /github_docker_deploy folder to current directory
COPY ./github_docker_deploy . 								
 
RUN dotnet restore
RUN dotnet build -c Release -o /out

# Project Published on out folder
RUN dotnet publish -c Release -o /out 						
 
# Runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1.3-alpine 

# Change working directory
WORKDIR /app

# copy /out folder from 'build-env' 
COPY --from=build-env /out .

# Start project   								
ENTRYPOINT ["dotnet", "github_docker_deploy.dll"] 			
