package com.secure.login.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

// ── Register Request ──────────────────────────────────────────────────────────
class RegisterRequest {
    @NotBlank
    @Size(min = 3, max = 50)
    public String username;

    @NotBlank
    @Email
    public String email;

    @NotBlank
    @Size(min = 8, max = 100)
    public String password;
}

// ── Login Request ─────────────────────────────────────────────────────────────
class LoginRequest {
    @NotBlank
    public String username;

    @NotBlank
    public String password;
}

// ── Auth Response ─────────────────────────────────────────────────────────────
class AuthResponse {
    public String token;
    public String tokenType = "Bearer";
    public String username;
    public String email;
}

// ── Error Response ─────────────────────────────────────────────────────────────
class ErrorResponse {
    public int status;
    public String error;
    public String message;
}

// Expose all as public top-level classes by making this a package-info style file.
// The actual classes are below as standalone files.
public class Dtos {
    public record RegisterRequestDto(
        @NotBlank @Size(min = 3, max = 50) String username,
        @NotBlank @Email String email,
        @NotBlank @Size(min = 8, max = 100) String password
    ) {}

    public record LoginRequestDto(
        @NotBlank String username,
        @NotBlank String password
    ) {}

    public record AuthResponseDto(
        String token,
        String tokenType,
        String username,
        String email
    ) {
        public AuthResponseDto(String token, String username, String email) {
            this(token, "Bearer", username, email);
        }
    }

    public record ErrorResponseDto(
        int status,
        String error,
        String message
    ) {}

    public record MessageResponseDto(String message) {}
}
