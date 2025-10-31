using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace SchoolSystemAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
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
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Username == request.Username && u.Password == request.Password);

            if (user == null)
                return Unauthorized(new { message = "نام کاربری یا رمز عبور نامعتبر است" });

            object userData = null;

            if (user.Role == "student")
            {
                var student = await _context.Students
                    .FirstOrDefaultAsync(s => s.UserID == user.UserId);

                userData = new
                {
                    userId = user.UserId,
                    username = user.Username,
                    role = user.Role,
                    name = student?.Name,
                    studentId = student?.StudentId,
                    stuCode = student?.StuCode,
                    classId = student?.Classeid
                };
            }
            else if (user.Role == "teacher")
            {
                var teacher = await _context.Teachers
                    .FirstOrDefaultAsync(t => t.UserId == user.UserId);

                userData = new
                {
                    userId = user.UserId,
                    username = user.Username,
                    role = user.Role,
                    name = teacher?.Name,
                    teacherId = teacher?.TeacherId,
                    courseId = teacher?.CourseId
                };
            }
            else if (user.Role == "admin")
            {
                userData = new
                {
                    userId = user.UserId,
                    username = user.Username,
                    role = user.Role,
                    name = "مدیر"
                };
            }

            return Ok(userData);
        }
    }

    public class LoginRequest
    {
        public string Username { get; set; }
        public string Password { get; set; }
    }
}