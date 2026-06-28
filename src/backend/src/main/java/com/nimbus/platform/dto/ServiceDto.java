package com.nimbus.platform.dto;

import com.nimbus.platform.entity.ServiceEntity.ServiceStatus;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public class ServiceDto {

    @Data
    @Builder
    public static class Response {
        private Long id;
        private String name;
        private String description;
        private ServiceStatus status;
        private String region;
        private String version;
        private BigDecimal uptimePct;
        private Instant updatedAt;
    }

    @Data
    @Builder
    public static class Summary {
        private long totalServices;
        private long runningServices;
        private long degradedServices;
        private long downServices;
        private double overallUptimePct;
        private List<Response> services;
    }
}
