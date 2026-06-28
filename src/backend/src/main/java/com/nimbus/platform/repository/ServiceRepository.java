package com.nimbus.platform.repository;

import com.nimbus.platform.entity.ServiceEntity;
import com.nimbus.platform.entity.ServiceEntity.ServiceStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ServiceRepository extends JpaRepository<ServiceEntity, Long> {

    List<ServiceEntity> findByStatus(ServiceStatus status);

    List<ServiceEntity> findByRegion(String region);

    long countByStatus(ServiceStatus status);

    @Query("SELECT AVG(s.uptimePct) FROM ServiceEntity s")
    Double findAverageUptimePct();
}
