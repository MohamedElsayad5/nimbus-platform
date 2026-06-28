package com.nimbus.platform.service;

import com.nimbus.platform.dto.ServiceDto;
import com.nimbus.platform.entity.ServiceEntity;
import com.nimbus.platform.entity.ServiceEntity.ServiceStatus;
import com.nimbus.platform.exception.ResourceNotFoundException;
import com.nimbus.platform.repository.ServiceRepository;
import io.micrometer.core.annotation.Timed;
import io.micrometer.core.instrument.MeterRegistry;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class PlatformService {

    private final ServiceRepository serviceRepository;
    private final MeterRegistry meterRegistry;

    @Cacheable(value = "services", key = "'all'")
    @Timed(value = "nimbus.services.fetch", description = "Time to fetch all services")
    public List<ServiceDto.Response> getAllServices() {
        log.info("Fetching all platform services from database");
        return serviceRepository.findAll()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Cacheable(value = "services", key = "#id")
    public ServiceDto.Response getServiceById(Long id) {
        return serviceRepository.findById(id)
                .map(this::toResponse)
                .orElseThrow(() -> new ResourceNotFoundException("Service not found with id: " + id));
    }

    @Cacheable(value = "platform-summary", key = "'summary'")
    @Timed(value = "nimbus.summary.fetch", description = "Time to compute platform summary")
    public ServiceDto.Summary getPlatformSummary() {
        long total    = serviceRepository.count();
        long running  = serviceRepository.countByStatus(ServiceStatus.RUNNING);
        long degraded = serviceRepository.countByStatus(ServiceStatus.DEGRADED);
        long down     = serviceRepository.countByStatus(ServiceStatus.DOWN);
        Double avgUptime = serviceRepository.findAverageUptimePct();

        meterRegistry.gauge("nimbus.services.running",  running);
        meterRegistry.gauge("nimbus.services.degraded", degraded);
        meterRegistry.gauge("nimbus.services.down",     down);

        return ServiceDto.Summary.builder()
                .totalServices(total)
                .runningServices(running)
                .degradedServices(degraded)
                .downServices(down)
                .overallUptimePct(avgUptime != null ? avgUptime : 0.0)
                .services(getAllServices())
                .build();
    }

    @Transactional
    @CacheEvict(value = {"services", "platform-summary"}, allEntries = true)
    public ServiceDto.Response updateServiceStatus(Long id, ServiceStatus newStatus) {
        ServiceEntity entity = serviceRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Service not found with id: " + id));

        log.info("Updating service '{}' status from {} to {}", entity.getName(), entity.getStatus(), newStatus);
        entity.setStatus(newStatus);
        ServiceEntity saved = serviceRepository.save(entity);

        meterRegistry.counter("nimbus.service.status.changes",
                "service", entity.getName(),
                "to", newStatus.name()
        ).increment();

        return toResponse(saved);
    }

    private ServiceDto.Response toResponse(ServiceEntity entity) {
        return ServiceDto.Response.builder()
                .id(entity.getId())
                .name(entity.getName())
                .description(entity.getDescription())
                .status(entity.getStatus())
                .region(entity.getRegion())
                .version(entity.getVersion())
                .uptimePct(entity.getUptimePct())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }
}
