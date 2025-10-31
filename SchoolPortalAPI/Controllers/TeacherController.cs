using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace SchoolSystemAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TeacherController : ControllerBase
    {
        private readonly SchoolDbContext _context;

        public TeacherController(SchoolDbContext context)
        {
            _context = context;
        }

        // GET: api/teacher/dashboard/{userId}
        [HttpGet("dashboard/{userId}")]
        public async Task<IActionResult> GetDashboard(long userId)
        {
            var teacher = await _context.Teachers
                .FirstOrDefaultAsync(t => t.UserId == userId);

            if (teacher == null)
                return NotFound(new { message = "معلم یافت نشد" });

            // Get teacher's courses
            var courses = await _context.Courses
                .Where(c => c.TeacherId == teacher.TeacherId)
                .Select(c => new
                {
                    courseId = c.CourseId,
                    courseName = c.Name,
                    classTime = c.ClassTime,
                    finalExamDate = c.FinalExamDate
                })
                .ToListAsync();

            return Ok(new
            {
                teacherName = teacher.Name,
                teacherId = teacher.TeacherId,
                courses = courses
            });
        }

        // GET: api/teacher/students/{teacherId}
        [HttpGet("students/{teacherId}")]
        public async Task<IActionResult> GetStudents(long teacherId)
        {
            var teacher = await _context.Teachers.FindAsync(teacherId);
            if (teacher == null)
                return NotFound();

            // Get course's class
            var course = await _context.Courses.FindAsync(teacher.CourseId);
            if (course == null)
                return Ok(new List<object>());

            var students = await _context.Students
                .Where(s => s.Classeid == course.ClassId)
                .Select(s => new
                {
                    studentId = s.StudentId,
                    name = s.Name,
                    stuCode = s.StuCode
                })
                .ToListAsync();

            return Ok(students);
        }
    }
}
