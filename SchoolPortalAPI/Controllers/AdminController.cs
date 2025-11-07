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

    // Controllers/AdminController.cs
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
            .ToListAsync();

        return Ok(progress);
    }

    // Controllers/AdminController.cs
    [HttpGet("stats")]
    public async Task<IActionResult> GetAdminStats()
    {
        // ۱. تعداد کل دانش‌آموزان
        var totalStudents = await _context.Students.CountAsync();

        // ۲. تعداد کل معلمان
        var totalTeachers = await _context.Teachers.CountAsync();

        // ۳. تعداد کل کلاس‌ها
        var totalClasses = await _context.Classes.CountAsync();

        // ۴. تعداد کل دروس
        var totalCourses = await _context.Courses.CountAsync();

//        // ۵. تعداد کل نمرات ثبت‌شده
//        var totalScores = await _context.Scores.CountAsync();
//
//        // ۶. میانگین کل نمرات در سیستم
//        var systemAverage = await _context.Scores
//            .AverageAsync(s => (double?)s.ScoreValue) ?? 0.0;


        var stats = new[]
        {
            new { label = "کل دانش‌آموزان", value = totalStudents.ToString(), subtitle = "فعال", icon = "person", color = "blue" },
            new { label = "کل معلمان", value = totalTeachers.ToString(), subtitle = "فعال", icon = "school", color = "green" },
            new { label = "کل کلاس‌ها", value = totalClasses.ToString(), subtitle = "تشکیل‌شده", icon = "class", color = "purple" },
            new { label = "کل دروس", value = totalCourses.ToString(), subtitle = "تعریف‌شده", icon = "menu_book", color = "orange" },
//            new { label = "کل نمرات", value = totalScores.ToString(), subtitle = "ثبت‌شده", icon = "grade", color = "pink" },
//            new { label = "میانگین سیستم", value = systemAverage.ToString("F1"), subtitle = "از ۲۰", icon = "trending_up", color = "cyan" },

        };

        return Ok(stats);
    }

    [HttpGet("name/{userId}")]
    public async Task<IActionResult> GetAdminName(long userId)
    {
        var name = await _context.Managers
            .Where(u => u.Userid == userId)
            .Select(u => u.Name)
            .FirstOrDefaultAsync();

        return Ok(new { name = name ?? "مدیر" });
    }
  }
}