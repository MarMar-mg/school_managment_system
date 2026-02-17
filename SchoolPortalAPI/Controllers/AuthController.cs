// Controllers/AuthController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SchoolPortalAPI.Data;
using SchoolPortalAPI.Models;

namespace SchoolPortalAPI.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private readonly SchoolDbContext _context;

        public AuthController(SchoolDbContext context)
        {
            _context = context;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (string.IsNullOrEmpty(request.Username) || string.IsNullOrEmpty(request.Password))
                return BadRequest(new { message = "نام کاربری و رمز عبور الزامی است" });

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Username == request.Username && u.Password == request.Password);

            if (user == null)
                return Unauthorized(new { message = "نام کاربری یا رمز عبور اشتباه است" });

            return Ok(new
            {
                userid = user.Userid,
                username = user.Username,
                role = user.Role.ToLower(),
                message = "ورود موفق"
            });
        }

        [HttpPost("change-password")]
            public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
            {
                if (string.IsNullOrWhiteSpace(request.CurrentPassword) ||
                    string.IsNullOrWhiteSpace(request.NewPassword))
                {
                    return BadRequest(new { message = "رمزهای عبور نمی‌توانند خالی باشند" });
                }

                var user = await _context.Users
                    .FirstOrDefaultAsync(u => u.Userid == request.UserId);

                if (user == null)
                {
                    return NotFound(new { message = "کاربر یافت نشد" });
                }

                if (user.Password != request.CurrentPassword)
                {
                    return BadRequest(new { message = "رمز عبور فعلی اشتباه است" });
                }

                if (request.NewPassword.Length < 8)
                {
                    return BadRequest(new { message = "رمز عبور جدید باید حداقل ۸ کاراکتر باشد" });
                }

                user.Password = request.NewPassword;           // ← plain text (insecure!)
                // user.UpdatedAt = DateTime.UtcNow;           // if you have this field

                _context.Users.Update(user);
                await _context.SaveChangesAsync();

                return Ok(new { message = "رمز عبور با موفقیت تغییر یافت" });
            }
    }

    public class LoginRequest
    {
        public string Username { get; set; } = null!;
        public string Password { get; set; } = null!;
    }

    public class ChangePasswordRequest
    {
        public long UserId { get; set; }
        public string CurrentPassword { get; set; } = null!;
        public string NewPassword { get; set; } = null!;
    }
}