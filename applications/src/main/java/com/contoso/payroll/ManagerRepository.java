package com.contoso.payroll;
import java.util.Optional;
import org.springframework.data.repository.Repository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

@RepositoryRestResource(exported = false)
public interface ManagerRepository extends Repository<Manager, Long> {
	Optional<Manager> findByName(String name);
	Manager save(Manager manager);
}



