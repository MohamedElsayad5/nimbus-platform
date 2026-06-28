package com.nimbus.platform.controller;

import com.nimbus.platform.dto.ServiceDto;
import com.nimbus.platform.entity.ServiceEntity.ServiceStatus;
import com.nimbus.platform.service.PlatformService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "${cors.allowed-origins:http://localhost:5173}")
public class PlatformController {

    private final PlatformService platformService;

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("OK");
    }

    @GetMapping("/services")
    public ResponseEntity<List<ServiceDto.Response>> getAllServices() {
        return ResponseEntity.ok(platformService.getAllServices());
    }

    @GetMapping("/services/{id}")
    public ResponseEntity<ServiceDto.Response> getService(@PathVariable Long id) {
        return ResponseEntity.ok(platformService.getServiceById(id));
    }

    @GetMapping("/summary")
    public ResponseEntity<ServiceDto.Summary> getPlatformSummary() {
        return ResponseEntity.ok(platformService.getPlatformSummary());
    }

    @PatchMapping("/services/{id}/status")
    public ResponseEntity<ServiceDto.Response> updateStatus(
            @PathVariable Long id,
            @RequestParam ServiceStatus status) {
        return ResponseEntity.ok(platformService.updateServiceStatus(id, status));
    }
}
