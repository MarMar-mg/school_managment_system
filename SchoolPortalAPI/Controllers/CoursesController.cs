using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace SchoolSystemAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CoursesController : ControllerBase
    {
        private readonly SchoolDbContext _context;

        public CoursesController(SchoolDbContext context)
        {
            _context = context;
        }

        // GET: api/courses
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var courses = await _context.Courses
                .Select(c => new
                {
                    courseId = c.CourseId,
                    name = c.Name,
                    classTime = c.ClassTime,
                    finalExamDate = c.FinalExamDate,
                    classId = c.ClassId,
                    teacherId = c.TeacherId
                })
                .ToListAsync();

            return Ok(courses);
        }

        // GET: api/courses/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(long id)
        {
            var course = await _context.Courses.FindAsync(id);
            if (course == null)
                return NotFound();

            return Ok(course);
        }

        // GET: api/courses/class/{classId}
        [HttpGet("class/{classId}")]
        public async Task<IActionResult> GetByClassId(long classId)
        {
            var courses = await _context.Courses
                .Where(c => c.ClassId == classId)
                .Select(c => new
                {
                    courseId = c.CourseId,
                    name = c.Name,
                    classTime = c.ClassTime,
                    finalExamDate = c.FinalExamDate
                })
                .ToListAsync();

            return Ok(courses);
        }
    }
}