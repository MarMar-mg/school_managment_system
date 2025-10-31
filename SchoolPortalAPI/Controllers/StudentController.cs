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

        [HttpGet("exercises/{studentId}")]
        public async Task<IActionResult> GetExercises(long studentId)
        {
            var exercises = await _context.ExerciseStuTeaches
                .Where(e => e.Studentid == studentId)
                .Select(e => new
                {
                    ExerciseId = e.Exerciseid,
                    Title = _context.Exercises
                        .Where(ex => ex.Exerciseid == e.Exerciseid)
                        .Select(ex => ex.Title)
                        .FirstOrDefault(),
                    e.Score,
                    e.Answerimage,
                    e.Date
                })
                .ToListAsync();

            return Ok(exercises);
        }

        [HttpGet("exams/{studentId}")]
        public async Task<IActionResult> GetExams(long studentId)
        {
            var exams = await _context.ExamStuTeaches
                .Where(e => e.Studentid == studentId)
                .Select(e => new
                {
                    ExamId = e.Examid,
                    Title = _context.Exams
                        .Where(ex => ex.Examid == e.Examid)
                        .Select(ex => ex.Title)
                        .FirstOrDefault(),
                    e.Score,
                    e.Answerimage,
                    e.Date
                })
                .ToListAsync();

            return Ok(exams);
        }

        [HttpGet("profile/{studentId}")]
        public async Task<IActionResult> GetProfile(long studentId)
        {
            var student = await _context.Students.FindAsync(studentId);
            if (student == null) return NotFound();
            return Ok(student);
        }
    }
}