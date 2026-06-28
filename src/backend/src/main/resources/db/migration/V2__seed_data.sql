-- ==============================================================================
-- V2__seed_data.sql
-- Initial seed data for the Nimbus Platform dashboard.
-- ==============================================================================

INSERT INTO services (name, description, status, region, version, uptime_pct)
VALUES ('API Gateway', 'Primary ingress point for all external traffic', 'RUNNING', 'us-central1', 'v2.4.1', 99.97),
       ('Auth Service', 'Authentication and authorization microservice', 'RUNNING', 'us-central1', 'v1.8.0', 99.99),
       ('Data Pipeline', 'Real-time event streaming and processing', 'RUNNING', 'us-central1', 'v3.1.2', 99.85),
       ('Storage Service', 'Object and blob storage abstraction layer', 'DEGRADED', 'us-east1', 'v1.2.0', 97.30),
       ('Notification Service', 'Email, SMS, and push notification delivery', 'RUNNING', 'eu-west1', 'v2.0.5', 99.91),
       ('Analytics Engine', 'Batch and real-time analytics processing', 'RUNNING', 'us-central1', 'v4.0.0', 99.78);
