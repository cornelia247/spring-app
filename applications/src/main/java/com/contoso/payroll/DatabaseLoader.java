package com.contoso.payroll;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class DatabaseLoader implements CommandLineRunner {

    private final EmployeeRepository employees;
    private final ManagerRepository managers;

    @Autowired
    public DatabaseLoader(EmployeeRepository employeeRepository,
                          ManagerRepository managerRepository) {

        this.employees = employeeRepository;
        this.managers = managerRepository;
    }

    @Override
    public void run(String... strings) throws Exception {

        // Check if managers already exist
        Manager greg = this.managers.findByName("greg")
        .orElseGet(() -> this.managers.save(new Manager("greg", "turnquist", "ROLE_MANAGER")));

        Manager oliver = this.managers.findByName("oliver")
        .orElseGet(() -> this.managers.save(new Manager("oliver", "gierke", "ROLE_MANAGER")));

        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken("greg", "doesn't matter",
                        AuthorityUtils.createAuthorityList("ROLE_MANAGER")));

        // Check if employees already exist
        saveEmployeeIfNotExists("Frodo", "Baggins", "ring bearer", greg);
        saveEmployeeIfNotExists("Bilbo", "Baggins", "burglar", greg);
        saveEmployeeIfNotExists("Gandalf", "the Grey", "wizard", greg);

        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken("oliver", "doesn't matter",
                        AuthorityUtils.createAuthorityList("ROLE_MANAGER")));

        saveEmployeeIfNotExists("Samwise", "Gamgee", "gardener", oliver);
        saveEmployeeIfNotExists("Merry", "Brandybuck", "pony rider", oliver);
        saveEmployeeIfNotExists("Peregrin", "Took", "pipe smoker", oliver);

        SecurityContextHolder.clearContext();
    }

    private void saveEmployeeIfNotExists(String firstName, String lastName, String role, Manager manager) {
        if (!employees.existsByFirstNameAndLastName(firstName, lastName)) {
            employees.save(new Employee(firstName, lastName, role, manager));
        }
    }
}