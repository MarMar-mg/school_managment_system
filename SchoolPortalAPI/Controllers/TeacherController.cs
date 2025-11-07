// Controllers/TeacherController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SchoolPortalAPI.Data;
using SchoolPortalAPI.Models;

namespace SchoolPortalAPI.Controllers
{
    [ApiController]
    [Route("api/teacher")]
    public class TeacherController : ControllerBase
    {
        private readonly SchoolDbContext _context;

        public TeacherController(SchoolDbContext context)
        {
            _context = context;
        }

        [HttpGet("dashboard/{teacherId}")]
        public async Task<IActionResult> GetDashboard(long teacherId)
        {
            var teacher = await _context.Teachers.FindAsync(teacherId);
            if (teacher == null) return NotFound();

            var course = teacher.Courseid != null
                ? await _context.Courses.FindAsync(teacher.Courseid)
                : null;

            return Ok(new
            {
                teacher.Teacherid,
                teacher.Name,
                CourseName = course?.Name
            });
        }

        [HttpGet("students/{teacherId}")]
        public async Task<IActionResult> GetStudents(long teacherId)
        {
            var course = await _context.Courses
                .FirstOrDefaultAsync(c => c.Teacherid == teacherId);

            if (course == null) return Ok(new List<object>());

            var students = await _context.Students
                .Where(s => s.Classeid == course.Classid)
                .Select(s => new
                {
                    s.Studentid,
                    s.Name,
                    s.StuCode
                })
                .ToListAsync();

            return Ok(students);
        }

        [HttpGet("progress/{teacherId}")]
        public async Task<IActionResult> GetTeacherProgress(long teacherId)
        {
            // مرحله ۱: پیدا کردن Teacherid از جدول Teachers
            var teacher = await _context.Teachers
                .Where(t => t.Userid == teacherId)
                .Select(t => t.Teacherid)
                .FirstOrDefaultAsync();

            if (teacher == 0) return NotFound("معلم یافت نشد");

            // مرحله ۲: پیدا کردن نمرات با Course.Teacherid
            var progress = await _context.Scores
                .Where(s => s.Course != null && s.Course.Teacherid == teacher)
                .Include(s => s.Course)
                .GroupBy(s => s.Courseid)
                .Select(g => new
                {
                    courseName = g.First().Course != null ? g.First().Course.Name : "نامشخص",
                    average = g.Average(s => (double?)s.ScoreValue) ?? 0.0
                })
                .ToListAsync();

            return Ok(progress);
        }

        [HttpGet("courses/{userId}")]
        public async Task<IActionResult> GetTeacherCourses(long userId)
        {
            var teacher = await _context.Teachers
                .Where(t => t.Userid == userId)
                .Select(t => new { t.Teacherid, t.Name })
                .FirstOrDefaultAsync();

            if (teacher == null) return NotFound("معلم یافت نشد");

            var courses = await _context.Courses
                .Where(c => c.Teacherid == teacher.Teacherid)
                .GroupJoin(
                    _context.Scores,
                    c => c.Courseid,
                    sc => sc.Courseid,
                    (c, scores) => new { c, scores }
                )
                .Select(g => new
                {
                    courseName = g.c.Name,
                    courseCode = g.c.Code ?? "",
                    teacherName = teacher.Name,  // اضافه شد
                    location = g.c.Location ?? "نامشخص",
                    time = g.c.Time ?? "نامشخص",
                    averageGrade = g.scores.Any()
                        ? Math.Round(g.scores.Average(s => s.ScoreValue), 1).ToString()
                        : "-"
                })
                .ToListAsync();

            return Ok(courses);
        }

        [HttpGet("average/{userId}")]
        public async Task<IActionResult> GetTeacherAverage(long userId)
        {
            var teacherId = await _context.Teachers
                .Where(t => t.Userid == userId)
                .Select(t => t.Teacherid)
                .FirstOrDefaultAsync();

            if (teacherId == 0) return NotFound();

            var average = await _context.Scores
                .Where(s => s.Course != null && s.Course.Teacherid == teacherId)
                .AverageAsync(s => (double?)s.ScoreValue) ?? 0.0;

            return Ok(new { average = Math.Round(average, 1) });
        }

        [HttpGet("stats/{userId}")]
        public async Task<IActionResult> GetTeacherStats(long userId)
        {
            var teacher = await _context.Teachers
                .Where(t => t.Userid == userId)
                .Select(t => new { t.Name, t.Teacherid })
                .FirstOrDefaultAsync();

            if (teacher == null) return NotFound();

            var lastCourseName = await _context.Courses
                .Where(c => c.Teacherid == teacher.Teacherid)
                .OrderByDescending(c => c.Courseid)
                .Select(c => c.Name)
                .FirstOrDefaultAsync();

            var totalCourses = await _context.Courses.Where(c => c.Teacherid == teacher.Teacherid).CountAsync();
            var totalStudents = await _context.Students
                .Where(s => _context.Courses.Any(c => c.Classid == s.Classeid && c.Teacherid == teacher.Teacherid))
                .CountAsync();

            var average = await _context.Scores
                .Where(s => s.Course != null && s.Course.Teacherid == teacher.Teacherid)
                .AverageAsync(s => (double?)s.ScoreValue) ?? 0.0;

            var stats = new[]
            {
                new { label = "نام درس", value = lastCourseName, subtitle = "استاد", icon = "course", color = "blue" },
                new { label = "تعداد دروس", value = totalCourses.ToString(), subtitle = "تدریس", icon = "school", color = "green" },
                new { label = "تعداد دانش‌آموز", value = totalStudents.ToString(), subtitle = "کلاس‌ها", icon = "group", color = "orange" },
                new { label = "میانگین نمرات", value = average.ToString("F1"), subtitle = "کلاس‌ها", icon = "grade", color = "purple" }
            };

            return Ok(stats);
        }

        [HttpGet("name/{userId}")]
        public async Task<IActionResult> GetTeacherName(long userId)
        {
            var name = await _context.Teachers
                .Where(t => t.Userid == userId)
                .Select(t => t.Name)
                .FirstOrDefaultAsync();

            return Ok(new { name = name ?? "معلم" });
        }
    }
}