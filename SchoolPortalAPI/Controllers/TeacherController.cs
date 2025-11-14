using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SchoolPortalAPI.Data;
using SchoolPortalAPI.Models;

namespace SchoolPortalAPI.Controllers
{
    public class AddExerciseDto
    {
        public long Teacherid { get; set; }
        public long Courseid { get; set; }
        public string Title { get; set; } = null!;
        public string? Description { get; set; }
        public string? Enddate { get; set; }
        public string? Endtime { get; set; }
        public string? Startdate { get; set; }
        public string? Starttime { get; set; }
        public int? Score { get; set; }
    }

    public class UpdateExerciseDto
    {
        public long Teacherid { get; set; }
        public string? Title { get; set; }
        public string? Description { get; set; }
        public string? Enddate { get; set; }
        public string? Endtime { get; set; }
        public int? Score { get; set; }
    }

    [ApiController]
    [Route("api/teacher")]
    public class TeacherController : ControllerBase
    {
        private readonly SchoolDbContext _context;

        public TeacherController(SchoolDbContext context)
        {
            _context = context;
        }

        // ──────────────────────────────────────────────────────────────
        // 1. Get basic teacher dashboard info (ID, Name, Current Course)
        // ──────────────────────────────────────────────────────────────
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

        // ──────────────────────────────────────────────────────────────
        // 2. Get all students in teacher's class
        // ──────────────────────────────────────────────────────────────
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

        // ──────────────────────────────────────────────────────────────
        // 3. Get average score per course for this teacher
        // ──────────────────────────────────────────────────────────────
        [HttpGet("progress/{teacherId}")]
        public async Task<IActionResult> GetTeacherProgress(long teacherId)
        {
            var teacher = await _context.Teachers
                .Where(t => t.Userid == teacherId)
                .Select(t => t.Teacherid)
                .FirstOrDefaultAsync();

            if (teacher == 0) return NotFound("معلم یافت نشد");

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

        // ──────────────────────────────────────────────────────────────
        // 4. Get all courses taught by teacher with details + average grade
        // ──────────────────────────────────────────────────────────────
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
                    courseId = g.c.Courseid,
                    courseCode = g.c.Code ?? "",
                    teacherName = teacher.Name,
                    location = g.c.Location ?? "نامشخص",
                    time = g.c.Time ?? "نامشخص",
                    averageGrade = g.scores.Any()
                        ? Math.Round(g.scores.Average(s => s.ScoreValue), 1).ToString()
                        : "-"
                })
                .ToListAsync();

            return Ok(courses);
        }

        // ──────────────────────────────────────────────────────────────
        // 5. Get overall average grade across all teacher's courses
        // ──────────────────────────────────────────────────────────────
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

        // ──────────────────────────────────────────────────────────────
        // 6. Get teacher stats for dashboard cards
        //    - Last taught course
        //    - Total courses
        //    - Total students
        //    - Overall average
        // ──────────────────────────────────────────────────────────────
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

            var totalCourses = await _context.Courses
                .Where(c => c.Teacherid == teacher.Teacherid)
                .CountAsync();

            var totalStudents = await _context.Students
                .Where(s => _context.Courses.Any(c => c.Classid == s.Classeid && c.Teacherid == teacher.Teacherid))
                .CountAsync();

            var average = await _context.Scores
                .Where(s => s.Course != null && s.Course.Teacherid == teacher.Teacherid)
                .AverageAsync(s => (double?)s.ScoreValue) ?? 0.0;

            var stats = new[]
            {
                new { label = "آخرین درس",          value = lastCourseName ?? "ندارد", subtitle = "تدریس",     icon = "menu_book", color = "purple" },
                new { label = "تعداد دروس",        value = totalCourses.ToString(),    subtitle = "کل",        icon = "school",    color = "green"  },
                new { label = "تعداد دانش‌آموز",   value = totalStudents.ToString(),   subtitle = "کلاس‌ها",   icon = "group",     color = "orange" },
                new { label = "میانگین نمرات",     value = average.ToString("F1"),     subtitle = "کلاس‌ها",   icon = "grade",     color = "blue"   }
            };

            return Ok(stats);
        }

        // ──────────────────────────────────────────────────────────────
        // 7. Get teacher's full name for display (AppBar, Profile, etc.)
        // ──────────────────────────────────────────────────────────────
        [HttpGet("name/{userId}")]
        public async Task<IActionResult> GetTeacherName(long userId)
        {
            var name = await _context.Teachers
                .Where(t => t.Userid == userId)
                .Select(t => t.Name)
                .FirstOrDefaultAsync();

            return Ok(new { name = name ?? "معلم" });
        }

        // ──────────────────────────────────────────────────────────────
        // 8. Add new exercise
        // ──────────────────────────────────────────────────────────────
        [HttpPost("exercises")]
        public async Task<IActionResult> AddExercise([FromBody] AddExerciseDto model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var teacherIdd = await _context.Teachers
                            .Where(t => t.Userid == model.Teacherid)
                            .Select(t => t.Teacherid)
                            .FirstOrDefaultAsync();

            var course = await _context.Courses
                .FirstOrDefaultAsync(c => c.Courseid == model.Courseid && c.Teacherid == teacherIdd);

            if (course == null)
            {
                return BadRequest("درس یافت نشد یا متعلق به شما نیست");
            }

            var exercise = new Exercise
            {
                Title = model.Title,
                Description = model.Description,
                Enddate = model.Enddate,
                Endtime = model.Endtime,
                Startdate = model.Startdate,
                Starttime = model.Starttime,
                Score = model.Score,
                Courseid = model.Courseid,
                Classid = course.Classid
            };

            _context.Exercises.Add(exercise);
            await _context.SaveChangesAsync();

            return Ok(new { id = exercise.Exerciseid, message = "تمرین با موفقیت اضافه شد" });
        }

        // ──────────────────────────────────────────────────────────────
        // 9. Get exercises for teacher
        // ──────────────────────────────────────────────────────────────
        [HttpGet("exercises/{teacherId}")]
        public async Task<IActionResult> GetTeacherExercises(long teacherId)
        {
            var teacherIdd = await _context.Teachers
                .Where(t => t.Userid == teacherId)
                .Select(t => t.Teacherid)
                .FirstOrDefaultAsync();

            var teacherCourses = await _context.Courses
                .Where(c => c.Teacherid == teacherIdd)
                .Select(c => new { c.Courseid, c.Name, c.Classid })
                .ToListAsync();

            if (!teacherCourses.Any()) return Ok(new List<object>());

            var exercises = await _context.Exercises
                .Where(e => teacherCourses.Select(tc => tc.Courseid).Contains(e.Courseid.Value))
                .ToListAsync();

            var result = new List<object>();

            foreach (var e in exercises)
            {
                var course = teacherCourses.FirstOrDefault(tc => tc.Courseid == e.Courseid);
                if (course == null) continue;

                var totalStudents = await _context.Students
                    .Where(s => s.Classeid == course.Classid)
                    .CountAsync();

                var submissions = await _context.ExerciseStuTeaches
                    .Where(est => est.Exerciseid == e.Exerciseid)
                    .CountAsync();

                var percentage = totalStudents > 0 ? Math.Round((double)submissions / totalStudents * 100) : 0;

                result.Add(new
                {
                    id = e.Exerciseid,
                    title = e.Title ?? "بدون عنوان",
                    subject = course.Name ?? "نامشخص",
                    dueDate = e.Enddate ?? "نامشخص",
                    dueTime = e.Endtime ?? "نامشخص",
                    score = e.Score?.ToString() ?? "0",
                    submissions = $"{submissions}/{totalStudents}",
                    percentage = $"{percentage}%",
                    // color not in backend
                });
            }

            return Ok(result);
        }

        // ──────────────────────────────────────────────────────────────
        // 10. Update exercise
        // ──────────────────────────────────────────────────────────────
        [HttpPut("exercises/{exerciseId}")]
        public async Task<IActionResult> UpdateExercise(long exerciseId, [FromBody] UpdateExerciseDto model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var exercise = await _context.Exercises.FindAsync(exerciseId);
            if (exercise == null) return NotFound("تمرین یافت نشد");

            var course = await _context.Courses.FindAsync(exercise.Courseid);
            if (course == null || course.Teacherid != model.Teacherid)
            {
                return BadRequest("مجوز ویرایش ندارید");
            }

            exercise.Title = model.Title ?? exercise.Title;
            exercise.Description = model.Description ?? exercise.Description;
            exercise.Enddate = model.Enddate ?? exercise.Enddate;
            exercise.Endtime = model.Endtime ?? exercise.Endtime;
            exercise.Score = model.Score ?? exercise.Score;

            await _context.SaveChangesAsync();

            return Ok(new { message = "تمرین به‌روزرسانی شد" });
        }

        // ──────────────────────────────────────────────────────────────
        // 11. Delete exercise
        // ──────────────────────────────────────────────────────────────
        [HttpDelete("exercises/{exerciseId}")]
        public async Task<IActionResult> DeleteExercise(long exerciseId, [FromQuery] long teacherId)
        {
            var exercise = await _context.Exercises.FindAsync(exerciseId);
            if (exercise == null) return NotFound("تمرین یافت نشد");

            var teacherIdd = await _context.Teachers
                            .Where(t => t.Userid == teacherId)
                            .Select(t => t.Teacherid)
                            .FirstOrDefaultAsync();

            var course = await _context.Courses.FindAsync(exercise.Courseid);
            if (course == null || course.Teacherid != teacherIdd)
            {
                return BadRequest("مجوز حذف ندارید");
            }

            _context.Exercises.Remove(exercise);
            await _context.SaveChangesAsync();

            return Ok(new { message = "تمرین حذف شد" });
        }

        // ──────────────────────────────────────────────────────────────
        // 12. Get submissions for exercise
        // ──────────────────────────────────────────────────────────────
        [HttpGet("exercises/{exerciseId}/submissions")]
        public async Task<IActionResult> GetSubmissions(long exerciseId, [FromQuery] long teacherId)
        {
            var teacherIdd = await _context.Teachers
                                        .Where(t => t.Userid == teacherId)
                                        .Select(t => t.Teacherid)
                                        .FirstOrDefaultAsync();

            var exercise = await _context.Exercises.FindAsync(exerciseId);
            if (exercise == null) return NotFound("تمرین یافت نشد");

            var course = await _context.Courses.FindAsync(exercise.Courseid);
            if (course == null || course.Teacherid != teacherIdd)
            {
                return BadRequest("مجوز مشاهده ندارید");
            }

            var submissions = await (from est in _context.ExerciseStuTeaches
                                     where est.Exerciseid == exerciseId
                                     join s in _context.Students on est.Studentid equals s.Studentid into studentGroup
                                     from student in studentGroup.DefaultIfEmpty()
                                     select new
                                     {
                                         studentId = est.Studentid,
                                         studentName = student != null ? student.Name : "نامشخص",
                                         score = est.Score,
                                         answerImage = est.Answerimage,
                                         filename = est.Filename,
                                         date = est.Date
                                     }).ToListAsync();

            return Ok(submissions);
        }
    }
}