package com.contoso.payroll;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.rest.core.annotation.HandleBeforeCreate;
import org.springframework.data.rest.core.annotation.HandleBeforeSave;
import org.springframework.data.rest.core.annotation.RepositoryEventHandler;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
@RepositoryEventHandler(Employee.class)
public class SpringDataRestEventHandler {

	private final ManagerRepository managerRepository;

	@Autowired
	public SpringDataRestEventHandler(ManagerRepository managerRepository) {
		this.managerRepository = managerRepository;
	}

	@HandleBeforeCreate
	@HandleBeforeSave
	public void applyUserInformationUsingSecurityContext(Employee employee) {
	
		String name = SecurityContextHolder.getContext().getAuthentication().getName();
	
		// Use Optional to find an existing manager or create a new one
		Manager manager = this.managerRepository.findByName(name)
				.orElseGet(() -> {
					Manager newManager = new Manager();
					newManager.setName(name);
					newManager.setRoles(new String[]{"ROLE_MANAGER"});
					return this.managerRepository.save(newManager);
				});
	
		employee.setManager(manager);
	}
}
