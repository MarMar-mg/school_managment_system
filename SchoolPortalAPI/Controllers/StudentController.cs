using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace SchoolSystemAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class StudentController : ControllerBase
    {
        private readonly SchoolDbContext _context;

        public StudentController(SchoolDbContext context)
        {
            _context = context;
        }

        // GET: api/student/dashboard/{userId}
        [HttpGet("dashboard/{userId}")]
        public async Task<IActionResult> GetDashboard(long userId)
        {
            var student = await _context.Students
                .FirstOrDefaultAsync(s => s.UserID == userId);

            if (student == null)
                return NotFound(new { message = "دانش‌آموز یافت نشد" });

            // Get student's class info
            var classInfo = await _context.Classes
                .FirstOrDefaultAsync(c => c.ClassId == student.Classeid);

            // Get courses for this class
            var courses = await _context.Courses
                .Where(c => c.ClassId == student.Classeid)
                .Select(c => new
                {
                    courseId = c.CourseId,
                    courseName = c.Name,
                    classTime = c.ClassTime,
                    finalExamDate = c.FinalExamDate
                })
                .ToListAsync();

            // Get student scores
            var scores = await _context.Scores
                .Where(s => s.StuCode == student.StuCode)
                .Select(s => new
                {
                    courseId = s.CourseId,
                    score = s.ScoreValue,
                    scoreMonth = s.Score_month
                })
                .ToListAsync();

            return Ok(new
            {
                studentName = student.Name,
                studentCode = student.StuCode,
                className = classInfo?.Name,
                grade = classInfo?.Grade,
                courses = courses,
                scores = scores
            });
        }

        // GET: api/student/exercises/{studentId}
        [HttpGet("exercises/{studentId}")]
        public async Task<IActionResult> GetExercises(long studentId)
        {
            var student = await _context.Students.FindAsync(studentId);
            if (student == null)
                return NotFound();

            var exercises = await _context.Exercises
                .Where(e => e.ClassId == student.Classeid)
                .OrderByDescending(e => e.EndDate)
                .Select(e => new
                {
                    exerciseId = e.ExerciseId,
                    title = e.Title,
                    description = e.Description,
                    startDate = e.StartDate,
                    endDate = e.EndDate,
                    courseId = e.CourseId
                })
                .Take(20)
                .ToListAsync();

            return Ok(exercises);
        }

        // GET: api/student/exams/{studentId}
        [HttpGet("exams/{studentId}")]
        public async Task<IActionResult> GetExams(long studentId)
        {
            var student = await _context.Students.FindAsync(studentId);
            if (student == null)
                return NotFound();

            var exams = await _context.Exams
                .Where(e => e.ClassId == student.Classeid)
                .OrderByDescending(e => e.EndDate)
                .Select(e => new
                {
                    examId = e.ExamId,
                    title = e.Title,
                    description = e.Description,
                    startDate = e.StartDate,
                    endDate = e.EndDate,
                    courseId = e.CourseId
                })
                .Take(20)
                .ToListAsync();

            return Ok(exams);
        }

        // GET: api/student/profile/{studentId}
        [HttpGet("profile/{studentId}")]
        public async Task<IActionResult> GetProfile(long studentId)
        {
            var student = await _context.Students.FindAsync(studentId);
            if (student == null)
                return NotFound();

            return Ok(new
            {
                studentId = student.StudentId,
                name = student.Name,
                stuCode = student.StuCode,
                address = student.Address,
                parentNum1 = student.ParentNum1,
                parentNum2 = student.ParentNum2,
                birthdate = student.Birthdate,
                registerdate = student.Registerdate
            });
        }
    }
}