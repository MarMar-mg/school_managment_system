// Controllers/CoursesController.cs
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

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var courses = await _context.Courses
                .ToListAsync();

            var result = courses.Select(c =>
            {
                string? className = null;
                if (c.Classid != null)
                {
                    var classObj = _context.Classes.FirstOrDefault(cl => cl.Classid == c.Classid);
                    className = classObj?.Name;
                }

                string? teacherName = null;
                if (c.Teacherid != null)
                {
                    var teacherObj = _context.Teachers.FirstOrDefault(t => t.Teacherid == c.Teacherid);
                    teacherName = teacherObj?.Name;
                }

                return new
                {
                    c.Courseid,
                    c.Name,
                    c.Finalexamdate,
                    c.Classtime,
                    ClassName = className,
                    TeacherName = teacherName
                };
            }).ToList();

            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(long id)
        {
            var course = await _context.Courses.FindAsync(id);
            if (course == null) return NotFound();
            return Ok(course);
        }
    }
}