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
                    description = e.Description,
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

            var teacherIdd = await _context.Teachers
                   .Where(t => t.Userid == model.Teacherid)
                   .Select(t => t.Teacherid)
                   .FirstOrDefaultAsync();

            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var exercise = await _context.Exercises.FindAsync(exerciseId);
            if (exercise == null) return NotFound("تمرین یافت نشد");

            var course = await _context.Courses.FindAsync(exercise.Courseid);
            if (course == null || course.Teacherid != teacherIdd)
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
                .Select(e => new
                {
                    id = e.Examid,
                    title = e.Title,
                    description = e.Description,
                    endDateStr = e.Enddate,
                    startTimeStr = e.Starttime,
                    duration = e.Duration ?? 90,
                    subject = e.Course != null ? e.Course.Name : "نامشخص",
                    date = e.Startdate,
                    classId = e.Classid,
                    possibleScore = e.PossibleScore ?? 100,
                    location = e.Class != null ? e.Class.Name : "نامشخص",
                    classTime = e.Starttime,
                    // Count students with submissions
                    submittedCount = _context.ExamStuTeaches.Count(est => est.Examid == e.Examid && est.Score != null),
                    // Count students who scored more than half
                    passCount = _context.ExamStuTeaches.Count(est => est.Examid == e.Examid && est.Score >= (e.PossibleScore ?? 100) * 0.5),
                    // Total count of submissions (not class size)
                    totalSubmitted = _context.ExamStuTeaches.Count(est => est.Examid == e.Examid)
                })
                .ToListAsync();

            var nowUtc = DateTime.UtcNow;

            var exams = examData.Select(ed => {
                var isFuture = false;

                if (!string.IsNullOrEmpty(ed.endDateStr))
                {
                    var dateParts = ed.endDateStr.Split('-');
                    if (dateParts.Length == 3 &&
                        int.TryParse(dateParts[0], out int jyear) &&
                        int.TryParse(dateParts[1], out int jmonth) &&
                        int.TryParse(dateParts[2], out int jday))
                    {
                        int startHour = 0, startMinute = 0;
                        if (!string.IsNullOrEmpty(ed.startTimeStr))
                        {
                            var timeParts = ed.startTimeStr.Split(':');
                            if (timeParts.Length >= 2)
                            {
                                int.TryParse(timeParts[0], out startHour);
                                int.TryParse(timeParts[1], out startMinute);
                            }
                        }

                        DateTime examStartDateTime = JalaliToGregorian(jyear, jmonth, jday);
                        examStartDateTime = examStartDateTime.AddHours(startHour).AddMinutes(startMinute);
                        DateTime examEndDateTime = examStartDateTime.AddMinutes(ed.duration);

                        isFuture = nowUtc < examEndDateTime;
                    }
                }

                // Calculate pass percentage: (students who scored > half) / (total submitted) * 100
                double passPercentage = ed.totalSubmitted > 0
                    ? Math.Round(ed.passCount * 100.0 / ed.totalSubmitted, 1)
                    : 0;

                return new
                {
                    id = ed.id,
                    title = ed.title,
                    description = ed.description,
                    status = isFuture ? "upcoming" : "completed",
                    subject = ed.subject,
                    date = ed.date,
                    classTime = ed.classTime,
                    capacity = ed.totalSubmitted,  // Number of students who submitted answers
                    duration = ed.duration,
                    possibleScore = ed.possibleScore,
                    location = ed.location,
                    passPercentage = passPercentage,
                    filledCapacity = ed.submittedCount + "/" + ed.totalSubmitted
                };
            }).ToList();

            return Ok(exams);
        }

        [HttpGet("exams/{examId}/submissions")]
        public async Task<IActionResult> GetExamSubmissions(long examId)
        {
            var submissions = await _context.ExamStuTeaches
                .Include(est => est.Stu)
                .Where(est => est.Examid == examId)
                .Select(est => new
                {
                    id = est.Estid,
                    examId = est.Examid,
                    studentId = est.Stuid,
                    studentName = est.Stu.Name ?? "نامشخص",
                    submittedAt = est.Submitteddate,
                    score = est.Score,
                    answerFile = est.Answerfile
                })
                .OrderByDescending(x => x.submittedAt)
                .ToListAsync();

            return Ok(submissions);
        }

        [HttpPost("exams/{examId}/submissions/{submissionId}/score")]
        public async Task<IActionResult> UpdateSubmissionScore(long examId, long submissionId, [FromBody] UpdateScoreRequest request)
        {
            try
            {
                var submission = await _context.ExamStuTeaches
                    .FirstOrDefaultAsync(est => est.Estid == submissionId && est.Examid == examId);

                if (submission == null)
                    return NotFound(new { message = "Submission not found" });

                if (request.Score < 0)
                    return BadRequest(new { message = "Score cannot be negative" });

                submission.Score = request.Score;
                submission.Gradeddate = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                return Ok(new
                {
                    message = "Score updated successfully",
                    submission = new
                    {
                        id = submission.Estid,
                        score = submission.Score,
                        gradedAt = submission.Gradeddate
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error updating score: " + ex.Message });
            }
        }

        public class UpdateScoreRequest
        {
            public double Score { get; set; }
        }

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

        // ──────────────────────────────────────────────────────────────
        // 14. Create Exams
        // ──────────────────────────────────────────────────────────────
        [HttpPost]
        public async Task<IActionResult> CreateExam([FromBody] Exam newExam)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            _context.Exams.Add(newExam);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetExam), new { id = newExam.Examid }, newExam);
        }

        // Fix GetExam
        [HttpGet("{id}")]
        public async Task<IActionResult> GetExam(long id)
        {
            var exam = await _context.Exams.FindAsync(id);
            if (exam == null) return NotFound();
            return Ok(exam);
        }

//        // Convert Gregorian to Jalali (Persian) calendar
//        private (int Year, int Month, int Day) ConvertGregorianToJalali(DateTime gregorianDate)
//        {
//            int gy = gregorianDate.Year;
//            int gm = gregorianDate.Month;
//            int gd = gregorianDate.Day;
//
//            int[] g_d_n_array = new[] { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 };
//
//            int g_d_n = 365 * gy + ((gy + 3) / 4) - ((gy + 99) / 100) + ((gy + 399) / 400) + gd + g_d_n_array[gm - 1];
//
//            int j_d_n = g_d_n - 79;
//
//            int j_np = j_d_n / 12053;
//            j_d_n = j_d_n % 12053;
//
//            int jy = 979 + 33 * j_np + 4 * (j_d_n / 1461);
//
//            j_d_n %= 1461;
//
//            if (j_d_n >= 366)
//            {
//                jy += (j_d_n - 1) / 365;
//                j_d_n = (j_d_n - 1) % 365;
//            }
//
//            int jm = j_d_n < 186 ? 1 + (j_d_n / 31) : 7 + ((j_d_n - 186) / 30);
//            int jd = 1 + (j_d_n < 186 ? (j_d_n % 31) : ((j_d_n - 186) % 30));
//
//            return (jy, jm, jd);
//        }
//
//        // Convert Jalali to Gregorian calendar
//        private DateTime ConvertJalaliToGregorian(int jy, int jm, int jd)
//        {
//            jy += 1474;
//            if (jm > 7)
//                jy += 1;
//
//            int days = 365 * jy + ((jy / 33) * 8) + ((jy % 33 + 3) / 4) + 78 + jd;
//
//            if (jm < 7)
//                days += (jm - 1) * 31;
//            else
//                days += (jm - 7) * 30 + 186;
//
//            DateTime gregorianDate = new DateTime(400, 1, 1).AddDays(days);
//            return gregorianDate;
//        }
    }
}