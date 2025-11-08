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

        // ──────────────────────────────────────────────────────────────
        // Get basic student dashboard data (ID, Name, Class, Score, Debt)
        // ──────────────────────────────────────────────────────────────
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

        // ──────────────────────────────────────────────────────────────
        // Get full student profile
        // ──────────────────────────────────────────────────────────────
        [HttpGet("profile/{studentId}")]
        public async Task<IActionResult> GetProfile(long studentId)
        {
            var student = await _context.Students.FindAsync(studentId);
            if (student == null) return NotFound();
            return Ok(student);
        }

        // ──────────────────────────────────────────────────────────────
        // Get average score per course for this student
        // ──────────────────────────────────────────────────────────────
        [HttpGet("progress/{userId}")]
        public async Task<IActionResult> GetProgress(long userId)
        {
            var studentId = await _context.Students
                .Where(s => s.UserID == userId)
                .Select(s => s.Studentid)
                .FirstOrDefaultAsync();

            if (studentId == 0) return NotFound("دانش‌آموز یافت نشد");

            var progress = await _context.Scores
                .Where(s => s.Course != null && s.Studentid == studentId)
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

        // ──────────────────────────────────────────────────────────────
        // Get exercises for student's class with optional date filtering
        // ──────────────────────────────────────────────────────────────
        [HttpGet("exercises/{studentId}")]
        public async Task<IActionResult> GetExercises(
            long studentId,
            [FromQuery] string? start,
            [FromQuery] string? end)
        {
            var student = await _context.Students
                .Where(s => s.Studentid == studentId)
                .Select(s => new { s.Classeid })
                .FirstOrDefaultAsync();

            if (student == null) return NotFound("دانش‌آموز یافت نشد");

            var query = _context.Exercises
                .Where(e => e.Classid == student.Classeid);

            if (!string.IsNullOrEmpty(start))
                query = query.Where(e => string.Compare(e.Enddate, start) >= 0);
            if (!string.IsNullOrEmpty(end))
                query = query.Where(e => string.Compare(e.Enddate, end) <= 0);

            var result = await query
                .Include(e => e.Course)
                .Select(e => new
                {
                    title = e.Title,
                    courseName = e.Course != null ? e.Course.Name : "نامشخص",
                    dueDate = e.Enddate,
                    startTime = e.Starttime,
                    endTime = e.Endtime
                })
                .ToListAsync();

            return Ok(result);
        }

        // ──────────────────────────────────────────────────────────────
        // Get exams for student's class with optional date filtering
        // ──────────────────────────────────────────────────────────────
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
                query = query.Where(e => string.Compare(e.Enddate, start) >= 0);
            if (!string.IsNullOrEmpty(end))
                query = query.Where(e => string.Compare(e.Enddate, end) <= 0);

            var result = await query
                .Include(e => e.Course)
                .Select(e => new
                {
                    title = e.Title,
                    courseName = e.Course != null ? e.Course.Name : "نامشخص",
                    examDate = e.Enddate,
                    startTime = e.Starttime,
                    endTime = e.Endtime
                })
                .ToListAsync();

            return Ok(result);
        }

        // ──────────────────────────────────────────────────────────────
        // Get all courses for student with latest grade and teacher info
        // ──────────────────────────────────────────────────────────────
        [HttpGet("courses/{userId}")]
        public async Task<IActionResult> GetStudentCourses(long userId)
        {
            var student = await _context.Students
                .Where(s => s.UserID == userId)
                .Select(s => new { s.Classeid, s.Studentid })
                .FirstOrDefaultAsync();

            if (student == null) return NotFound("دانش‌آموز یافت نشد");

            var courses = await _context.Courses
                .Where(c => c.Classid == student.Classeid)
                .Include(c => c.Teacher)
                .GroupJoin(
                    _context.Scores.Where(sc => sc.Studentid == student.Studentid),
                    c => c.Courseid,
                    sc => sc.Courseid,
                    (c, scores) => new { c, scores }
                )
                .SelectMany(
                    x => x.scores.DefaultIfEmpty(),
                    (c, sc) => new { c.c, score = sc }
                )
                .GroupBy(x => new
                {
                    x.c.Courseid,
                    x.c.Name,
                    x.c.Code,
                    x.c.Location,
                    x.c.Time,
                    TeacherName = x.c.Teacher != null ? x.c.Teacher.Name : "نامشخص"
                })
                .Select(g => new
                {
                    courseName = g.Key.Name,
                    courseCode = g.Key.Code ?? "",
                    teacherName = g.Key.TeacherName,
                    location = g.Key.Location ?? "نامشخص",
                    time = g.Key.Time ?? "نامشخص",
                    grade = g.OrderByDescending(s => s.score != null ? s.score.Id : 0)
                             .FirstOrDefault().score != null
                        ? g.OrderByDescending(s => s.score != null ? s.score.Id : 0)
                           .FirstOrDefault().score.ScoreValue.ToString()
                        : "-"
                })
                .ToListAsync();

            return Ok(courses);
        }
        // ──────────────────────────────────────────────────────────────
        // Get overall average grade for the student
        // ──────────────────────────────────────────────────────────────
        [HttpGet("average/{userId}")]
        public async Task<IActionResult> GetStudentAverage(long userId)
        {
            var studentId = await _context.Students
                .Where(s => s.UserID == userId)
                .Select(s => s.Studentid)
                .FirstOrDefaultAsync();

            if (studentId == 0) return NotFound();

            var average = await _context.Scores
                .Where(s => s.Studentid == studentId)
                .AverageAsync(s => (double?)s.ScoreValue) ?? 0.0;

            return Ok(new { average = Math.Round(average, 1) });
        }

        // ──────────────────────────────────────────────────────────────
        // Get student stats for dashboard cards
        // - Last score month (discipline score)
        // - Total courses
        // - Overall average
        // - Submitted assignments
        // ──────────────────────────────────────────────────────────────
        [HttpGet("stats/{userId}")]
        public async Task<IActionResult> GetStudentStats(long userId)
        {
            var student = await _context.Students
                .Where(s => s.UserID == userId)
                .Select(s => new { s.Studentid, s.Name })
                .FirstOrDefaultAsync();

            if (student == null) return NotFound();

            var totalCourses = await _context.Courses
                .Where(c => c.Classid == _context.Students
                    .Where(s => s.UserID == userId)
                    .Select(s => s.Classeid)
                    .FirstOrDefault())
                .CountAsync();

            var average = await _context.Scores
                .Where(s => s.Studentid == student.Studentid)
                .AverageAsync(s => (double?)s.ScoreValue) ?? 0.0;

            var lastScoreMonth = await _context.Scores
                .Where(s => s.Studentid == student.Studentid)
                .OrderByDescending(s => s.Id)
                .Select(s => s.Score_month)
                .FirstOrDefaultAsync();

            var stats = new[]
            {
                new { label = "آخرین نمره",       value = lastScoreMonth ?? "ندارد", subtitle = "ماه",       icon = "event",     color = "purple" },
                new { label = "تعداد دروس",       value = totalCourses.ToString(),   subtitle = "ثبت‌نام شده", icon = "school",    color = "green"  },
                new { label = "میانگین نمرات",    value = average.ToString("F1"),    subtitle = "از ۲۰",      icon = "grade",     color = "blue"   },
                new { label = "تمرین‌های تحویل‌شده", value = "۱۲",                   subtitle = "از ۱۵",      icon = "assignment", color = "orange" }
            };

            return Ok(stats);
        }

        // ──────────────────────────────────────────────────────────────
        // Get student's full name for display (AppBar, Profile, etc.)
        // ──────────────────────────────────────────────────────────────
        [HttpGet("name/{userId}")]
        public async Task<IActionResult> GetStudentName(long userId)
        {
            var name = await _context.Students
                .Where(s => s.UserID == userId)
                .Select(s => s.Name)
                .FirstOrDefaultAsync();

            return Ok(new { name = name ?? "دانش‌آموز" });
        }
    }
}