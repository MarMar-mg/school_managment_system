using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SchoolPortalAPI.Data;
using SchoolPortalAPI.Models;
using System.IO;
using Microsoft.AspNetCore.Authorization;

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

    public class AddExamDto
    {
        public long Teacherid { get; set; }
        public long Courseid { get; set; }
        public string Title { get; set; } = null!;
        public string? Enddate { get; set; }
        public string? Endtime { get; set; }
        public string? Startdate { get; set; }
        public string? Starttime { get; set; }
        public int? PossibleScore { get; set; }
        public int? Duration { get; set; }
        public string? Description { get; set; }
    }

    public class UpdateExamDto
    {
        public long Teacherid { get; set; }
        public string? Title { get; set; }
        public string? Enddate { get; set; }
        public string? Endtime { get; set; }
        public int? PossibleScore { get; set; }
        public int? Duration { get; set; }
        public string? Description { get; set; }
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
        // 8. Add new exercise (with optional file) + notify students
        // ──────────────────────────────────────────────────────────────
        [HttpPost("exercises")]
        public async Task<IActionResult> AddExercise([FromForm] AddExerciseDto model, IFormFile? file)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // 1. Find teacher ID from UserId
            var teacherIdd = await _context.Teachers
                .Where(t => t.Userid == model.Teacherid)
                .Select(t => t.Teacherid)
                .FirstOrDefaultAsync();

            if (teacherIdd == 0)
                return Unauthorized("معلم معتبر یافت نشد");

            // 2. Validate course belongs to this teacher
            var course = await _context.Courses
                .FirstOrDefaultAsync(c => c.Courseid == model.Courseid && c.Teacherid == teacherIdd);

            if (course == null)
            {
                return BadRequest("درس یافت نشد یا متعلق به شما نیست");
            }

            // 3. Handle file upload (your existing logic – slightly improved)
            string? fileName = null;
            if (file != null && file.Length > 0)
            {
                var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "exercises");
                Directory.CreateDirectory(uploadsFolder);

                fileName = $"{Guid.NewGuid()}_{file.FileName}";
                var filePath = Path.Combine(uploadsFolder, fileName);

                await using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                Console.WriteLine($"[ADD EXERCISE] File saved: {fileName}");
            }

            // 4. Create the exercise
            var exercise = new Exercise
            {
                Title       = model.Title,
                Description = model.Description,
                Enddate     = model.Enddate,
                Endtime     = model.Endtime,
                Startdate   = model.Startdate,
                Starttime   = model.Starttime,
                Score       = model.Score,
                Courseid    = model.Courseid,
                Classid     = course.Classid,          // ← from course
                Filename    = file?.FileName,          // original name
                File        = fileName,                // stored unique name (or null)
            };

            _context.Exercises.Add(exercise);

            // 5. Save exercise first → we need exercise.Exerciseid for RelatedId
            await _context.SaveChangesAsync();

            // ──────────────────────────────────────────────
            // 6. Send notifications to students in the class/course
            // ──────────────────────────────────────────────

            // Find students in the same class (adjust if you use different relation)
            var students = await _context.Students
                .Where(s => s.Classeid == course.Classid)
                .ToListAsync();

            foreach (var student in students)
            {
                var notification = new Notification
                {
                    UserId      = student.UserID ?? 0,
                    Title       = "تمرین جدید اضافه شد",
                    Body        = $"درس {course.Name ?? "نامشخص"} – عنوان: {exercise.Title} – مهلت ارسال: {exercise.Enddate} {exercise.Endtime}",
                    Type        = "exercise",
                    RelatedId   = exercise.Exerciseid,
                    RelatedType = "exercise",
                    CreatedAt   = DateTime.UtcNow
                };

                _context.Notifications.Add(notification);
            }

            // Optional: Notify the teacher (confirmation / log)
            var teacherUser = await _context.Users.FirstOrDefaultAsync(u => u.Userid == model.Teacherid);
            if (teacherUser != null)
            {
                _context.Notifications.Add(new Notification
                {
                    UserId      = teacherUser.Userid,
                    Title       = "تمرین شما ثبت شد",
                    Body        = $"تمرین {exercise.Title} با موفقیت ایجاد گردید.",
                    Type        = "exercise_created",
                    RelatedId   = exercise.Exerciseid,
                    RelatedType = "exercise",
                    CreatedAt   = DateTime.UtcNow
                });
            }

            // 7. Final save (exercise + notifications)
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException ex)
            {
                return StatusCode(500, new
                {
                    message = "خطا در ذخیره تمرین یا ارسال اعلان‌ها",
                    detail = ex.InnerException?.Message ?? ex.Message
                });
            }

            return Ok(new
            {
                id = exercise.Exerciseid,
                message = "تمرین با موفقیت اضافه شد",
                filename = fileName
            });
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
                    description = e.Description,
                    score = e.Score?.ToString() ?? "0",
                    submissions = $"{submissions}/{totalStudents}",
                    percentage = $"{percentage}%",
                    File = e.File,
                    courseId = e.Courseid,
                    Filename = e.Filename
                });
            }

            return Ok(result);
        }

        // ──────────────────────────────────────────────────────────────
        // 10. Update exercise (with optional file) + notify students
        // ──────────────────────────────────────────────────────────────
        [HttpPut("exercises/{exerciseId}")]
        public async Task<IActionResult> UpdateExercise(long exerciseId, [FromForm] UpdateExerciseDto model, IFormFile? file)
        {
            // 1. Find teacher ID from UserId
            var teacherIdd = await _context.Teachers
                .Where(t => t.Userid == model.Teacherid)
                .Select(t => t.Teacherid)
                .FirstOrDefaultAsync();

            if (teacherIdd == 0)
                return Unauthorized("معلم معتبر یافت نشد");

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // 2. Find the exercise + include Course
            var exercise = await _context.Exercises
                .Include(e => e.Course)               // for course name in notification
                .FirstOrDefaultAsync(e => e.Exerciseid == exerciseId);

            if (exercise == null)
                return NotFound("تمرین یافت نشد");

            // 3. Authorization check
            var course = exercise.Course;
            if (course == null || course.Teacherid != teacherIdd)
                return BadRequest("مجوز ویرایش این تمرین را ندارید");

            // 4. Handle file upload (your logic – slightly cleaned)
            string? fileName = exercise.File; // keep old if no new file

            if (file != null && file.Length > 0)
            {
                // Delete old file if exists
                if (!string.IsNullOrEmpty(exercise.File))
                {
                    var oldFilePath = Path.Combine(
                        Directory.GetCurrentDirectory(),
                        "wwwroot", "uploads", "exercises",
                        exercise.File);

                    if (System.IO.File.Exists(oldFilePath))
                    {
                        try
                        {
                            System.IO.File.Delete(oldFilePath);
                            Console.WriteLine($"[UPDATE EXERCISE] Deleted old file: {exercise.File}");
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"[UPDATE EXERCISE] Failed to delete old file: {ex.Message}");
                        }
                    }
                }

                // Save new file
                var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "exercises");
                Directory.CreateDirectory(uploadsFolder);

                fileName = $"{Guid.NewGuid()}_{file.FileName}";
                var filePath = Path.Combine(uploadsFolder, fileName);

                await using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                Console.WriteLine($"[UPDATE EXERCISE] File saved: {fileName}");
            }

            // 5. Apply updates (only if new value provided)
            exercise.Title       = model.Title ?? exercise.Title;
            exercise.Description = model.Description ?? exercise.Description;
            exercise.Enddate     = model.Enddate ?? exercise.Enddate;
            exercise.Endtime     = model.Endtime ?? exercise.Endtime;
            exercise.Score       = model.Score ?? exercise.Score;
            exercise.Filename    = file?.FileName;   // original filename
            exercise.File        = fileName;         // stored unique name (or null)

            // 6. Save exercise changes first
            await _context.SaveChangesAsync();

            // ──────────────────────────────────────────────
            // 7. Send notifications to students in the class/course
            // ──────────────────────────────────────────────

            // Find students in the same class as the exercise
            var students = await _context.Students
                .Where(s => s.Classeid == course.Classid)
                .ToListAsync();

            foreach (var student in students)
            {
                var notification = new Notification
                {
                    UserId      = student.UserID ?? 0,
                    Title       = "تمرین به‌روزرسانی شد",
                    Body        = $"تمرین {exercise.Title} در درس {course.Name ?? "نامشخص"} ویرایش شد. لطفاً مهلت ارسال، توضیحات یا فایل جدید را بررسی کنید.",
                    Type        = "exercise_updated",
                    RelatedId   = exercise.Exerciseid,
                    RelatedType = "exercise",
                    CreatedAt   = DateTime.UtcNow
                };

                _context.Notifications.Add(notification);
            }

            // Optional: Notify the teacher (confirmation)
            var teacherUser = await _context.Users.FirstOrDefaultAsync(u => u.Userid == model.Teacherid);
            if (teacherUser != null)
            {
                _context.Notifications.Add(new Notification
                {
                    UserId      = teacherUser.Userid,
                    Title       = "تمرین شما ویرایش شد",
                    Body        = $"تمرین {exercise.Title} با موفقیت به‌روزرسانی گردید.",
                    Type        = "exercise_teacher_update",
                    RelatedId   = exercise.Exerciseid,
                    RelatedType = "exercise",
                    CreatedAt   = DateTime.UtcNow
                });
            }

            // 8. Final save (exercise + notifications)
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException ex)
            {
                return StatusCode(500, new
                {
                    message = "خطا در ذخیره تغییرات یا ارسال اعلان‌ها",
                    detail = ex.InnerException?.Message ?? ex.Message
                });
            }

            return Ok(new
            {
                message = "تمرین با موفقیت به‌روزرسانی شد",
                filename = fileName,
                exerciseId = exercise.Exerciseid
            });
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
                                         submittedDescription = est.Description,
                                         date = est.Date
                                     }).ToListAsync();

            return Ok(submissions);
        }

        // ──────────────────────────────────────────────────────────────
          // 13. Get Exams
          // ──────────────────────────────────────────────────────────────
          [HttpGet("exams/{teacherId}")]
          public async Task<IActionResult> GetTeacherExams(long teacherId)
          {
              var teacherIdd = await _context.Teachers
                   .Where(t => t.Userid == teacherId)
                   .Select(t => t.Teacherid)
                   .FirstOrDefaultAsync();

              var examData = await _context.Exams
                  .Include(e => e.Course)
                  .Include(e => e.Class)
                  .Where(e => e.Course != null && e.Course.Teacherid == teacherIdd)
                  .ToListAsync();

              var nowUtc = DateTime.UtcNow;
              var result = new List<object>();

              var iranTimeZone = TimeZoneInfo.FindSystemTimeZoneById("Iran Standard Time");

              foreach (var e in examData)
              {
                  // Get class capacity
                  int capacity = e.Class?.Capacity ?? 0;

                  // Get submission counts
                  int submitted = await _context.ExamStuTeaches.CountAsync(est => est.Examid == e.Examid);
                  int passCount = await _context.ExamStuTeaches.CountAsync(est =>
                      est.Examid == e.Examid &&
                      est.Score >= (e.PossibleScore ?? 100) * 0.5);
                  int gradedCount = await _context.ExamStuTeaches.CountAsync(est =>
                      est.Examid == e.Examid &&
                      est.Score != null);

                  // Check if exam is future or completed based on END date and time
                  bool isFuture = true;

                  if (!string.IsNullOrEmpty(e.Enddate) && !string.IsNullOrEmpty(e.Endtime))
                  {
                      // Parse end date (Jalali format: YYYY-MM-DD)
                      string[] dateParts = e.Enddate.Split('-');
                      if (dateParts.Length == 3 &&
                          int.TryParse(dateParts[0], out int jyear) &&
                          int.TryParse(dateParts[1], out int jmonth) &&
                          int.TryParse(dateParts[2], out int jday))
                      {
                          // Parse end time (HH:MM format)
                          string[] timeParts = e.Endtime.Split(':');
                          int endHour = 0, endMinute = 0;
                          if (timeParts.Length >= 2)
                          {
                              int.TryParse(timeParts[0], out endHour);
                              int.TryParse(timeParts[1], out endMinute);
                          }

                          // Convert Jalali date to Gregorian
                          DateTime examEndDateTime = JalaliToGregorian(jyear, jmonth, jday);

                          // Explicitly set to the beginning of the day
                          examEndDateTime = examEndDateTime.Date;

                          // Add the end time to the date
                          examEndDateTime = examEndDateTime.AddHours(endHour).AddMinutes(endMinute);

                          // Convert to UTC assuming the exam time is in Iran Standard Time
                          DateTime examEndDateTimeUtc = TimeZoneInfo.ConvertTimeToUtc(examEndDateTime, iranTimeZone);

                          // Compare current UTC time with exam end time in UTC
                          // If now is AFTER exam end time, exam is completed
                          isFuture = nowUtc < examEndDateTimeUtc;
                      }
                  }

                  double? passPercentage = null;
                  if (submitted > 0)
                      passPercentage = Math.Round(passCount * 100.0 / submitted, 1);

                  result.Add(new
                  {
                      id = e.Examid,
                      title = e.Title,
                      description = e.Description,
                      status = !isFuture ? "completed" : "upcoming",
                      subject = e.Course != null ? e.Course.Name : "نامشخص",
                      date = e.Startdate,
                      classId = e.Classid,
                      courseId = e.Courseid,
                      capacity = capacity,
                      submitted = submitted,
                      graded = gradedCount,
                      possibleScore = e.PossibleScore,
                      location = e.Class?.Name ?? "نامشخص",
                      passPercentage = passPercentage,
                      filledCapacity = $"{submitted}/{capacity}",
                      classTime = e.Starttime,
                      duration = e.Duration,
                      File = e.File,
                      Filename = e.Filename
                  });
              }

              return Ok(result);
          }

        // ──────────────────────────────────────────────────────────────
        // 14. Get Exams Submissions
        // ──────────────────────────────────────────────────────────────
        [HttpGet("exams/{examId}/submissions")]
        public async Task<IActionResult> GetExamSubmissions(long examId)
        {
            var exam = await _context.Exams.FirstOrDefaultAsync(e => e.Examid == examId);
            if (exam == null)
                return NotFound("Exam not found");

            var submissions = await _context.ExamStuTeaches
                .Include(est => est.Student)
                .Where(est => est.Examid == examId)
                .Select(est => new
                {
                    submissionId = est.Estid,
                    examId = est.Examid,
                    studentId = est.Studentid,
                    studentName = est.Student != null ? est.Student.Name : "نامشخص",
                    score = est.Score,
                    submittedAt = est.Date ?? DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"),
                    answerFile = est.Filename,
                    submittedDescription = est.Description
                })
                .ToListAsync();

            return Ok(submissions);
        }

        // ──────────────────────────────────────────────────────────────
        // 16. Update Exams Score (group/batch) + notify affected students
        // ──────────────────────────────────────────────────────────────
        [HttpPost("exams/{examId}/scores/batch")]
        public async Task<IActionResult> BatchUpdateScores(long examId, [FromBody] List<BatchScoreUpdate> scores)
        {
            if (scores == null || !scores.Any())
            {
                return BadRequest("هیچ نمره‌ای برای به‌روزرسانی ارسال نشده است");
            }

            // 1. Validate exam exists
            var exam = await _context.Exams
                .Include(e => e.Course)           // optional: for course name in notification
                .FirstOrDefaultAsync(e => e.Examid == examId);

            if (exam == null)
                return NotFound(new { message = "امتحان یافت نشد" });

            // 2. Validate all scores are in valid range
            foreach (var scoreUpdate in scores)
            {
                if (scoreUpdate.Score < 0 || scoreUpdate.Score > exam.PossibleScore)
                {
                    return BadRequest(new
                    {
                        message = $"نمره باید بین ۰ تا {exam.PossibleScore} باشد",
                        invalidSubmissionId = scoreUpdate.SubmissionId
                    });
                }
            }

            // 3. Collect submissions to update + prepare notifications
            var updatedSubmissions = new List<ExamStuTeach>();
            var notificationsToAdd = new List<Notification>();

            var courseName = exam.Course?.Name ?? "نامشخص";

            // To avoid N+1 queries → load all relevant submissions in one go
            var submissionIds = scores.Select(s => s.SubmissionId).ToList();
            var existingSubmissions = await _context.ExamStuTeaches
                .Include(est => est.Student)
                .Where(est => est.Examid == examId && submissionIds.Contains(est.Estid))
                .ToDictionaryAsync(est => est.Estid);

            foreach (var scoreUpdate in scores)
            {
                if (!existingSubmissions.TryGetValue(scoreUpdate.SubmissionId, out var submission))
                {
                    // Skip or log – depending on your policy
                    continue; // or return BadRequest if you want strict mode
                }

                // Update score
                submission.Score = (int)scoreUpdate.Score;
                _context.ExamStuTeaches.Update(submission);
                updatedSubmissions.Add(submission);

                // Create notification for the student (if they have a linked user)
                if (submission.Student?.UserID > 0)
                {
                    var notification = new Notification
                    {
                        UserId      = submission.Student.UserID ?? 0,
                        Title       = "نمره امتحان شما ثبت شد",
                        Body        = $"امتحان {exam.Title} در درس {courseName} – نمره: {scoreUpdate.Score} از {exam.PossibleScore}",
                        Type        = "grade",
                        RelatedId   = exam.Examid,
                        RelatedType = "exam",
                        CreatedAt   = DateTime.UtcNow
                    };

                    notificationsToAdd.Add(notification);
                }
            }

            // 4. Save everything in one transaction
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException ex)
            {
                // In real app: log exception
                return StatusCode(500, new
                {
                    message = "خطا در ذخیره نمرات یا ارسال اعلان‌ها",
                    detail = ex.InnerException?.Message ?? ex.Message
                });
            }

            // 5. Return success with summary
            return Ok(new
            {
                message = $"نمرات {updatedSubmissions.Count} دانش‌آموز با موفقیت به‌روزرسانی شد",
                updatedCount = updatedSubmissions.Count,
                examId = exam.Examid
            });
        }

        // ──────────────────────────────────────────────────────────────
        // 17. Get Exams Statistic
        // ──────────────────────────────────────────────────────────────
        [HttpGet("exams/{examId}/stats")]
        public async Task<IActionResult> GetExamStats(long examId)
        {
            var exam = await _context.Exams
                .Include(e => e.Course)
                .FirstOrDefaultAsync(e => e.Examid == examId);

            if (exam == null)
                return NotFound("Exam not found");

            var allStudents = await _context.Students
                .Where(s => s.Classeid == exam.Classid)
                .ToListAsync();

            var submissions = await _context.ExamStuTeaches
                .Where(est => est.Examid == examId)
                .ToListAsync();

            var submission = submissions.Where(es => es.Date != null).ToList();

            var gradedSubmissions = submissions.Where(s => s.Score.HasValue).ToList();

            double avgScore = gradedSubmissions.Count > 0
                ? gradedSubmissions.Average(s => (double)s.Score.Value)
                : 0;

            double passPercentage = submissions.Count > 0
                ? (gradedSubmissions.Count(s => s.Score >= (exam.PossibleScore * 0.5)) * 100.0 / allStudents.Count)
                : 0;

            return Ok(new
            {
                examId = exam.Examid,
                title = exam.Title,
                subject = exam.Course?.Name ?? "نامشخص",
                possibleScore = exam.PossibleScore,
                totalSubmissions = submission.Count,
                gradedSubmissions = gradedSubmissions.Count,
                pendingSubmissions = submissions.Count - gradedSubmissions.Count,
                averageScore = Math.Round(avgScore, 2),
                passPercentage = Math.Round(passPercentage, 1),
                maxScore = gradedSubmissions.Count > 0 ? gradedSubmissions.Max(s => s.Score) : null,
                minScore = gradedSubmissions.Count > 0 ? gradedSubmissions.Min(s => s.Score) : null
            });
        }

        // ──────────────────────────────────────────────────────────────
        // 17-b. Get Exercises Statistic
        // ──────────────────────────────────────────────────────────────
        [HttpGet("exercises/{exerciseId}/stats")]
        public async Task<IActionResult> GetExercisesStats(long exerciseId)
        {
            var exercises = await _context.Exercises
                .Include(e => e.Course)
                .FirstOrDefaultAsync(e => e.Exerciseid == exerciseId);

            if (exercises == null)
                return NotFound("exercises not found");

            var allStudents = await _context.Students
                .Where(s => s.Classeid == exercises.Classid)
                .ToListAsync();

            var submissions = await _context.ExerciseStuTeaches
                .Where(est => est.Exerciseid == exerciseId)
                .ToListAsync();

            var submission = submissions.Where(es => es.Date != null).ToList();

            var gradedSubmissions = submissions.Where(s => s.Score.HasValue).ToList();

            double avgScore = gradedSubmissions.Count > 0
                ? gradedSubmissions.Average(s => (double)s.Score.Value)
                : 0;

            double passPercentage = submissions.Count > 0
                ? (gradedSubmissions.Count(s => s.Score >= (exercises.Score * 0.5)) * 100.0 / allStudents.Count)
                : 0;

            return Ok(new
            {
                exercisesId = exercises.Exerciseid,
                title = exercises.Title,
                subject = exercises.Course?.Name ?? "نامشخص",
                score = exercises.Score,
                totalSubmissions = submission.Count,
                gradedSubmissions = gradedSubmissions.Count,
                pendingSubmissions = submissions.Count - gradedSubmissions.Count,
                averageScore = Math.Round(avgScore, 2),
                passPercentage = Math.Round(passPercentage, 1),
                maxScore = gradedSubmissions.Count > 0 ? gradedSubmissions.Max(s => s.Score) : null,
                minScore = gradedSubmissions.Count > 0 ? gradedSubmissions.Min(s => s.Score) : null
            });
        }

        // ──────────────────────────────────────────────────────────────
        // 18. Add New Exams (with optional file) + notify students
        // ──────────────────────────────────────────────────────────────
        [HttpPost("exams")]
        public async Task<IActionResult> CreateExam([FromForm] AddExamDto model, IFormFile? file)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // 1. Find teacher ID from UserId
            var teacherIdd = await _context.Teachers
                .Where(t => t.Userid == model.Teacherid)
                .Select(t => t.Teacherid)
                .FirstOrDefaultAsync();

            if (teacherIdd == 0)
                return Unauthorized("معلم معتبر یافت نشد");

            // 2. Validate course belongs to this teacher
            var course = await _context.Courses
                .FirstOrDefaultAsync(c => c.Courseid == model.Courseid && c.Teacherid == teacherIdd);

            if (course == null)
            {
                return BadRequest("درس یافت نشد یا متعلق به شما نیست");
            }

            // 3. Handle file upload (your existing logic – slightly improved)
            string? fileName = null;
            if (file != null && file.Length > 0)
            {
                var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "exams");
                Directory.CreateDirectory(uploadsFolder);

                fileName = $"{Guid.NewGuid()}_{file.FileName}";
                var filePath = Path.Combine(uploadsFolder, fileName);

                await using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                Console.WriteLine($"[CREATE EXAM] File saved: {fileName}");
            }

            // 4. Create the exam
            var exam = new Exam
            {
                Title         = model.Title,
                Enddate       = model.Enddate,
                Endtime       = model.Endtime,
                Startdate     = model.Startdate,
                Starttime     = model.Starttime,
                PossibleScore = model.PossibleScore,
                Courseid      = model.Courseid,
                Classid       = course.Classid,           // ← from course
                Description   = model.Description,
                Duration      = model.Duration,
                Filename      = file?.FileName,           // original name
                File          = fileName,                 // stored unique name
            };

            _context.Exams.Add(exam);

            // 5. Save exam first → we need exam.Examid for RelatedId
            await _context.SaveChangesAsync();

            // ──────────────────────────────────────────────
            // 6. Send notifications to students in the class/course
            // ──────────────────────────────────────────────

            // Find students in the same class (adjust if you use different relation)
            var students = await _context.Students
                .Where(s => s.Classeid == course.Classid)
                .ToListAsync();


            foreach (var student in students)
            {
                var notification = new Notification
                {
                    UserId      = student.UserID ?? 0,
                    Title       = "امتحان جدید اضافه شد",
                    Body        = $"امتحان {exam.Title} در درس {course.Name ?? "نامشخص"} – تاریخ: {exam.Startdate} تا {exam.Enddate}",
                    Type        = "exam",
                    RelatedId   = exam.Examid,
                    RelatedType = "exam",
                    CreatedAt   = DateTime.UtcNow
                };

                _context.Notifications.Add(notification);
            }

            // Optional: Notify the teacher (confirmation / log)
            var teacherUser = await _context.Users.FirstOrDefaultAsync(u => u.Userid == model.Teacherid);
            if (teacherUser != null)
            {
                _context.Notifications.Add(new Notification
                {
                    UserId      = teacherUser.Userid,
                    Title       = "امتحان شما ثبت شد",
                    Body        = $"امتحان {exam.Title} با موفقیت ایجاد گردید.",
                    Type        = "exam_created",
                    RelatedId   = exam.Examid,
                    RelatedType = "exam",
                    CreatedAt   = DateTime.UtcNow
                });
            }

            // 7. Final save (exam + notifications)
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException ex)
            {
                return StatusCode(500, new
                {
                    message = "خطا در ذخیره امتحان یا ارسال اعلان‌ها",
                    detail = ex.InnerException?.Message ?? ex.Message
                });
            }

            return Ok(new
            {
                id = exam.Examid,
                message = "امتحان با موفقیت اضافه شد",
                filename = fileName
            });
        }

        // ──────────────────────────────────────────────────────────────
        // 19. Update Exam (with optional file) + send notifications to students
        // ──────────────────────────────────────────────────────────────
        [HttpPut("exams/{examId}")]
        public async Task<IActionResult> UpdateExam(long examId, [FromForm] UpdateExamDto model, IFormFile? file)
        {
            // 1. Find the teacher ID from UserId (your existing logic)
            var teacherIdd = await _context.Teachers
                .Where(t => t.Userid == model.Teacherid)
                .Select(t => t.Teacherid)
                .FirstOrDefaultAsync();

            if (teacherIdd == 0)
                return Unauthorized("معلم معتبر یافت نشد");

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // 2. Find the exam
            var exam = await _context.Exams
                .Include(e => e.Course)                // to access course info
                .FirstOrDefaultAsync(e => e.Examid == examId);

            if (exam == null)
                return NotFound("امتحان یافت نشد");

            // 3. Authorization check
            if (exam.Course == null || exam.Course.Teacherid != teacherIdd)
                return BadRequest("مجوز ویرایش این امتحان را ندارید");

            // 4. Handle file upload (your existing logic - slightly cleaned)
            string? fileName = exam.File; // keep old if no new file

            if (file != null && file.Length > 0)
            {
                // Delete old file if exists
                if (!string.IsNullOrEmpty(exam.File))
                {
                    var oldFilePath = Path.Combine(
                        Directory.GetCurrentDirectory(),
                        "wwwroot", "uploads", "exams",
                        exam.File);

                    if (System.IO.File.Exists(oldFilePath))
                    {
                        try
                        {
                            System.IO.File.Delete(oldFilePath);
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"[UPDATE EXAM] Failed to delete old file: {ex.Message}");
                        }
                    }
                }

                // Save new file
                var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "exams");
                Directory.CreateDirectory(uploadsFolder);

                fileName = $"{Guid.NewGuid()}_{file.FileName}";
                var filePath = Path.Combine(uploadsFolder, fileName);

                await using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }
            }

            // 5. Apply updates (only if provided)
            exam.Title         = model.Title ?? exam.Title;
            exam.Description   = model.Description ?? exam.Description;
            exam.Enddate       = model.Enddate ?? exam.Enddate;
            exam.Endtime       = model.Endtime ?? exam.Endtime;
            exam.PossibleScore = model.PossibleScore ?? exam.PossibleScore;
            exam.Duration      = model.Duration ?? exam.Duration;
            exam.Filename      = file?.FileName;   // original filename
            exam.File          = fileName;         // stored unique name (or null)

            // 6. Save changes first (so we have the updated exam data)
            await _context.SaveChangesAsync();

            // ──────────────────────────────────────────────
            // 7. Send notifications to students in the course/class
            // ──────────────────────────────────────────────

            var studentsInCourse = await _context.Students
                .Where(s => s.Classeid == exam.Classid)
                .ToListAsync();


            foreach (var student in studentsInCourse)
            {
                var notification = new Notification
                {
                    UserId      = student.UserID ?? 0,
                    Title       = "امتحان به‌روزرسانی شد",
                    Body        = $"امتحان {exam.Title} در درس {exam.Course?.Name ?? "نامشخص"} ویرایش شد. لطفاً جزئیات (تاریخ، زمان، نمره ممکن) را بررسی کنید.",
                    Type        = "exam_updated",
                    RelatedId   = exam.Examid,
                    RelatedType = "exam",
                    CreatedAt   = DateTime.UtcNow
                };

                _context.Notifications.Add(notification);
            }

            // 8. Final save (notifications + exam updates)
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException ex)
            {
                return StatusCode(500, new
                {
                    message = "خطا در ذخیره تغییرات یا ارسال اعلان‌ها",
                    detail = ex.InnerException?.Message ?? ex.Message
                });
            }

            return Ok(new
            {
                message = "امتحان با موفقیت به‌روزرسانی شد",
                filename = fileName,
                examId = exam.Examid
            });
        }

        // ──────────────────────────────────────────────────────────────
        // 20. Delete Exam
        // ──────────────────────────────────────────────────────────────
        [HttpDelete("exams/{ExamId}")]
        public async Task<IActionResult> DeleteExams(long ExamId, [FromQuery] long teacherId)
        {
            var exam = await _context.Exams.FindAsync(ExamId);
            if (exam == null) return NotFound("امتجان یافت نشد");

            var teacherIdd = await _context.Teachers
                            .Where(t => t.Userid == teacherId)
                            .Select(t => t.Teacherid)
                            .FirstOrDefaultAsync();

            var course = await _context.Courses.FindAsync(exam.Courseid);
            if (course == null || course.Teacherid != teacherIdd)
            {
                return BadRequest("مجوز حذف ندارید");
            }

            _context.Exams.Remove(exam);
            await _context.SaveChangesAsync();

            return Ok(new { message = "امتجان حذف شد" });
        }

        // Fix GetExam
        [HttpGet("{id}")]
        public async Task<IActionResult> GetExam(long id)
        {
            var exam = await _context.Exams.FindAsync(id);
            if (exam == null) return NotFound();
            return Ok(exam);
        }

        // ──────────────────────────────────────────────────────────────
        // 21. Download Exercise File
        // ──────────────────────────────────────────────────────────────
        [HttpGet("download/exercise/{exerciseId}")]
        public async Task<IActionResult> DownloadExerciseFile(long exerciseId)
        {
            try
            {
                var exercise = await _context.Exercises.FindAsync(exerciseId);
                if (exercise == null || string.IsNullOrEmpty(exercise.Filename))
                    return NotFound(new { message = "فایل یافت نشد" });

                var filePath = Path.Combine(
                    Directory.GetCurrentDirectory(),
                    "wwwroot", "uploads", "exercises",
                    exercise.Filename);

                if (!System.IO.File.Exists(filePath))
                    return NotFound(new { message = "فایل در سرور یافت نشد" });

                var fileBytes = await System.IO.File.ReadAllBytesAsync(filePath);
                var contentType = GetContentType(filePath);

                return File(fileBytes, contentType, exercise.Filename);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "خطای سرور", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // 20. Download Exam File
        // ──────────────────────────────────────────────────────────────
        [HttpGet("download/exam/{examId}")]
        public async Task<IActionResult> DownloadExamFile(long examId)
        {
            try
            {
                var exam = await _context.Exams.FindAsync(examId);
                if (exam == null || string.IsNullOrEmpty(exam.Filename))
                    return NotFound(new { message = "فایل یافت نشد" });

                var filePath = Path.Combine(
                    Directory.GetCurrentDirectory(),
                    "wwwroot", "uploads", "exams",
                    exam.Filename);

                if (!System.IO.File.Exists(filePath))
                    return NotFound(new { message = "فایل در سرور یافت نشد" });

                var fileBytes = await System.IO.File.ReadAllBytesAsync(filePath);
                var contentType = GetContentType(filePath);

                return File(fileBytes, contentType, exam.Filename);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "خطای سرور", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Get all students for an exam (including those without submission)
        // ──────────────────────────────────────────────────────────────
        [HttpGet("exams/{examId}/students")]
        public async Task<IActionResult> GetExamStudents(long examId)
        {
            var exam = await _context.Exams
                .Include(e => e.Class)
                .FirstOrDefaultAsync(e => e.Examid == examId);

            if (exam == null)
                return NotFound(new { message = "Exam not found" });

            // Get all students in the exam's class
            var allStudents = await _context.Students
                .Where(s => s.Classeid == exam.Classid)
                .Select(s => new { s.Studentid, s.Name, s.StuCode })
                .ToListAsync();

            // Get exam submissions
            var submissions = await _context.ExamStuTeaches
                .Where(est => est.Examid == examId)
                .ToListAsync();

            var result = allStudents.Select(student =>
            {
                var submission = submissions.FirstOrDefault(s => s.Studentid == student.Studentid);

                return new
                {
                    submissionId = submission?.Estid ?? 0,
                    studentId = student.Studentid,
                    stuCode = student.StuCode,
                    studentName = student.Name,
                    score = submission?.Score,
                    hasSubmitted = submission?.Date != null,
                    submittedAt = submission?.Date ?? "",
                    submittedTime = submission?.Time ?? "",
                    answerFile = submission?.Filename ?? "",
                    examId = examId,
                };
            }).OrderBy(s => s.studentName).ToList();

            return Ok(result);
        }

        // ──────────────────────────────────────────────────────────────
        // Get all students for an assignment (including those without submission)
        // ──────────────────────────────────────────────────────────────
        [HttpGet("exercises/{exerciseId}/students")]
        public async Task<IActionResult> GetExerciseStudents(long exerciseId)
        {
            var exercise = await _context.Exercises
                .Include(e => e.Course)
                .FirstOrDefaultAsync(e => e.Exerciseid == exerciseId);

            if (exercise == null)
                return NotFound(new { message = "Exercise not found" });

            // Get the class from the course
            var classId = exercise.Classid;
            if (classId == null && exercise.Courseid.HasValue)
            {
                var course = await _context.Courses.FindAsync(exercise.Courseid);
                classId = course?.Classid;
            }

            if (classId == null)
                return BadRequest(new { message = "Class information not available" });

            // Get all students in the exercise's class
            var allStudents = await _context.Students
                .Where(s => s.Classeid == classId)
                .Select(s => new { s.Studentid, s.Name, s.StuCode })
                .ToListAsync();

            // Get exercise submissions
            var submissions = await _context.ExerciseStuTeaches
                .Where(est => est.Exerciseid == exerciseId)
                .ToListAsync();

            var result = allStudents.Select(student =>
            {
                var submission = submissions
                    .FirstOrDefault(s => s.Studentid == student.Studentid);

                return new
                {
                    submissionId = submission?.Exstid ?? 0,
                    studentId = student.Studentid,
                    stuCode = student.StuCode,
                    studentName = student.Name,
                    score = submission?.Score,
                    hasSubmitted =  submission?.Date != null,
                    submittedAt = submission?.Date ?? "",
                    submittedTime = submission?.Time ?? "",
                    answerFile = submission?.Filename ?? "",
                    exerciseId = exerciseId,
                };
            }).OrderBy(s => s.studentName).ToList();

            return Ok(result);
        }

        // ──────────────────────────────────────────────────────────────
        // Update exam submission score
        // ──────────────────────────────────────────────────────────────
        [HttpPut("exams/submissions/{submissionId}/score")]
        public async Task<IActionResult> UpdateSubmissionScore(long submissionId, [FromBody] UpdateScoreRequest request)
        {
            if (request == null || request.Score < 0)
            {
                return BadRequest(new { message = "نمره نمی‌تواند منفی باشد یا درخواست نامعتبر است" });
            }

            // 1. Load the submission + related Exam (to get Courseid)
            var submission = await _context.ExamStuTeaches
                .Include(est => est.Exam)               // ← important: load the related Exam
                .FirstOrDefaultAsync(est => est.Estid == submissionId);

            if (submission == null)
            {
                return NotFound(new { message = "پاسخ امتحان یافت نشد" });
            }

            // 2. Update the score
            submission.Score = (int)request.Score;
            _context.ExamStuTeaches.Update(submission);

            // 3. Load student + user (for sending notification)
            var student = await _context.Students               // assuming Student has User navigation property
                .FirstOrDefaultAsync(s => s.Studentid == submission.Studentid);

            // 4. Load course name (from Exam → Course)
            string? courseName = null;
            if (submission.Exam?.Courseid.HasValue == true)
            {
                courseName = await _context.Courses
                    .Where(c => c.Courseid == submission.Exam.Courseid)
                    .Select(c => c.Name)
                    .FirstOrDefaultAsync();
            }

            // 5. Create notification for the student (if they have a linked user account)
            if (student?.UserID > 0)
            {
                var notification = new Notification
                {
                    UserId      = student.UserID ?? 0,
                    Title       = "نمره امتحان شما ثبت شد",
                    Body        = $"درس {courseName ?? "نامشخص"} – نمره: {request.Score}",
                    Type        = "grade",
                    RelatedId   = submission.Examid,           // link to the exam
                    RelatedType = "exam",
                    CreatedAt   = DateTime.UtcNow
                };

                _context.Notifications.Add(notification);
            }

            // 6. Save all changes in one transaction
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException ex)
            {
                // In real app: log the exception
                return StatusCode(500, new
                {
                    message = "خطا در ذخیره تغییرات",
                    detail = ex.InnerException?.Message ?? ex.Message
                });
            }

            // 7. Return success response
            return Ok(new
            {
                message = "نمره با موفقیت ثبت شد",
                submission = new
                {
                    submissionId = submission.Estid,
                    studentId    = submission.Studentid,
                    score        = submission.Score
                }
            });
        }

        // ──────────────────────────────────────────────────────────────
        // Update submission score (creates record if it doesn't exist)
        // ──────────────────────────────────────────────────────────────
        [HttpPut("exercises/submissions/{submissionId}/score")]
        public async Task<IActionResult> UpdateSubmissionScoreEx(long submissionId, [FromBody] UpdateScoreRequest request)
        {
            if (request == null || request.Score < 0)
            {
                return BadRequest(new { message = "Score cannot be negative or request is invalid" });
            }

            // 1. Find the submission
            var submission = await _context.ExerciseStuTeaches
                .Include(est => est.Exercise)
                .FirstOrDefaultAsync(est => est.Exstid == submissionId);

            if (submission == null)
            {
                return NotFound(new { message = "Submission not found" });
            }

            // 2. Update score
            submission.Score = (int)request.Score;
            _context.ExerciseStuTeaches.Update(submission);

            // 3. Try to load student + user + course for notification
            var student = await _context.Students                        // assuming Student has User navigation property
                .FirstOrDefaultAsync(s => s.Studentid == submission.Studentid);

            Course? course = null;
            if (submission.Exercise?.Courseid.HasValue == true)
            {
                course = await _context.Courses
                    .FirstOrDefaultAsync(c => c.Courseid == submission.Exercise.Courseid);
            }

            // 4. Create notification only if student has a linked user account
            if (student?.UserID > 0)
            {
                var notification = new Notification
                {
                    UserId      = student?.UserID ?? 0,
                    Title       = "نمره تکلیف ثبت شد",
                    Body        = $"درس {course?.Name ?? "نامشخص"} – نمره: {request.Score}",
                    Type        = "grade",
                    RelatedId   = submission.Exerciseid,           // links to the exercise
                    RelatedType = "exercise",
                    CreatedAt   = DateTime.UtcNow
                };

                _context.Notifications.Add(notification);
            }

            // 5. Save everything in one transaction
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException ex)
            {
                // Log exception in real app
                return StatusCode(500, new { message = "خطا در ذخیره تغییرات", detail = ex.Message });
            }

            // 6. Return success response
            return Ok(new
            {
                message = "نمره با موفقیت به‌روزرسانی شد",
                submission = new
                {
                    submissionId = submission.Exstid,
                    studentId    = submission.Studentid,
                    score        = submission.Score
                }
            });
        }

        // ──────────────────────────────────────────────────────────────
        // Create empty submission for student without submission + score
        // ──────────────────────────────────────────────────────────────
        [HttpPost("exams/{examId}/students/{studentId}/score")]
        public async Task<IActionResult> CreateExamScoreForStudent(long examId, long studentId, [FromBody] UpdateScoreRequest request)
        {
            if (request.Score < 0)
                return BadRequest(new { message = "Score cannot be negative" });

            var exam = await _context.Exams.FindAsync(examId);
            if (exam == null)
                return NotFound(new { message = "Exam not found" });

            var student = await _context.Students.FindAsync(studentId);
            if (student == null)
                return NotFound(new { message = "Student not found" });

            var course = await _context.Courses.FindAsync(exam.Courseid);
            if (course == null)
                return BadRequest(new { message = "Course not found" });

            // Check if submission already exists
            var existingSubmission = await _context.ExamStuTeaches
                .FirstOrDefaultAsync(est => est.Examid == examId && est.Studentid == studentId);

            if (existingSubmission != null)
            {
                existingSubmission.Score = (int)request.Score;
                _context.ExamStuTeaches.Update(existingSubmission);
            }
            else
            {
                // Create new submission with score (no answer)
                var newSubmission = new ExamStuTeach
                {
                    Examid = examId,
                    Studentid = studentId,
                    Courseid = exam.Courseid ?? 0,
                    Teacherid = course.Teacherid ?? 0,
                    Score = (int)request.Score,
                    Answerimage = null,
                    Description = "نمره توسط استاد و بدون پاسخ داده شده!"
                };
                _context.ExamStuTeaches.Add(newSubmission);
            }

            await _context.SaveChangesAsync();

            var studentt = await _context.Students
                .FirstOrDefaultAsync(s => s.Studentid == studentId);

            if (studentt?.UserID == null) return Ok(); // no user → skip notification

            var notification = new Notification
            {
                UserId     = studentt.UserID.Value,
                Title      = "نمره جدید ثبت شد",
                Body       = $"درس {course?.Name ?? "نامشخص"} – نمره: {(int)request.Score}",
                Type       = "grade",
                RelatedId  = examId,           // optional
                RelatedType = "exam"
            };

            _context.Notifications.Add(notification);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Score saved successfully" });
        }

        // Similar for exercises/assignments
        [HttpPost("exercises/{exerciseId}/students/{studentId}/score")]
        public async Task<IActionResult> CreateExerciseScoreForStudent(long exerciseId, long studentId, [FromBody] UpdateScoreRequest request)
        {
            if (request.Score < 0)
                return BadRequest(new { message = "Score cannot be negative" });

            var exercise = await _context.Exercises.FindAsync(exerciseId);
            if (exercise == null)
                return NotFound(new { message = "Exercise not found" });

            var student = await _context.Students.FindAsync(studentId);
            if (student == null)
                return NotFound(new { message = "Student not found" });

            // Check if submission already exists
            var existingSubmission = await _context.ExerciseStuTeaches
                .FirstOrDefaultAsync(est => est.Exerciseid == exerciseId && est.Studentid == studentId);

            if (existingSubmission != null)
            {
                existingSubmission.Score = (int)request.Score;
                _context.ExerciseStuTeaches.Update(existingSubmission);
            }
            else
            {
                // Create new submission with score (no answer)
                var newSubmission = new ExerciseStuTeach
                {
                    Exerciseid = exerciseId,
                    Studentid = studentId,
                    Courseid = exercise.Courseid ?? 0,
                    Teacherid = 0,
                    Score = (int)request.Score,
                    Answerimage = null,
                    Description = "نمره توسط استاد و بدون پاسخ داده شده!"
                };
                _context.ExerciseStuTeaches.Add(newSubmission);
            }

            await _context.SaveChangesAsync();

            var studentt = await _context.Students
                .FirstOrDefaultAsync(s => s.Studentid == studentId);

            if (studentt?.UserID == null) return Ok(); // no user → skip notification

            var course = await _context.Courses.FindAsync(exercise.Courseid);

            var notification = new Notification
            {
                UserId     = studentt.UserID.Value,
                Title      = "نمره جدید ثبت شد",
                Body       = $"درس {course?.Name ?? "نامشخص"} – نمره: {(int)request.Score}",
                Type       = "grade",
                RelatedId  = exerciseId,           // optional
                RelatedType = "exercise"
            };

            _context.Notifications.Add(notification);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Score saved successfully" });
        }

        [HttpGet("course/{courseId}/students-scores")]
        public async Task<IActionResult> GetCourseStudentsScores(long courseId)
        {
            try
            {


                // 2. Find course - safe
                var course = await _context.Courses
                    .AsNoTracking()
                    .FirstOrDefaultAsync(c => c.Courseid == courseId);

                if (course == null)
                {
                    return StatusCode(403, new { message = "شما این درس را تدریس نمی‌کنید یا درس یافت نشد" });
                }

                // 3. Get classId - safe
                if (course.Classid == null)
                {
                    return BadRequest(new { message = "این درس به هیچ کلاسی وابسته نیست" });
                }

                var classId = course.Classid.Value;

                // 4. Load students with safe projection
                var students = await _context.Students
                    .AsNoTracking()
                    .Where(s => s.Classeid == classId)
                    .Select(s => new
                    {
                        studentId = s.Studentid,
                        name = s.Name ?? "نامشخص",
                        studentCode = s.StuCode ?? "نامشخص",
                        currentScore = _context.Scores
                            .Where(sc => sc.Studentid == s.Studentid && sc.Courseid == courseId)
                            .OrderByDescending(sc => sc.Score_month ?? "")
                            .Select(sc => new
                            {
                                scoreValue = sc.ScoreValue,
                                score_month = sc.Score_month ?? "نامشخص"
                            })
                            .FirstOrDefault()
                    })
                    .ToListAsync();

                return Ok(new
                {
                    courseId,
                    courseName = course.Name ?? "درس بدون نام",
                    studentsCount = students.Count,
                    students
                });
            }
            catch (Exception ex)
            {
                // Log the error (in production use logger)
                Console.WriteLine($"Error in GetCourseStudentsScores: {ex.Message}\n{ex.StackTrace}");
                return StatusCode(500, new { message = "خطای سرور در بارگذاری دانشجویان", detail = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // NEW: Batch update course scores
        // POST: api/teacher/course/{courseId}/scores
        [HttpPost("course/{courseId}/scores")]
        public async Task<IActionResult> UpdateCourseScores(long courseId, [FromBody] List<CourseScoreUpdateDto> updates)
        {
            var teacherId = long.Parse(User.FindFirst("userid")?.Value ?? "0");

            var course = await _context.Courses
                .FirstOrDefaultAsync(c => c.Courseid == courseId && c.Teacherid == teacherId);

            foreach (var update in updates)
            {
                if (update.ScoreValue < 0 || update.ScoreValue > 20) // assuming 0–20 scale – adjust if needed
                    return BadRequest($"Invalid score for student {update.StudentId}");

                var existing = await _context.Scores
                    .FirstOrDefaultAsync(s =>
                        s.Studentid == update.StudentId &&
                        s.Courseid == courseId &&
                        s.Score_month == update.ScoreMonth);

                if (existing != null)
                {
                    existing.ScoreValue = update.ScoreValue;
//                    existing.UpdatedAt = DateTime.UtcNow; // if you have this field
                }
                else
                {
                    _context.Scores.Add(new Score
                    {
                        Studentid   = update.StudentId,
                        Courseid    = courseId,
                        Classid     = course.Classid,
                        ScoreValue  = update.ScoreValue,
                        Score_month = update.ScoreMonth,   // e.g. "1404-11"
                        // StuCode     = ... (optional – can remove if using Studentid)
                    });
                }
            }

            await _context.SaveChangesAsync();
            return NoContent();
        }

////////////////////////////////////////////////////////////////////////////
        private string GetContentType(string path)
        {
            var ext = System.IO.Path.GetExtension(path).ToLowerInvariant();
            return ext switch
            {
                ".pdf" => "application/pdf",
                ".jpg" => "image/jpeg",
                ".jpeg" => "image/jpeg",
                ".png" => "image/png",
                ".gif" => "image/gif",
                ".bmp" => "image/bmp",
                ".doc" => "application/msword",
                ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                ".xls" => "application/vnd.ms-excel",
                ".xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                ".ppt" => "application/vnd.ms-powerpoint",
                ".pptx" => "application/vnd.openxmlformats-officedocument.presentationml.presentation",
                ".txt" => "text/plain",
                ".zip" => "application/zip",
                ".rar" => "application/x-rar-compressed",
                _ => "application/octet-stream"  // Generic fallback for unknown types
            };
        }
        ///////////////////
        private DateTime JalaliToGregorian(int jy, int jm, int jd)
        {
            int dayOfYear = 0;

            if (jm <= 6)
                dayOfYear = (jm - 1) * 31 + jd;
            else if (jm <= 11)
                dayOfYear = 6 * 31 + (jm - 7) * 30 + jd;
            else
                dayOfYear = 6 * 31 + 5 * 30 + jd;

            int totalDays = (jy - 1) * 365;
            totalDays += (jy - 1) / 33 * 8;
            totalDays += ((jy - 1) % 33) / 4;
            totalDays += dayOfYear;

            DateTime jalaliEpoch = new DateTime(622, 3, 22);
            DateTime gregorianDate = jalaliEpoch.AddDays(totalDays - 1);

            return gregorianDate;
        }

        public class UpdateScoreRequest
        {
            public decimal Score { get; set; }
        }

        public class BatchScoreUpdate
        {
            public long SubmissionId { get; set; }
            public decimal Score { get; set; }
        }

        public class CourseScoreUpdateDto
        {
            public long StudentId { get; set; }
            public long ScoreValue { get; set; }
            public string ScoreMonth { get; set; } = null!;   // e.g. "1404-11"
        }
    }

}