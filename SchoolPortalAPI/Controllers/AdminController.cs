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

    // AdminController.cs
    [HttpGet("stats")]
    public async Task<IActionResult> GetStats()
    {
        var totalClasses = await _context.Classes.CountAsync();
        var totalStudents = await _context.Students.CountAsync();
        var totalTeachers = await _context.Teachers.CountAsync();

        return Ok(new
        {
            totalClasses,
            totalStudents,
            totalTeachers
        });
    }

    [HttpGet("stats")]
    public async Task<IActionResult> GetManagerStats()
    {
        var totalStudents = await _context.Students.CountAsync();
        var totalTeachers = await _context.Teachers.CountAsync();
        var totalCourses = await _context.Courses.CountAsync();
        var totalClasses = await _context.Classes.CountAsync();

        var stats = new[]
        {
            new { label = "تعداد دانش‌آموز", value = totalStudents.ToString(), subtitle = "فعال", icon = "person", color = "blue" },
            new { label = "تعداد معلم", value = totalTeachers.ToString(), subtitle = "فعال", icon = "school", color = "green" },
            new { label = "تعداد دروس", value = totalCourses.ToString(), subtitle = "کل", icon = "menu_book", color = "purple" },
            new { label = "تعداد کلاس", value = totalClasses.ToString(), subtitle = "فعال", icon = "class", color = "orange" }
        };

        return Ok(stats);
    }
  }
}