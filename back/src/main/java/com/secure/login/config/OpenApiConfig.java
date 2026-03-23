package com.secure.login.config;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Contact;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.info.License;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import io.swagger.v3.oas.annotations.servers.Server;
import org.springframework.context.annotation.Configuration;

@Configuration
@OpenAPIDefinition(
    info = @Info(
        title = "Secure Login Service API",
        version = "1.0.0",
        description = """
            RESTful API for secure user authentication with JWT.
            
            ## Security Features:
            - BCrypt password hashing (cost factor 12)
            - Stateless JWT authentication
            - TLS encryption (HTTPS)
            - Rate limiting on authentication endpoints
            
            ## Authentication Flow:
            1. Register a new user via POST /api/auth/register
            2. Login via POST /api/auth/login to receive JWT token
            3. Use the JWT token in Authorization header for protected endpoints
            """,
        contact = @Contact(
            name = "TDSE Workshop",
            email = "contact@example.com"
        ),
        license = @License(
            name = "MIT License",
            url = "https://opensource.org/licenses/MIT"
        )
    ),
    servers = {
        @Server(
            description = "Local Development",
            url = "http://localhost:8080"
        ),
        @Server(
            description = "Production (AWS)",
            url = "https://YOUR_DOMAIN"
        )
    }
)
@SecurityScheme(
    name = "Bearer Authentication",
    type = SecuritySchemeType.HTTP,
    bearerFormat = "JWT",
    scheme = "bearer",
    description = "Enter your JWT token received from /api/auth/login endpoint"
)
public class OpenApiConfig {
}
