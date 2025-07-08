import jwt
import base64
import json
from datetime import datetime, timedelta

# Your dummy JWT token
token = "eyJhbGciOiJSUzI1NiIsInR5cCI6ImF0K2p3dCIsImtpZCI6IkFrOFBrYkZEcm5OZWhvQXJMZUo5cmJlNExvd2VOQ0tXSjF6cVd4VEtvcG8ifQ.eyJ0aWQiOiJwMHdjcW9mbjd0eGFoOHkwcjBsZWoiLCJhcHBfbmFtZSI6IkZsZXggQWRtaW4gUG9ydGFsIiwiYXBwX2lkIjoiZmxleC1hZG1pbi1wb3J0YWwiLCJyb2xlcyI6WyJHbG9iYWwgQWRtaW4iLCJBZG1pbiIsIlRlbmFudCBBZG1pbiJdLCJqdGkiOiJEZ1ZEUmY5N0FjSmw0TjNrVUNEN1AiLCJzdWIiOiI0ejRocWl4ajVubnkwcnNmMTg2a2ciLCJpYXQiOjE3MTg2MjkyMTAsImV4cCI6MTcxODYzMjgxMCwic2NvcGUiOiJvcGVuaWQgb2ZmbGluZV9hY2Nlc3MiLCJjbGllbnRfaWQiOiI5YXAzbHFrNnlnd3NicTgzaDg3dGRvd2R0bXR4MWp0dSIsImlzcyI6Imh0dHBzOi8vdXNlcmlkLXN0Zy5pbyIsImF1ZCI6IlRyYW5zbWl0LVNlY3VyaXR5LUFkbWluLUFQSS9wMHdjcW9mbjd0eGFoOHkwcjBsZWoifQ.hp5Q9dvvx9k0lHYru9fW-uLraAJBFSieUNWE3lgbXlZRfJGL6j7k8v4A0AUS6ZBJ9FQP3mfWu81l0Z4FkLeDO1V_WoOdHAqP0TDoZsQj1NlIqOSWkoCDX1VzzCNKx88ZxM3bO1q-ZjiwnB9cFQbpiXn9eQ2KsVv41Zv0OiR4YrnxbhvgJPosmQZDebGqvUT7Q3D_EIGF1Cuz7mQRw0FCfpPp0JJ6rF_o67iK3sZYgSm-VQQjFsqghrKbgpaYF8WIsnZDDbiuRs9eZy_GAcoePuqw9twR2dsd5x7eYVggBTBls6EkE7iBdo0v-ZM9fvufLbtylgmWuG61LzJGOuqbm0ZU-h0DfBjnHSDnJnGnO_QKl8fZtNW748wbcNx84ToSsgYPXFmlL9y8oG_vdgadbaUk3tqYXvHYWCEeN2DqxB13cboXQr-aqDqKLZVgbLpY9b5mCnAlQJ7iWYfT7rex4u7d5qZ0ZO2aon90bkn1zLDPLlJOFmamSeCW0m-6fSsQEYaXRGgqFp5JP3afcHQCb6FUioUCuiHzqc98lDHzqSd0mhDPEs3EvoT4tqBQHjsqwDaOZyysw4cRU8dmRpnlapR5PYqhJXh8T8ZAmfwONjT8lZK-pbwW0MxVprrCvfF-CI-x6vcPcgswlSdhgydhFWAX91tVfknYnJHPzsKUzq4"
            
# Secret key used to sign the token
secret_key = "your_secret_key"

# Decode the JWT token without verification
def decode_jwt_without_verification(token):
    payload = token.split('.')[1]
    # Add padding if necessary
    payload += '=' * (4 - len(payload) % 4)
    decoded_bytes = base64.urlsafe_b64decode(payload)
    decoded_str = decoded_bytes.decode('utf-8')
    return json.loads(decoded_str)

# Decode the token
decoded_token = decode_jwt_without_verification(token)

# Modify the 'exp' claim to a time in the past
decoded_token['exp'] = int((datetime.utcnow() - timedelta(days=1)).timestamp())

# Encode the token again
new_token = jwt.encode(decoded_token, secret_key, algorithm="HS256")

print(new_token)
