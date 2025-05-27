import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { LoggerService } from '../core/logger/logger.service';
import { ExceptionService } from '../core/exception/exception.service';
import { UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';

// Mock bcrypt module
jest.mock('bcrypt', () => ({
  compare: jest.fn(),
  hash: jest.fn(),
  genSalt: jest.fn(),
}));

describe('AuthService', () => {
  let service: AuthService;
  let jwtService: JwtService;

  const mockUser = {
    id: 'test-id',
    email: 'test@example.com',
    password: 'hashed_password',
    firstName: 'Test',
    lastName: 'User',
    role: 'user',
  };

  const mockUsersService = {
    findByEmail: jest.fn(),
    findById: jest.fn(),
    create: jest.fn(),
    updateLastLogin: jest.fn(),
  };

  const mockJwtService = {
    sign: jest.fn(),
    verify: jest.fn(),
  };

  const mockConfigService = {
    get: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: UsersService,
          useValue: mockUsersService,
        },
        {
          provide: JwtService,
          useValue: mockJwtService,
        },
        {
          provide: ConfigService,
          useValue: mockConfigService,
        },
        {
          provide: LoggerService,
          useValue: {
            setContext: jest.fn(),
            log: jest.fn(),
            error: jest.fn(),
            debug: jest.fn(),
          },
        },
        {
          provide: ExceptionService,
          useValue: {
            handleException: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    jwtService = module.get<JwtService>(JwtService);

    // Reset mocks
    jest.clearAllMocks();

    // Setup bcrypt mocks
    (bcrypt.compare as jest.Mock).mockImplementation((password, _hash) => {
      return Promise.resolve(password === 'correct_password');
    });
    (bcrypt.genSalt as jest.Mock).mockResolvedValue('salt');
    (bcrypt.hash as jest.Mock).mockResolvedValue('hashed_password');

    // Mock config service
    mockConfigService.get.mockImplementation(key => {
      if (key === 'jwt.accessTokenExpiration') return '1h';
      if (key === 'jwt.refreshTokenExpiration') return '7d';
      return null;
    });
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('validateUser', () => {
    it('should return user object when credentials are valid', async () => {
      mockUsersService.findById.mockResolvedValue(mockUser);

      const result = await service.validateUser({
        sub: 'test-id',
        email: 'test@example.com',
        role: 'user',
      });

      expect(result).toEqual(mockUser);
      expect(mockUsersService.findById).toHaveBeenCalledWith('test-id');
    });

    it('should throw an error when user is not found', async () => {
      mockUsersService.findById.mockResolvedValue(null);

      await expect(
        service.validateUser({
          sub: 'nonexistent-id',
          email: 'nonexistent@example.com',
          role: 'user',
        }),
      ).rejects.toThrow(UnauthorizedException);

      expect(mockUsersService.findById).toHaveBeenCalledWith('nonexistent-id');
    });
  });

  describe('login', () => {
    it('should generate tokens when login is successful', async () => {
      const loginDto = {
        email: mockUser.email,
        password: 'correct_password',
      };

      mockUsersService.findByEmail.mockResolvedValue(mockUser);
      mockJwtService.sign.mockReturnValueOnce('access_token');
      mockJwtService.sign.mockReturnValueOnce('refresh_token');

      const result = await service.login(loginDto);

      expect(result).toEqual({
        user: {
          id: mockUser.id,
          email: mockUser.email,
          firstName: mockUser.firstName,
          lastName: mockUser.lastName,
          role: mockUser.role,
        },
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
      });
      expect(jwtService.sign).toHaveBeenCalledTimes(2);
    });
  });

  describe('register', () => {
    it('should create a new user and return tokens', async () => {
      const registerDto = {
        email: 'new@example.com',
        password: 'password123',
        name: 'New User',
      };

      const newUser = {
        id: 'new-id',
        email: registerDto.email,
        firstName: 'New',
        lastName: 'User',
        role: 'user',
      };

      mockUsersService.findByEmail.mockResolvedValue(null);
      mockUsersService.create.mockResolvedValue(newUser);
      mockJwtService.sign.mockReturnValueOnce('access_token');
      mockJwtService.sign.mockReturnValueOnce('refresh_token');

      const result = await service.register(registerDto);

      expect(result).toEqual({
        user: {
          id: newUser.id,
          email: newUser.email,
          firstName: newUser.firstName,
          lastName: newUser.lastName,
          role: newUser.role,
        },
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
      });
      expect(mockUsersService.findByEmail).toHaveBeenCalledWith(registerDto.email);
      expect(mockUsersService.create).toHaveBeenCalled();
      expect(jwtService.sign).toHaveBeenCalledTimes(2);
    });

    it('should throw an error if user already exists', async () => {
      const registerDto = {
        email: 'existing@example.com',
        password: 'password123',
        name: 'Existing User',
      };

      mockUsersService.findByEmail.mockResolvedValue(mockUser);

      await expect(service.register(registerDto)).rejects.toThrow();
      expect(mockUsersService.findByEmail).toHaveBeenCalledWith(registerDto.email);
      expect(mockUsersService.create).not.toHaveBeenCalled();
    });
  });

  describe('refreshToken', () => {
    it('should generate new tokens when refresh token is valid', async () => {
      const refreshToken = 'valid_refresh_token';
      const payload = {
        sub: mockUser.id,
        email: mockUser.email,
        role: mockUser.role,
      };

      mockJwtService.verify.mockReturnValue(payload);
      mockUsersService.findById.mockResolvedValue(mockUser);
      mockJwtService.sign.mockReturnValueOnce('new_access_token');

      const result = await service.refreshToken(refreshToken);

      expect(result).toEqual({
        accessToken: 'new_access_token',
      });
      expect(mockUsersService.findById).toHaveBeenCalledWith(payload.sub);
      expect(mockJwtService.sign).toHaveBeenCalledTimes(1);
    });

    it('should throw an error if user not found during refresh', async () => {
      const refreshToken = 'invalid_refresh_token';
      const payload = {
        sub: 'nonexistent-id',
        email: 'nonexistent@example.com',
        role: 'user',
      };

      mockJwtService.verify.mockReturnValue(payload);
      mockUsersService.findById.mockResolvedValue(null);

      await expect(service.refreshToken(refreshToken)).rejects.toThrow(UnauthorizedException);
      expect(mockUsersService.findById).toHaveBeenCalledWith(payload.sub);
    });
  });
});
