# Multi-stage build for Spring Boot backend
FROM maven:3.9-openjdk-17-slim AS build

# Set working directory
WORKDIR /app

# Copy pom.xml first for better layer caching
COPY pom.xml .

# Download dependencies
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build application
RUN mvn clean package -DskipTests

# Production stage with distroless image
FROM gcr.io/distroless/java17-debian11:nonroot

# Copy JAR from build stage
COPY --from=build /app/target/*.jar /app/app.jar

# Set working directory
WORKDIR /app

# Configure JVM memory settings
ENV JAVA_TOOL_OPTIONS="-Xmx512m -Xms256m -XX:+UseG1GC -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Expose port
EXPOSE 8080

# Health check using Java HTTP client (no curl needed in distroless)
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD java -cp app.jar org.springframework.boot.loader.JarLauncher --health-check || exit 1

# Run application as non-root user (distroless nonroot user)
ENTRYPOINT ["java", "-jar", "app.jar"]
