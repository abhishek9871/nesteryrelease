import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';

describe('AuthService', () => {
  let service: AuthService;
  let usersService: UsersService;
  let jwtService: JwtService;

  const mockUser = {
    id: 'test-id',
    email: 'test@example.com',
    password: 'hashed_password',
    name: 'Test User',
    role: 'user',
  };

  const mockUsersService = {
    findByEmail: jest.fn(),
    create: jest.fn(),
  };

  const mockJwtService = {
    sign: jest.fn(),
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
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    usersService = module.get<UsersService>(UsersService);
    jwtService = module.get<JwtService>(JwtService);

    // Reset mocks
    jest.clearAllMocks();
    
    // Mock bcrypt compare
    jest.spyOn(bcrypt, 'compare').mockImplementation((password, hash) => {
      return Promise.resolve(password === 'correct_password');
    });
    
    // Mock config service
    mockConfigService.get.mockImplementation((key) => {
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
      mockUsersService.findByEmail.mockResolvedValue(mockUser);
      
      const result = await service.validateUser('test@example.com', 'correct_password');
      
      expect(result).toEqual({
        id: mockUser.id,
        email: mockUser.email,
        name: mockUser.name,
        role: mockUser.role,
      });
      expect(mockUsersService.findByEmail).toHaveBeenCalledWith('test@example.com');
      expect(bcrypt.compare).toHaveBeenCalledWith('correct_password', mockUser.password);
    });

    it('should return null when user is not found', async () => {
      mockUsersService.findByEmail.mockResolvedValue(null);
      
      const result = await service.validateUser('nonexistent@example.com', 'any_password');
      
      expect(result).toBeNull();
      expect(mockUsersService.findByEmail).toHaveBeenCalledWith('nonexistent@example.com');
    });

    it('should return null when password is incorrect', async () => {
      mockUsersService.findByEmail.mockResolvedValue(mockUser);
      
      const result = await service.validateUser('test@example.com', 'wrong_password');
      
      expect(result).toBeNull();
      expect(mockUsersService.findByEmail).toHaveBeenCalledWith('test@example.com');
      expect(bcrypt.compare).toHaveBeenCalledWith('wrong_password', mockUser.password);
    });
  });

  describe('login', () => {
    it('should generate tokens when login is successful', async () => {
      const user = {
        id: mockUser.id,
        email: mockUser.email,
        name: mockUser.name,
        role: mockUser.role,
      };
      
      mockJwtService.sign.mockReturnValueOnce('access_token');
      mockJwtService.sign.mockReturnValueOnce('refresh_token');
      
      const result = await service.login(user);
      
      expect(result).toEqual({
        user,
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
        name: registerDto.name,
        role: 'user',
      };
      
      mockUsersService.findByEmail.mockResolvedValue(null);
      mockUsersService.create.mockResolvedValue(newUser);
      mockJwtService.sign.mockReturnValueOnce('access_token');
      mockJwtService.sign.mockReturnValueOnce('refresh_token');
      
      const result = await service.register(registerDto);
      
      expect(result).toEqual({
        user: newUser,
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
      const payload = {
        sub: mockUser.id,
        email: mockUser.email,
        role: mockUser.role,
      };
      
      mockUsersService.findByEmail.mockResolvedValue(mockUser);
      mockJwtService.sign.mockReturnValueOnce('new_access_token');
      mockJwtService.sign.mockReturnValueOnce('new_refresh_token');
      
      const result = await service.refreshToken(payload);
      
      expect(result).toEqual({
        accessToken: 'new_access_token',
        refreshToken: 'new_refresh_token',
      });
      expect(mockUsersService.findByEmail).toHaveBeenCalledWith(payload.email);
      expect(jwtService.sign).toHaveBeenCalledTimes(2);
    });

    it('should throw an error if user not found during refresh', async () => {
      const payload = {
        sub: 'nonexistent-id',
        email: 'nonexistent@example.com',
        role: 'user',
      };
      
      mockUsersService.findByEmail.mockResolvedValue(null);
      
      await expect(service.refreshToken(payload)).rejects.toThrow(UnauthorizedException);
      expect(mockUsersService.findByEmail).toHaveBeenCalledWith(payload.email);
    });
  });
});
