package com.secure.login.service;

import com.secure.login.dto.Dtos.*;
import com.secure.login.model.User;
import com.secure.login.repository.UserRepository;
import com.secure.login.security.JwtUtils;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Set;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtUtils jwtUtils;

    public AuthService(UserRepository userRepository,
                       PasswordEncoder passwordEncoder,
                       AuthenticationManager authenticationManager,
                       JwtUtils jwtUtils) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
        this.jwtUtils = jwtUtils;
    }

    /**
     * Register a new user.
     * Password is hashed with BCrypt (cost 12) before being stored.
     */
    @Transactional
    public MessageResponseDto register(RegisterRequestDto request) {
        if (userRepository.existsByUsername(request.username())) {
            throw new IllegalArgumentException("Username is already taken.");
        }
        if (userRepository.existsByEmail(request.email())) {
            throw new IllegalArgumentException("Email is already registered.");
        }

        User user = User.builder()
                .username(request.username())
                .email(request.email())
                // BCrypt hash — plain text password never touches the DB
                .password(passwordEncoder.encode(request.password()))
                .roles(Set.of("USER"))
                .enabled(true)
                .build();

        userRepository.save(user);
        return new MessageResponseDto("User registered successfully.");
    }

    /**
     * Authenticate user and return a signed JWT.
     */
    public AuthResponseDto login(LoginRequestDto request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.username(), request.password())
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = jwtUtils.generateToken(authentication);

        User user = userRepository.findByUsername(request.username())
                .orElseThrow(() -> new IllegalStateException("User not found after auth"));

        return new AuthResponseDto(jwt, user.getUsername(), user.getEmail());
    }
}
