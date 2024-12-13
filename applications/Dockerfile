# Use Maven image to build the application
FROM maven:3.8.7-eclipse-temurin-17 AS build

# Set working directory
WORKDIR /app

# Copy the project files
COPY applications/. .

# Build the Spring Boot application
RUN mvn package 

# Use OpenJDK image for the runtime
FROM eclipse-temurin:17-jdk-jammy

# Set working directory
WORKDIR /app

# Copy the JAR file from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]