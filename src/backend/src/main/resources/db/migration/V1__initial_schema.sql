-- ==============================================================================
-- V1__initial_schema.sql
-- Initial database schema for Nimbus Platform.
-- Flyway naming convention: V{version}__{description}.sql
-- ==============================================================================

CREATE TABLE IF NOT EXISTS services
(
    id          BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    name        VARCHAR(100)     NOT NULL,
    description TEXT,
    status      ENUM ('RUNNING', 'DEGRADED', 'DOWN', 'UNKNOWN') NOT NULL DEFAULT 'UNKNOWN',
    region      VARCHAR(50)      NOT NULL,
    version     VARCHAR(50),
    uptime_pct  DECIMAL(5, 2)   NOT NULL DEFAULT 100.00,
    created_at  DATETIME(6)      NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at  DATETIME(6)      NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uq_services_name (name),
    INDEX idx_services_status (status),
    INDEX idx_services_region (region)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS incidents
(
    id           BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
    service_id   BIGINT UNSIGNED  NOT NULL,
    title        VARCHAR(255)     NOT NULL,
    description  TEXT,
    severity     ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') NOT NULL DEFAULT 'MEDIUM',
    status       ENUM ('OPEN', 'INVESTIGATING', 'IDENTIFIED', 'MONITORING', 'RESOLVED') NOT NULL DEFAULT 'OPEN',
    started_at   DATETIME(6)      NOT NULL,
    resolved_at  DATETIME(6),
    created_at   DATETIME(6)      NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at   DATETIME(6)      NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_incidents_service FOREIGN KEY (service_id) REFERENCES services (id) ON DELETE CASCADE,
    INDEX idx_incidents_service_id (service_id),
    INDEX idx_incidents_status (status),
    INDEX idx_incidents_severity (severity)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS metrics_snapshots
(
    id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    service_id   BIGINT UNSIGNED NOT NULL,
    cpu_pct      DECIMAL(5, 2)  NOT NULL,
    memory_pct   DECIMAL(5, 2)  NOT NULL,
    request_rate DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    error_rate   DECIMAL(5, 4)  NOT NULL DEFAULT 0.0000,
    p99_latency  INT UNSIGNED   NOT NULL DEFAULT 0 COMMENT 'milliseconds',
    snapshot_at  DATETIME(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_metrics_service FOREIGN KEY (service_id) REFERENCES services (id) ON DELETE CASCADE,
    INDEX idx_metrics_service_snapshot (service_id, snapshot_at)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
