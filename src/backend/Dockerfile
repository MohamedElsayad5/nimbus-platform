# ==============================================================================
# NIMBUS PLATFORM — BACKEND DOCKERFILE
# Spring Boot application — multi-stage, distroless, non-root
#
# Final image size target: < 200MB
# Base runtime: gcr.io/distroless/java21-debian12
# Runs as: nonroot (UID 65532)
# ==============================================================================

# ------------------------------------------------------------------------------
# STAGE 1: DEPENDENCY CACHE
# Separate stage just to download Maven dependencies.
# This stage is only re-executed when pom.xml changes.
# On a typical code-only change, this entire stage is served from cache,
# saving 2-4 minutes of network time per CI build.
# ------------------------------------------------------------------------------
FROM maven:3.9.6-eclipse-temurin-21-alpine AS dependencies

WORKDIR /build

# Copy ONLY the pom.xml first.
# Docker layer caching: this layer is invalidated only when pom.xml changes.
# As long as dependencies don't change, this is always a cache hit.
COPY pom.xml .

# Download all dependencies into the local Maven repository.
# -B = batch mode (no interactive prompts, cleaner CI output)
# -e = show errors
# dependency:go-offline = download everything needed to build offline
RUN mvn -B -e dependency:go-offline

# ------------------------------------------------------------------------------
# STAGE 2: BUILD
# Compile the application and produce the executable JAR.
# Starts from the dependencies stage so the Maven cache is already populated.
# ------------------------------------------------------------------------------
FROM dependencies AS builder

WORKDIR /build

# Copy source code AFTER dependencies.
# This layer changes every time code changes, but the dependency layer above
# is still cached — so Maven compiles without re-downloading anything.
COPY src/ src/

# Build the application, skip tests (tests run in CI before Docker build).
# -DskipTests does not skip test compilation, only execution.
# Use -Dmaven.test.skip=true to skip compilation too (faster, but less safe).
RUN mvn -B -e -DskipTests package

# Extract the JAR into layers for better Docker caching.
# Spring Boot 2.3+ supports layered JARs. The layers are:
#   dependencies     → Spring Boot + third-party libs (rarely change)
#   spring-boot-loader → Spring Boot loader (rarely changes)
#   snapshot-dependencies → SNAPSHOT deps (change sometimes)
#   application      → your code (changes every build)
# Extracting layers means only your application layer is pushed on each build.
RUN java -Djarmode=layertools -jar target/*.jar extract --destination target/extracted

# ------------------------------------------------------------------------------
# STAGE 3: RUNTIME
# Minimal distroless image with just the JRE and the application.
# No shell. No package manager. No tools. Attack surface: near zero.
#
# gcr.io/distroless/java21-debian12 contains:
#   - OpenJDK 21 JRE (not JDK — no compiler)
#   - ca-certificates (for HTTPS outbound calls)
#   - tzdata (timezone support)
#   - glibc, libssl (runtime dependencies)
#
# It does NOT contain:
#   - bash, sh, or any shell
#   - curl, wget, apt, or any package manager
#   - Any other binaries
# ------------------------------------------------------------------------------
FROM gcr.io/distroless/java21-debian12 AS runtime

# nonroot is a built-in user in distroless images (UID 65532, GID 65532).
# Never run as root. If an attacker exploits the app, they get UID 65532
# which has no privileges on the host or other containers.
USER nonroot:nonroot

WORKDIR /app

# Copy the layered JAR contents from the builder stage.
# IMPORTANT: --chown=nonroot:nonroot ensures the files are owned by our user,
# not root. Without this, the nonroot user can't read them.
# Order matters: copy least-frequently-changing layers first.
COPY --chown=nonroot:nonroot --from=builder /build/target/extracted/dependencies/ ./
COPY --chown=nonroot:nonroot --from=builder /build/target/extracted/spring-boot-loader/ ./
COPY --chown=nonroot:nonroot --from=builder /build/target/extracted/snapshot-dependencies/ ./
COPY --chown=nonroot:nonroot --from=builder /build/target/extracted/application/ ./

# Expose the application port.
# This is documentation only — it doesn't actually publish the port.
# The actual port binding happens in Kubernetes Service/container spec.
EXPOSE 8080

# Actuator port for health checks (separate from app port for security).
# NetworkPolicy can allow probes on 8081 while blocking external access.
EXPOSE 8081

# Spring Boot environment configuration.
# These are defaults that can be overridden by Kubernetes ConfigMap/Secrets
# via environment variables or --spring.config.additional-location.
ENV SPRING_PROFILES_ACTIVE=prod \
    SERVER_PORT=8080 \
    MANAGEMENT_SERVER_PORT=8081 \
    # JVM heap tuning for e2-small nodes (2GB RAM total, shared with other pods).
    # -XX:MaxRAMPercentage=75 means: use at most 75% of available container memory
    # for the JVM heap. The container memory limit is set in Kubernetes.
    # This replaces fixed -Xms/-Xmx which are fragile in containerized environments.
    JAVA_OPTS="-XX:+UseContainerSupport \
               -XX:MaxRAMPercentage=75.0 \
               -XX:InitialRAMPercentage=50.0 \
               -XX:+UseG1GC \
               -XX:+UseStringDeduplication \
               -Djava.security.egd=file:/dev/./urandom \
               -Dspring.backgroundpreinitializer.ignore=true"

# Health check for Docker (separate from Kubernetes probes, but useful for
# local development with docker-compose).
# Kubernetes ignores this and uses its own probe configuration.
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD ["java", "-cp", "/app", "org.springframework.boot.loader.launch.JarLauncher", \
       "--spring.main.web-application-type=none", \
       "--management.endpoint.health.enabled=true"]

# Entry point uses the Spring Boot layered jar launcher.
# exec form (JSON array) is required — shell form would run as PID 2 under sh,
# which means SIGTERM from Kubernetes would not reach the Java process,
# breaking graceful shutdown.
ENTRYPOINT ["java", \
            "-XX:+UseContainerSupport", \
            "-XX:MaxRAMPercentage=75.0", \
            "-XX:InitialRAMPercentage=50.0", \
            "-XX:+UseG1GC", \
            "-XX:+UseStringDeduplication", \
            "-Djava.security.egd=file:/dev/./urandom", \
            "-Dspring.backgroundpreinitializer.ignore=true", \
            "org.springframework.boot.loader.launch.JarLauncher"]
