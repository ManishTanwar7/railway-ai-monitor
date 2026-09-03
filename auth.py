import datetime
from typing import Optional, List, Dict, Any
import jwt
from fastapi import Request, HTTPException, status
from fastapi.responses import RedirectResponse
from config import SECRET_KEY, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES, COOKIE_NAME, USERS_DB

def create_access_token(data: dict, expires_delta: Optional[datetime.timedelta] = None) -> str:
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.datetime.now(datetime.timezone.utc) + expires_delta
    else:
        expire = datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def decode_access_token(token: str) -> Optional[dict]:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except Exception:
        return None

def authenticate_user(username: str, password: str) -> Optional[dict]:
    user = USERS_DB.get(username.strip().lower())
    if not user:
        return None
    # Password matching (allows clean plain comparison for test users)
    if user["password_hash"] != password:
        return None
    return user

def get_current_user_from_request(request: Request) -> Optional[dict]:
    # Check session cookie first
    token = request.cookies.get(COOKIE_NAME)
    
    # If not in cookie, check Authorization header (Bearer token)
    if not token:
        auth_header = request.headers.get("Authorization")
        if auth_header and auth_header.startswith("Bearer "):
            token = auth_header.split(" ")[1]
            
    if not token:
        return None
        
    payload = decode_access_token(token)
    if not payload:
        return None
        
    username = payload.get("sub")
    if not username:
        return None
        
    return USERS_DB.get(username)

def require_role(allowed_roles: List[str]):
    """
    Dependency to enforce role access.
    Returns the user dict if authorized, otherwise raises HTTPException or redirects.
    """
    def role_checker(request: Request) -> dict:
        user = get_current_user_from_request(request)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Not authenticated. Please log in."
            )
        if user["role"] not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied for role '{user['role']}'. Required: {allowed_roles}"
            )
        return user
    return role_checker
