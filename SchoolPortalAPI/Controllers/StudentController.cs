// Controllers/StudentController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SchoolPortalAPI.Data;
using SchoolPortalAPI.Models;

namespace SchoolPortalAPI.Controllers
{
    [ApiController]
    [Route("api/student")]
    public class StudentController : ControllerBase
    {
        private readonly SchoolDbContext _context;

        public StudentController(SchoolDbContext context)
        {
            _context = context;
        }

        // Existing methods (dashboard, exercises, exams, profile)...
        [HttpGet("dashboard/{userId}")]
        public async Task<IActionResult> GetDashboard(long userId)
        {
            var student = await _context.Students
                .FirstOrDefaultAsync(s => s.UserID == userId);

            if (student == null) return NotFound();

            string? className = null;
            if (student.Classeid != null)
            {
                var classObj = await _context.Classes
                    .FirstOrDefaultAsync(c => c.Classid == student.Classeid);
                className = classObj?.Name;
            }

            return Ok(new
            {
                student.Studentid,
                student.Name,
                student.StuCode,
                ClassName = className,
                student.Score,
                student.Debt
            });
        }
        

        [HttpGet("profile/{studentId}")]
        public async Task<IActionResult> GetProfile(long studentId)
        {
            var student = await _context.Students.FindAsync(studentId);
            if (student == null) return NotFound();
            return Ok(student);
        }

      [HttpGet("progress/1")]
      public async Task<IActionResult> GetProgress(long userId)
      {
          // مرحله ۱: پیدا کردن StuCode از جدول Students
          var student = await _context.Students
              .Where(s => s.UserID == userId)
              .Select(s => new { s.StuCode, s.Name })
              .FirstOrDefaultAsync();

          if (student == null)
              return NotFound("دانش‌آموز یافت نشد");

          // مرحله ۲: پیدا کردن نمرات با StuCode
          var progress = await _context.Scores
              .Where(s => s.StuCode == student.StuCode)
              .Include(s => s.Course)
              .GroupBy(s => s.Courseid)
              .Select(g => new
              {
                  courseName = g.First().Course != null ? g.First().Course.Name : "نامشخص",
                  average = g.Average(s => (double?)s.ScoreValue) ?? 0.0
              })
              .ToListAsync();

          return Ok(new
          {
              studentName = student.Name,
              progress
          });
      }
      // Controllers/StudentController.cs

      [HttpGet("exercises/{studentId}")]
      public async Task<IActionResult> GetExercises(
          long studentId,
          [FromQuery] string? start,
          [FromQuery] string? end)
      {
          var student = await _context.Students
              .Where(s => s.Studentid == studentId)
              .Select(s => new { s.Classeid, s.StuCode })
              .FirstOrDefaultAsync();

          if (student == null) return NotFound("دانش‌آموز یافت نشد");

          var query = _context.Exercises
              .Where(e => e.Classid == student.Classeid);

          if (!string.IsNullOrEmpty(start))
              query = query.Where(e => e.Duedate.CompareTo(start) >= 0);
          if (!string.IsNullOrEmpty(end))
              query = query.Where(e => e.Duedate.CompareTo(end) <= 0);

          var result = await query
              .Include(e => e.Course)
              .Select(e => new
              {
                  title = e.Title,
                  courseName = e.Course != null ? e.Course.Name : "نامشخص",
                  dueDate = e.Duedate
              })
              .ToListAsync();

          return Ok(result);
      }

      [HttpGet("exams/{studentId}")]
      public async Task<IActionResult> GetExams(
          long studentId,
          [FromQuery] string? start,
          [FromQuery] string? end)
      {
          var student = await _context.Students
              .Where(s => s.Studentid == studentId)
              .Select(s => new { s.Classeid })
              .FirstOrDefaultAsync();

          if (student == null) return NotFound("دانش‌آموز یافت نشد");

          var query = _context.Exams
              .Where(e => e.Classid == student.Classeid);

          if (!string.IsNullOrEmpty(start))
              query = query.Where(e => e.Examdate.CompareTo(start) >= 0);
          if (!string.IsNullOrEmpty(end))
              query = query.Where(e => e.Examdate.CompareTo(end) <= 0);

          var result = await query
              .Include(e => e.Course)
              .Select(e => new
              {
                  title = e.Title,
                  courseName = e.Course != null ? e.Course.Name : "نامشخص",
                  examDate = e.Examdate
              })
              .ToListAsync();

          return Ok(result);
      }
    }
}