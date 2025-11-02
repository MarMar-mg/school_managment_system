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
    }
}