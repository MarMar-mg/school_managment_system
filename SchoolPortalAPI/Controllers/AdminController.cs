// Controllers/AdminController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SchoolPortalAPI.Data;
using SchoolPortalAPI.Models;

namespace SchoolPortalAPI.Controllers
{
    [ApiController]
    [Route("api/admin")]
    public class AdminController : ControllerBase
    {
        private readonly SchoolDbContext _context;

        public AdminController(SchoolDbContext context)
        {
            _context = context;
        }

        // ──────────────────────────────────────────────────────────────
        // Get average score per class and course across the entire system
        // ──────────────────────────────────────────────────────────────
        [HttpGet("progress")]
        public async Task<IActionResult> GetAdminProgress()
        {
            var progress = await _context.Scores
                .Include(s => s.Course)
                .Include(s => s.Class)
                .GroupBy(s => new { s.Classid, s.Courseid })
                .Select(g => new
                {
                    className = g.First().Class != null ? g.First().Class.Name : "نامشخص",
                    courseName = g.First().Course != null ? g.First().Course.Name : "نامشخص",
                    average = g.Average(s => (double?)s.ScoreValue) ?? 0.0
                })
                .OrderBy(x => x.className)
                .ThenBy(x => x.courseName)
                .ToListAsync();

            return Ok(progress);
        }

        // ──────────────────────────────────────────────────────────────
        // Get system-wide statistics for admin dashboard cards
        // - Total students
        // - Total teachers
        // - Total classes
        // - Total courses
        // ──────────────────────────────────────────────────────────────
        [HttpGet("stats")]
        public async Task<IActionResult> GetAdminStats()
        {
            var totalStudents = await _context.Students.CountAsync();
            var totalTeachers = await _context.Teachers.CountAsync();
            var totalClasses  = await _context.Classes.CountAsync();
            var totalCourses  = await _context.Courses.CountAsync();

            var stats = new[]
            {
                new { label = "کل دانش‌آموزان",   value = totalStudents.ToString(),  subtitle = "فعال",        icon = "person",     color = "blue"    },
                new { label = "کل معلمان",       value = totalTeachers.ToString(),  subtitle = "فعال",        icon = "school",     color = "green"   },
                new { label = "کل کلاس‌ها",      value = totalClasses.ToString(),   subtitle = "تشکیل‌شده",   icon = "class",      color = "purple"  },
                new { label = "کل دروس",         value = totalCourses.ToString(),   subtitle = "تعریف‌شده",   icon = "menu_book",  color = "orange"  }
            };

            return Ok(stats);
        }

        // ──────────────────────────────────────────────────────────────
        // Get admin's full name for display in AppBar and profile
        // ──────────────────────────────────────────────────────────────
        [HttpGet("name/{userId}")]
        public async Task<IActionResult> GetAdminName(long userId)
        {
            var name = await _context.Managers
                .Where(m => m.Userid == userId)
                .Select(m => m.Name)
                .FirstOrDefaultAsync();

            return Ok(new { name = name ?? "مدیر" });
        }
    }
}