using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SchoolPortalAPI.Data;
using SchoolPortalAPI.Models;

namespace SchoolPortalAPI.Controllers
{
    [ApiController]
    [Route("api/course")]
    public class CoursesController : ControllerBase
    {
        private readonly SchoolDbContext _context;

        public CoursesController(SchoolDbContext context)
        {
            _context = context;
        }

        // ==================== GET: api/course ====================
        // Returns all courses with class and teacher names
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var courses = await _context.Courses.ToListAsync();

            var result = courses.Select(c => new
            {
                c.Courseid,
                c.Name,
                c.Finalexamdate,
                c.Classtime,
                ClassName = GetClassName(c.Classid),
                TeacherName = GetTeacherName(c.Teacherid)
            }).ToList();

            return Ok(result);
        }

        // ==================== GET: api/course/{id} ====================
        // Returns a specific course by ID
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(long id)
        {
            var course = await _context.Courses.FindAsync(id);

            if (course == null)
            {
                return NotFound(new { message = "Course not found" });
            }

            return Ok(course);
        }

        // ==================== Helper Methods ====================

        private string? GetClassName(long? classId)
        {
            if (classId == null)
            {
                return null;
            }

            var classObj = _context.Classes
                .FirstOrDefault(cl => cl.Classid == classId);

            return classObj?.Name;
        }

        private string? GetTeacherName(long? teacherId)
        {
            if (teacherId == null)
            {
                return null;
            }

            var teacherObj = _context.Teachers
                .FirstOrDefault(t => t.Teacherid == teacherId);

            return teacherObj?.Name;
        }
    }
}