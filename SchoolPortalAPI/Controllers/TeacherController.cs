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
                .ToListAsync();

            var nowUtc = DateTime.UtcNow;
            var result = new List<object>();

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

                // Check if exam is future or completed
                bool isFuture = false;
                if (!string.IsNullOrEmpty(e.Enddate) && !string.IsNullOrEmpty(e.Starttime))
                {
                    string[] dateParts = e.Enddate.Split('-');
                    if (dateParts.Length == 3 &&
                        int.TryParse(dateParts[0], out int jyear) &&
                        int.TryParse(dateParts[1], out int jmonth) &&
                        int.TryParse(dateParts[2], out int jday))
                    {
                        string[] timeParts = e.Starttime.Split(':');
                        int startHour = 0, startMinute = 0;
                        if (timeParts.Length >= 2)
                        {
                            int.TryParse(timeParts[0], out startHour);
                            int.TryParse(timeParts[1], out startMinute);
                        }

                        DateTime examStartDateTime = JalaliToGregorian(jyear, jmonth, jday);
                        examStartDateTime = examStartDateTime.AddHours(startHour).AddMinutes(startMinute);
                        DateTime examEndDateTime = examStartDateTime.AddMinutes(e.Duration ?? 90);

                        isFuture = nowUtc < examEndDateTime;
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
                    status = isFuture ? "upcoming" : "completed",
                    subject = e.Course != null ? e.Course.Name : "نامشخص",
                    date = e.Startdate,
                    classId = e.Classid,
                    capacity = capacity,
                    submitted = submitted,
                    graded = gradedCount,
                    possibleScore = e.PossibleScore,
                    location = e.Class?.Name ?? "نامشخص",
                    passPercentage = passPercentage,
                    filledCapacity = $"{submitted}/{capacity}"
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
                    answerFile = est.Filename ?? ""
                })
                .ToListAsync();

            return Ok(submissions);
        }

        // ──────────────────────────────────────────────────────────────
        // 14. Update Exams Score
        // ──────────────────────────────────────────────────────────────
        [HttpPut("exams/submissions/{submissionId}/score")]
        public async Task<IActionResult> UpdateSubmissionScore(long submissionId, [FromBody] UpdateScoreRequest request)
        {
            if (request.Score < 0)
                return BadRequest("Score cannot be negative");

            var submission = await _context.ExamStuTeaches.FirstOrDefaultAsync(est => est.Estid == submissionId);

            if (submission == null)
                return NotFound("Submission not found");

            submission.Score = (int)request.Score;

            _context.ExamStuTeaches.Update(submission);
            await _context.SaveChangesAsync();

            return Ok(new {
                message = "Score updated successfully",
                submission = new
                {
                    submissionId = submission.Estid,
                    studentId = submission.Studentid,
                    score = submission.Score
                }
            });
        }

        // ──────────────────────────────────────────────────────────────
        // 14. Update Exams Score(group)
        // ──────────────────────────────────────────────────────────────
        [HttpPost("exams/{examId}/scores/batch")]
        public async Task<IActionResult> BatchUpdateScores(long examId, [FromBody] List<BatchScoreUpdate> scores)
        {
            var exam = await _context.Exams.FirstOrDefaultAsync(e => e.Examid == examId);
            if (exam == null)
                return NotFound("Exam not found");

            foreach (var scoreUpdate in scores)
            {
                if (scoreUpdate.Score < 0 || scoreUpdate.Score > exam.PossibleScore)
                    return BadRequest($"Score must be between 0 and {exam.PossibleScore}");

                var submission = await _context.ExamStuTeaches
                    .FirstOrDefaultAsync(est => est.Estid == scoreUpdate.SubmissionId);

                if (submission != null)
                {
                    submission.Score = (int)scoreUpdate.Score;
                    _context.ExamStuTeaches.Update(submission);
                }
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "Scores updated successfully" });
        }

        // ──────────────────────────────────────────────────────────────
        // 14. Get Exams Statistic
        // ──────────────────────────────────────────────────────────────
        [HttpGet("exams/{examId}/stats")]
        public async Task<IActionResult> GetExamStats(long examId)
        {
            var exam = await _context.Exams
                .Include(e => e.Course)
                .FirstOrDefaultAsync(e => e.Examid == examId);

            if (exam == null)
                return NotFound("Exam not found");

            var submissions = await _context.ExamStuTeaches
                .Where(est => est.Examid == examId)
                .ToListAsync();

            var gradedSubmissions = submissions.Where(s => s.Score.HasValue).ToList();

            double avgScore = gradedSubmissions.Count > 0
                ? gradedSubmissions.Average(s => (double)s.Score.Value)
                : 0;

            double passPercentage = submissions.Count > 0
                ? (gradedSubmissions.Count(s => s.Score >= (exam.PossibleScore * 0.5)) * 100.0 / submissions.Count)
                : 0;

            return Ok(new
            {
                examId = exam.Examid,
                title = exam.Title,
                subject = exam.Course?.Name ?? "نامشخص",
                possibleScore = exam.PossibleScore,
                totalSubmissions = submissions.Count,
                gradedSubmissions = gradedSubmissions.Count,
                pendingSubmissions = submissions.Count - gradedSubmissions.Count,
                averageScore = Math.Round(avgScore, 2),
                passPercentage = Math.Round(passPercentage, 1),
                maxScore = gradedSubmissions.Count > 0 ? gradedSubmissions.Max(s => s.Score) : null,
                minScore = gradedSubmissions.Count > 0 ? gradedSubmissions.Min(s => s.Score) : null
            });
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

        // ──────────────────────────────────────────────────────────────
        // 11. Delete Exam
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
//////////////////////////
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
    }
}