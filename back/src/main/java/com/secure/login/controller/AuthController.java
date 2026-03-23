package com.secure.login.controller;

import com.secure.login.dto.Dtos.*;
import com.secure.login.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Authentication", description = "User authentication and registration endpoints")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    /**
     * POST /api/auth/register
     * Register a new user. Password is stored as BCrypt hash.
     */
    @Operation(
        summary = "Register a new user",
        description = "Creates a new user account with BCrypt hashed password",
        responses = {
            @ApiResponse(responseCode = "200", description = "User registered successfully"),
            @ApiResponse(responseCode = "400", description = "Invalid input or username already exists", content = @Content)
        }
    )
    @PostMapping("/register")
    public ResponseEntity<MessageResponseDto> register(@Valid @RequestBody RegisterRequestDto request) {
        MessageResponseDto response = authService.register(request);
        return ResponseEntity.ok(response);
    }

    /**
     * POST /api/auth/login
     * Authenticate and receive a JWT token.
     */
    @Operation(
        summary = "Login",
        description = "Authenticate with username and password, returns JWT token for subsequent requests",
        responses = {
            @ApiResponse(
                responseCode = "200", 
                description = "Login successful, JWT token returned",
                content = @Content(schema = @Schema(implementation = AuthResponseDto.class))
            ),
            @ApiResponse(responseCode = "401", description = "Invalid credentials", content = @Content)
        }
    )
    @PostMapping("/login")
    public ResponseEntity<AuthResponseDto> login(@Valid @RequestBody LoginRequestDto request) {
        AuthResponseDto response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    /**
     * GET /api/auth/me
     * Protected endpoint — returns current user info from the JWT.
     */
    @Operation(
        summary = "Get current user",
        description = "Returns information about the currently authenticated user (requires valid JWT token)",
        security = @SecurityRequirement(name = "Bearer Authentication"),
        responses = {
            @ApiResponse(responseCode = "200", description = "User information retrieved successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized - invalid or missing JWT token", content = @Content)
        }
    )
    @GetMapping("/me")
    public ResponseEntity<?> me(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(new MessageResponseDto("Authenticated as: " + userDetails.getUsername()));
    }
}
