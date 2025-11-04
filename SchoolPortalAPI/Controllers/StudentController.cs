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

      [HttpGet("progress/{userId}")]
      public async Task<IActionResult> GetProgress(long userId)
      {
          var student = await _context.Students
              .Where(s => s.UserID == userId)
              .Select(s => s.Studentid)
              .FirstOrDefaultAsync();

          if (student == null)
              return NotFound("دانش‌آموز یافت نشد");

          var progress = await _context.Scores
              .Where(s => s.Course != null && s.Studentid == student)
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
              query = query.Where(e => e.Enddate.CompareTo(start) >= 0);
          if (!string.IsNullOrEmpty(end))
              query = query.Where(e => e.Enddate.CompareTo(end) <= 0);

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
              query = query.Where(e => e.Enddate.CompareTo(start) >= 0);
          if (!string.IsNullOrEmpty(end))
              query = query.Where(e => e.Enddate.CompareTo(end) <= 0);

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

      [HttpGet("courses/{userId}")]
      public async Task<IActionResult> GetStudentCourses(long userId)
      {
          var student = await _context.Students
              .Where(s => s.UserID == userId)  // درست: Userid
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
              .GroupBy(x => new { x.c.Courseid, x.c.Name, x.c.Code, x.c.Location, x.c.Time, TeacherName = x.c.Teacher != null ? x.c.Teacher.Name : "نامشخص" })
              .Select(g => new
              {
                  courseName = g.Key.Name,
                  courseCode = g.Key.Code ?? "",
                  teacherName = g.Key.TeacherName,
                  location = g.Key.Location ?? "نامشخص",
                  time = g.Key.Time ?? "نامشخص",
                  grade = g.OrderByDescending(s => s.score.Id).FirstOrDefault().score != null
                      ? g.OrderByDescending(s => s.score.Id).FirstOrDefault().score.ScoreValue.ToString()
                      : "-"
              })
              .ToListAsync();

          return Ok(courses);
      }

      [HttpGet("average/{userId}")]
      public async Task<IActionResult> GetStudentAverage(long userId)
      {
          var student = await _context.Students
              .Where(s => s.UserID == userId)
              .Select(s => s.Studentid)
              .FirstOrDefaultAsync();

          if (student == null) return NotFound();

          var average = await _context.Scores
              .Where(s => s.Studentid == student)
              .AverageAsync(s => (double?)s.ScoreValue) ?? 0.0;

          return Ok(new { average = Math.Round(average, 1) });
      }

      [HttpGet("stats/{userId}")]
      public async Task<IActionResult> GetStudentStats(long userId)
      {
          var student = await _context.Students
              .Where(s => s.UserID == userId)
              .Select(s => new { s.Studentid, s.Name })
              .FirstOrDefaultAsync();

          if (student == null) return NotFound();

          var totalCourses = await _context.Courses
              .Where(c => c.Classid == _context.Students.Where(s => s.UserID == userId).Select(s => s.Classeid).FirstOrDefault())
              .CountAsync();

          var average = await _context.Scores
              .Where(s => s.Studentid == student.Studentid)
              .AverageAsync(s => (double?)s.ScoreValue) ?? 0.0;

          var stats = new[]
          {
              new { label = "نام دانش‌آموز", value = student.Name, subtitle = "شناسه", icon = "person", color = "blue" },
              new { label = "تعداد دروس", value = totalCourses.ToString(), subtitle = "ثبت‌نام شده", icon = "school", color = "green" },
              new { label = "میانگین نمرات", value = average.ToString("F1"), subtitle = "از ۲۰", icon = "grade", color = "purple" },
              new { label = "تمرین‌های تحویل‌شده", value = "۱۲", subtitle = "از ۱۵", icon = "assignment", color = "orange" }
          };

          return Ok(stats);
      }
    }
}