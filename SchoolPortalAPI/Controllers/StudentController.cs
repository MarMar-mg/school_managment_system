using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SchoolPortalAPI.Data;      // <-- Make sure this is correct
using SchoolPortalAPI.Models;    // Exam, ExamStuTeach, Course, Class
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

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

        // ──────────────────────────────────────────────────────────────
        // Get basic student dashboard data (ID, Name, Class, Score, Debt)
        // ──────────────────────────────────────────────────────────────
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

        // ──────────────────────────────────────────────────────────────
        // Get full student profile
        // ──────────────────────────────────────────────────────────────
        [HttpGet("profile/{studentId}")]
        public async Task<IActionResult> GetProfile(long studentId)
        {
            var student = await _context.Students.FindAsync(studentId);
            if (student == null) return NotFound();
            return Ok(student);
        }

        // ──────────────────────────────────────────────────────────────
        // Get average score per course for this student
        // ──────────────────────────────────────────────────────────────
        [HttpGet("progress/{userId}")]
        public async Task<IActionResult> GetProgress(long userId)
        {
            var studentId = await _context.Students
                .Where(s => s.UserID == userId)
                .Select(s => s.Studentid)
                .FirstOrDefaultAsync();

            if (studentId == 0) return NotFound("دانش‌آموز یافت نشد");

            var progress = await _context.Scores
                .Where(s => s.Course != null && s.Studentid == studentId)
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
        // Get exercises for student's class with optional date filtering
        // ──────────────────────────────────────────────────────────────
        [HttpGet("assignment/{studentId}")]
        public async Task<IActionResult> GetExercises1(
            long studentId,
            [FromQuery] string? start,
            [FromQuery] string? end)
        {
            var student = await _context.Students
                .Where(s => s.Studentid == studentId)
                .Select(s => new { s.Classeid })
                .FirstOrDefaultAsync();

            if (student == null) return NotFound("دانش‌آموز یافت نشد");

            var query = _context.Exercises
                .Where(e => e.Classid == student.Classeid);

            if (!string.IsNullOrEmpty(start))
                query = query.Where(e => string.Compare(e.Enddate, start) >= 0);
            if (!string.IsNullOrEmpty(end))
                query = query.Where(e => string.Compare(e.Enddate, end) <= 0);

            var result = await query
                .Include(e => e.Course)
                .Select(e => new
                {
                    title = e.Title,
                    courseName = e.Course != null ? e.Course.Name : "نامشخص",
                    dueDate = e.Enddate,
                    startTime = e.Starttime,
                    endTime = e.Endtime
                })
                .ToListAsync();

            return Ok(result);
        }


        // ──────────────────────────────────────────────────────────────
        // Get exercises for student's class
        // ──────────────────────────────────────────────────────────────
       [HttpGet("exercises/{studentId}")]
       public async Task<IActionResult> GetExercises(long studentId)
       {
           var student = await _context.Students
               .FirstOrDefaultAsync(s => s.UserID == studentId);

           if (student == null)
               return NotFound("دانش‌آموز یافت نشد");

           var todayShamsi = DateTime.Now.ToShamsi().Replace("-", ""); // 14031118

           // همه تمرین‌های کلاس دانش‌آموز
           var exercises = await _context.Exercises
               .Where(e => e.Classid == student.Classeid)
               .Select(e => new
               {
                   e.Exerciseid,
                   e.Title,
                   e.Description,
                   e.Enddate,
                   e.Endtime,
                   e.Score,
                   e.Courseid
               })
               .ToListAsync();

           var pending = new List<object>();      // در انتظار پاسخ
           var submittedNoGrade = new List<object>(); // مهلت تمام + ارسال شده + بدون نمره
           var graded = new List<object>();       // نمره داده شده

           var studentidd = await _context.Students
                           .Where(e => e.UserID == studentId)
                           .Select(e => e.Studentid)
                           .FirstOrDefaultAsync();

           foreach (var e in exercises)
           {
               string? dueDateStr = e.Enddate?.Trim();
               bool isPastDue = false;
               bool isUrgent = false;

               if (!string.IsNullOrEmpty(dueDateStr) && dueDateStr.Length == 10)
               {
                   try
                   {
                       string todayStr = DateTime.Today.ToString("yyyy-MM-dd",
                           new System.Globalization.CultureInfo("fa-IR"));

                       // مقایسه مستقیم رشته‌ای (چون فرمت یکسانه)
                       isPastDue = string.Compare(dueDateStr, todayStr) < 0;

                       // فردا = امروز + 1 روز
                       string tomorrowStr = DateTime.Today.AddDays(1).ToString("yyyy-MM-dd",
                           new System.Globalization.CultureInfo("fa-IR"));

                       bool isTodayOrTomorrow = dueDateStr == todayStr || dueDateStr == tomorrowStr;

                       isUrgent = !isPastDue && isTodayOrTomorrow;
                   }
                   catch
                   {
                       isPastDue = false;
                       isUrgent = false;
                   }
               }

               // پاسخ دانش‌آموز
               var answer = await _context.ExerciseStuTeaches
                   .FirstOrDefaultAsync(est => est.Exerciseid == e.Exerciseid && est.Studentid == studentidd);

               bool hasSubmitted = answer != null;
               bool hasGrade = answer?.Score != null;

               // نام درس
               string courseName = "نامشخص";
               if (e.Courseid.HasValue)
               {
                   courseName = await _context.Courses
                       .Where(c => c.Courseid == e.Courseid.Value)
                       .Select(c => c.Name)
                       .FirstOrDefaultAsync() ?? "نامشخص";
               }

               var item = new
               {
                   id = e.Exerciseid,
                   title = e.Title ?? "بدون عنوان",
                   courseName,
                   description = e.Description ?? "",
                   endTime = e.Endtime ?? "نامشخص",
                   dueDate = dueDateStr ?? "نامشخص",
                   totalScore = e.Score?.ToString() ?? "نامشخص",
                   isUrgent,
                   status = hasGrade ? "graded" : (hasSubmitted ? "submitted" : (!isPastDue ? "pending" : "notSubmitted")),
                   finalScore = hasGrade ? $"{answer.Score}/{e.Score}" : null,
                   answerImage = answer?.Answerimage,
                   filename = answer?.Filename
               };

               // دسته‌بندی هوشمند
               if (hasGrade)
               {
                   graded.Add(item);
               }
               else if (hasSubmitted)
               {
                   submittedNoGrade.Add(item);
               }
               else if (!isPastDue)
               {
                   pending.Add(item);
               }
               else
               {
                   // مهلت تمام شده + نفرستاده → به submittedNoGrade اضافه شود
                   submittedNoGrade.Add(item);
               }
           }

           return Ok(new
           {
               pending = pending,         // در انتظار پاسخ (هنوز وقت داره)
               submittedNoGrade = submittedNoGrade, // مهلت تمام (ارسال شده بدون نمره یا ارسال نشده)
               graded = graded           // نمره داده شده
           });
       }


        // ──────────────────────────────────────────────────────────────
        // Get all exams for a student
        // ──────────────────────────────────────────────────────────────
        [HttpGet("exam/{studentId}")]
        public async Task<ActionResult<IEnumerable<object>>> GetAllExams(long studentId)
        {
            try
            {
                // Get the student and their classId
                var student = await _context.Students
                    .Where(s => s.UserID == studentId)
                    .Select(s => new { s.Studentid, s.Classeid })
                    .FirstOrDefaultAsync();

                if (student == null)
                    return NotFound(new { message = "دانش‌آموز یافت نشد" });

                // Get all exams for the student's class
                var exams = await _context.Exams
                    .Where(e => e.Classid == student.Classeid)
                    .Include(e => e.Course)
                    .Include(e => e.Class)
                    .Select(e => new
                    {
                        id = e.Examid,
                        title = e.Title ?? "بدون عنوان",
                        courseName = e.Course!.Name ?? "نامشخص",
                        className = e.Class!.Name ?? "نامشخص",
                        description = e.Description ?? "",
                        examDate = e.Enddate,
                        startDate = e.Startdate,
                        startTime = e.Starttime,
                        endTime = e.Endtime,
                        possibleScore = e.PossibleScore,
                        duration = e.Duration,

                        // Get student's submission data from ExamStuTeach
                        score = _context.ExamStuTeaches
                            .Where(est => est.Examid == e.Examid && est.Studentid == studentId)
                            .Select(est => (int?)est.Score)
                            .FirstOrDefault(),

                        answerImage = _context.ExamStuTeaches
                            .Where(est => est.Examid == e.Examid && est.Studentid == studentId)
                            .Select(est => est.Answerimage)
                            .FirstOrDefault(),

                        filename = _context.ExamStuTeaches
                            .Where(est => est.Examid == e.Examid && est.Studentid == studentId)
                            .Select(est => est.Filename)
                            .FirstOrDefault(),

                        submittedDate = _context.ExamStuTeaches
                            .Where(est => est.Examid == e.Examid && est.Studentid == studentId)
                            .Select(est => est.Date)
                            .FirstOrDefault(),

                        submittedTime = _context.ExamStuTeaches
                            .Where(est => est.Examid == e.Examid && est.Studentid == studentId)
                            .Select(est => est.Time)
                            .FirstOrDefault(),

                        estid = _context.ExamStuTeaches
                            .Where(est => est.Examid == e.Examid && est.Studentid == studentId)
                            .Select(est => (long?)est.Estid)
                            .FirstOrDefault()
                    })
                    .OrderBy(e => e.examDate)
                    .ToListAsync();

                return Ok(exams);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "خطا در بارگذاری امتحانات", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Get scores for student's courses
        // ──────────────────────────────────────────────────────────────
        [HttpGet("my-score/{studentId}")]
        public async Task<ActionResult<object>> GetMyScore(long studentId)
        {
            try
            {
                var studentIdd = await _context.Students
                                            .Where(s => s.UserID == studentId)
                                            .Select(s => s.Studentid)
                                            .FirstOrDefaultAsync();

                var student = await _context.Students
                    .FirstOrDefaultAsync(s => s.UserID == studentId);

                if (student == null)
                    return NotFound(new { message = "دانش‌آموز یافت نشد" });

                // === 1. GPA (معدل کل) ===
                var gpaQuery = await _context.Scores
                    .Where(s => s.Studentid == studentIdd && s.Classid == student.Classeid)
                    .AverageAsync(s => (double?)s.ScoreValue);

                var gpa = gpaQuery ?? 0.0;

                var courses = await _context.Courses
                                .Where(c => c.Classid == student.Classeid)
                                .Select(s => s.Courseid)
                                                        .Distinct()
                                                        .ToListAsync();

                // === 2. Collect all unique course IDs from Scores, Exercises, Exams ===
                var courseIdsFromScores = await _context.Scores
                    .Where(s => s.Studentid == studentIdd && s.Classid == student.Classeid && s.Courseid.HasValue)
                    .Select(s => s.Courseid.Value)
                    .Distinct()
                    .ToListAsync();

                var courseIdsFromExercises = await _context.ExerciseStuTeaches
                    .Where(est => est.Studentid == studentIdd)
                    .Select(est => est.Courseid)
                    .Distinct()
                    .ToListAsync();

                var courseIdsFromExams = await _context.ExamStuTeaches
                    .Where(est => est.Studentid == studentIdd && est.Exam != null && est.Exam.Courseid.HasValue)
                    .Select(est => est.Exam.Courseid.Value)
                    .Distinct()
                    .ToListAsync();

                var allCourseIds = courses
                    .ToList();

                // Get course details
                var courseDetails = await _context.Courses
                    .Where(c => allCourseIds.Contains(c.Courseid))
                    .Select(c => new { c.Courseid, Name = c.Name ?? "نامشخص" })
                    .ToListAsync();

                // === 3. Grades per course ===
                var grades = new List<object>();

                foreach (var course in courseDetails)
                {
                    var avgScore = await _context.Scores
                        .Where(s => s.Studentid == studentIdd && s.Courseid == course.Courseid)
                        .AverageAsync(s => (double?)s.ScoreValue) ?? 0.0;

                    var percent = (int)Math.Round(avgScore);

                    var avgExercises = await _context.ExerciseStuTeaches
                        .Where(est => est.Studentid == studentIdd && est.Score != null && est.Courseid == course.Courseid)
                        .AverageAsync(est => (double?)est.Score) ?? 0.0;

                    var avgExams = await _context.ExamStuTeaches
                        .Where(est => est.Studentid == studentIdd && est.Score != null && est.Exam.Courseid == course.Courseid)
                        .AverageAsync(est => (double?)est.Score) ?? 0.0;

                    grades.Add(new
                    {
                        name = course.Name,
                        percent,
                        isTop = course.Name == "ریاضی ۳",
                        avgExercises,
                        avgExams
                    });
                }

                grades = grades.OrderByDescending(g => ((dynamic)g).percent).ToList();

                // === 4. Stats ===
                var totalScores = await _context.Scores
                    .CountAsync(s => s.Studentid == studentIdd && s.Classid == student.Classeid);

                var uniqueCourses = allCourseIds.Count;

                // هر درس = ۳ واحد (مثال)
                var units = uniqueCourses * 3;

                // زنگ = تعداد امتیازات (مثال)
                var bells = totalScores;

                var response = new
                {
                    studentName = student.Name,
                    gpa = Math.Round(gpa, 1),
                    bells,
                    courses = uniqueCourses,
                    units,
                    grades
                };

                return Ok(response);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "خطای سرور", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Get exams for student's class with optional date filtering
        // ──────────────────────────────────────────────────────────────
        [HttpGet("exams/{studentId}")]
        public async Task<IActionResult> GetExams(
            long studentId,
            [FromQuery] string? start,
            [FromQuery] string? end)
        {
            var student = await _context.Students
                .Where(s => s.UserID == studentId)
                .Select(s => new { s.Classeid })
                .FirstOrDefaultAsync();

            if (student == null)
                return NotFound("دانش‌آموز یافت نشد");

            var query = _context.Exams
                .Where(e => e.Classid == student.Classeid);

            if (!string.IsNullOrEmpty(start))
                query = query.Where(e => string.Compare(e.Enddate ?? "", start) >= 0);
            if (!string.IsNullOrEmpty(end))
                query = query.Where(e => string.Compare(e.Enddate ?? "", end) <= 0);

            var result = await query
                .Include(e => e.Course)
                .Select(e => new
                {
                    title = e.Title,
                    courseName = e.Course != null ? e.Course.Name : "نامشخص",
                    examDate = e.Enddate,
                    startTime = e.Starttime,
                    endTime = e.Endtime
                })
                .ToListAsync();

            return Ok(result);
        }

        // ──────────────────────────────────────────────────────────────
        // Get all courses for student with latest grade and teacher info
        // ──────────────────────────────────────────────────────────────
        [HttpGet("courses/{userId}")]
        public async Task<IActionResult> GetStudentCourses(long userId)
        {
            var student = await _context.Students
                .Where(s => s.UserID == userId)
                .Select(s => new { s.Classeid, s.Studentid })
                .FirstOrDefaultAsync();

            if (student == null) return NotFound("دانش‌آموز یافت نشد");

            var courses = await _context.Courses
                .Where(c => c.Classid == student.Classeid)
                .Include(c => c.Teacher)
                .GroupJoin(
                    _context.Scores.Where(sc => sc.Studentid == student.Studentid),
                    c => c.Courseid,
                    sc => sc.Courseid,
                    (c, scores) => new { c, scores }
                )
                .SelectMany(
                    x => x.scores.DefaultIfEmpty(),
                    (c, sc) => new { c.c, score = sc }
                )
                .GroupBy(x => new
                {
                    x.c.Courseid,
                    x.c.Name,
                    x.c.Code,
                    x.c.Location,
                    x.c.Classtime,
                    TeacherName = x.c.Teacher != null ? x.c.Teacher.Name : "نامشخص"
                })
                .Select(g => new
                {
                    courseName = g.Key.Name,
                    courseCode = g.Key.Code,
                    teacherName = g.Key.TeacherName,
                    location = g.Key.Location,
                    Classtime = g.Key.Classtime,
                    grade = g.OrderByDescending(s => s.score != null ? s.score.Id : 0)
                             .FirstOrDefault().score != null
                        ? g.OrderByDescending(s => s.score != null ? s.score.Id : 0)
                           .FirstOrDefault().score.ScoreValue.ToString()
                        : "-"
                })
                .ToListAsync();

            return Ok(courses);
        }
        // ──────────────────────────────────────────────────────────────
        // Get overall average grade for the student
        // ──────────────────────────────────────────────────────────────
        [HttpGet("average/{userId}")]
        public async Task<IActionResult> GetStudentAverage(long userId)
        {
            var studentId = await _context.Students
                .Where(s => s.UserID == userId)
                .Select(s => s.Studentid)
                .FirstOrDefaultAsync();

            if (studentId == 0) return NotFound();

            var average = await _context.Scores
                .Where(s => s.Studentid == studentId)
                .AverageAsync(s => (double?)s.ScoreValue) ?? 0.0;

            return Ok(new { average = Math.Round(average, 1) });
        }

        // ──────────────────────────────────────────────────────────────
        // Get student stats for dashboard cards
        // - Last score month (discipline score)
        // - Total courses
        // - Overall average
        // - Submitted assignments
        // ──────────────────────────────────────────────────────────────
        [HttpGet("stats/{userId}")]
        public async Task<IActionResult> GetStudentStats(long userId)
        {
            var student = await _context.Students
                .Where(s => s.UserID == userId)
                .Select(s => new { s.Studentid, s.Name, s.Classeid })
                .FirstOrDefaultAsync();

            if (student == null)
                return NotFound("دانش‌آموز یافت نشد");

            var totalCourses = await _context.Courses
                .Where(c => c.Classid == student.Classeid)
                .CountAsync();

            var average = await _context.Scores
                .Where(s => s.Studentid == student.Studentid)
                .AverageAsync(s => (double?)s.ScoreValue) ?? 0.0;

            var lastScoreMonth = await _context.Scores
                .Where(s => s.Studentid == student.Studentid)
                .OrderByDescending(s => s.Id)
                .Select(s => s.ScoreValue)
                .FirstOrDefaultAsync();

            var todayShamsi = DateTime.Now.ToShamsi(); // 1403-09-01

            var upcomingExamsCount = await _context.Exams
                .Where(e => e.Classid == student.Classeid &&
                            e.Enddate != null &&
                            string.Compare(e.Enddate, todayShamsi) >= 0)
                .CountAsync();

            var stats = new[]
            {
                new { label = "آخرین نمره",       value = lastScoreMonth.ToString() ?? "ندارد", subtitle = "ماه",       icon = "event",     color = "purple" },
                new { label = "تعداد دروس",       value = totalCourses.ToString(),   subtitle = "ثبت‌نام شده", icon = "school",    color = "green"  },
                new { label = "میانگین نمرات",    value = average.ToString("F1"),    subtitle = "از ۲۰",      icon = "grade",     color = "blue"   },
                new { label = "آزمون‌های آینده",   value = upcomingExamsCount.ToString(), subtitle = "در پیش رو", icon = "upcoming",  color = "orange" }
            };

            return Ok(stats);
        }


        // ──────────────────────────────────────────────────────────────
        // Get student's full name for display (AppBar, Profile, etc.)
        // ──────────────────────────────────────────────────────────────
        [HttpGet("name/{userId}")]
        public async Task<IActionResult> GetStudentName(long userId)
        {
            var name = await _context.Students
                .Where(s => s.UserID == userId)
                .Select(s => s.Name)
                .FirstOrDefaultAsync();

            return Ok(new { name = name ?? "دانش‌آموز" });
        }

        // ──────────────────────────────────────────────────────────────
        // Submit assignment answer
        // ──────────────────────────────────────────────────────────────
        [HttpPost("submit/assignment/{userId}/{assignmentId}")]
        public async Task<IActionResult> SubmitAssignment(
            long userId,
            long assignmentId,
            [FromForm] string? description,
            [FromForm] IFormFile? file)
        {
            var studentId = await _context.Students
                            .Where(s => s.UserID == userId)
                            .Select(s => s.Studentid)
                            .FirstOrDefaultAsync();
            // Validate student exists
            var student = await _context.Students.FindAsync(studentId);
            if (student == null) return NotFound("دانش‌آموز یافت نشد");

            // Get assignment (exercise)
            var assignment = await _context.Exercises
                .Include(e => e.Course)
                .FirstOrDefaultAsync(e => e.Exerciseid == assignmentId);

            if (assignment == null) return NotFound("تکلیف یافت نشد");

            if (assignment.Courseid == null || assignment.Course?.Teacherid == null)
                return BadRequest("اطلاعات درس ناقص است");

            // Check if already submitted
            var existing = await _context.ExerciseStuTeaches
                .FirstOrDefaultAsync(est =>
                    est.Exerciseid == assignmentId &&
                    est.Studentid == studentId);

            if (existing != null) return BadRequest("پاسخ قبلاً ارسال شده");

            // Handle file upload if provided
            string? fileName = null;
            if (file != null)
            {
                var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "assignments");
                if (!Directory.Exists(uploadsFolder)) Directory.CreateDirectory(uploadsFolder);

                fileName = $"{Guid.NewGuid()}_{file.FileName}";
                var filePath = Path.Combine(uploadsFolder, fileName);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }
            }

            // Create new submission
            var submission = new ExerciseStuTeach
            {
                Exerciseid = assignmentId,
                Courseid = assignment.Courseid.Value,
                Teacherid = assignment.Course.Teacherid.Value,
                Studentid = studentId,
                Description = description,
                Date = DateTime.Now.ToShamsi(),
                Filename = fileName,
                Answerimage = fileName, // If it's image, or adjust based on type
                Score = null // Pending grading
            };

            _context.ExerciseStuTeaches.Add(submission);
            await _context.SaveChangesAsync();

            return Ok(new { message = "پاسخ با موفقیت ارسال شد" });
        }

        // ──────────────────────────────────────────────────────────────
        // Submit exam answer
        // ──────────────────────────────────────────────────────────────
        [HttpPost("submit/exam/{userId}/{examId}")]
        public async Task<IActionResult> SubmitExam(
            long userId,
            long examId,
            [FromForm] string? description,
            [FromForm] IFormFile? file,
            [FromForm] string? isUpdate = "false")
        {
            try
            {
                var studentId = await _context.Students
                        .Where(s => s.UserID == userId)
                        .Select(s => s.Studentid)
                        .FirstOrDefaultAsync();

                var student = await _context.Students.FindAsync(studentId);
                if (student == null) return NotFound("دانش‌آموز یافت نشد");

                var exam = await _context.Exams
                    .Include(e => e.Course)
                    .FirstOrDefaultAsync(e => e.Examid == examId);

                if (exam == null) return NotFound("امتحان یافت نشد");

                if (exam.Courseid == null || exam.Course?.Teacherid == null)
                    return BadRequest("اطلاعات درس ناقص است");

                // Parse isUpdate - default to false
                bool isUpdating = !string.IsNullOrEmpty(isUpdate) &&
                                 (isUpdate.Equals("true", StringComparison.OrdinalIgnoreCase) || isUpdate == "True");

                Console.WriteLine($"[SUBMIT EXAM] UserId: {userId}, ExamId: {examId}, isUpdate: {isUpdating}");

                // Check for existing submission
                var existing = await _context.ExamStuTeaches
                    .FirstOrDefaultAsync(est =>
                        est.Examid == examId &&
                        est.Studentid == studentId);

                Console.WriteLine($"[SUBMIT EXAM] Existing submission: {(existing != null ? "FOUND" : "NOT FOUND")}");

                // Logic:
                // - If isUpdating=false and existing!=null → Reject (already submitted)
                // - If isUpdating=true and existing==null → Reject (no previous submission)
                // - If isUpdating=false and existing==null → Create new
                // - If isUpdating=true and existing!=null → Update existing

                if (!isUpdating && existing != null)
                    return BadRequest("پاسخ قبلاً ارسال شده");

                if (isUpdating && existing == null)
                    return BadRequest("پاسخ قبلی یافت نشد");

                // Handle file upload
                string? fileName = null;
                if (file != null && file.Length > 0)
                {
                    var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "exams");
                    if (!Directory.Exists(uploadsFolder))
                        Directory.CreateDirectory(uploadsFolder);

                    fileName = $"{Guid.NewGuid()}_{file.FileName}";
                    var filePath = Path.Combine(uploadsFolder, fileName);

                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await file.CopyToAsync(stream);
                    }

                    // Delete old file if updating
                    if (isUpdating && !string.IsNullOrEmpty(existing?.Filename))
                    {
                        try
                        {
                            var oldFilePath = Path.Combine(uploadsFolder, existing.Filename);
                            if (System.IO.File.Exists(oldFilePath))
                                System.IO.File.Delete(oldFilePath);

                            Console.WriteLine($"[SUBMIT EXAM] Deleted old file: {existing.Filename}");
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"[SUBMIT EXAM] Error deleting old file: {ex.Message}");
                        }
                    }
                }

                if (isUpdating && existing != null)
                {
                    // UPDATE existing submission
                    Console.WriteLine($"[SUBMIT EXAM] Updating existing submission");

                    existing.Description = description ?? existing.Description;
                    existing.Date = DateTime.Now.ToShamsi();
                    existing.Time = DateTime.Now.ToString("HH:mm:ss");

                    // Only update filename if a new file was provided
                    if (fileName != null)
                    {
                        existing.Filename = fileName;
                        existing.Answerimage = fileName;
                    }

                    _context.ExamStuTeaches.Update(existing);
                    await _context.SaveChangesAsync();

                    return Ok(new {
                        message = "پاسخ با موفقیت به‌روزرسانی شد",
                        isUpdate = true,
                        submissionId = existing.Estid
                    });
                }
                else
                {
                    // CREATE new submission
                    Console.WriteLine($"[SUBMIT EXAM] Creating new submission");

                    var submission = new ExamStuTeach
                    {
                        Examid = examId,
                        Courseid = exam.Courseid.Value,
                        Teacherid = exam.Course.Teacherid.Value,
                        Studentid = studentId,
                        Description = description,
                        Date = DateTime.Now.ToShamsi(),
                        Time = DateTime.Now.ToString("HH:mm:ss"),
                        Filename = fileName,
                        Answerimage = fileName,
                        Score = null
                    };

                    _context.ExamStuTeaches.Add(submission);
                    await _context.SaveChangesAsync();

                    return Ok(new {
                        message = "پاسخ با موفقیت ارسال شد",
                        isUpdate = false,
                        submissionId = submission.Estid
                    });
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SUBMIT EXAM] Exception: {ex.Message}");
                Console.WriteLine($"[SUBMIT EXAM] StackTrace: {ex.StackTrace}");
                return StatusCode(500, new { message = "خطای سرور", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Update assignment answer (replace existing submission)
        // ──────────────────────────────────────────────────────────────
        [HttpPost("update/assignment/{userId}/{assignmentId}")]
        public async Task<IActionResult> UpdateAssignmentAnswer(
            long userId,
            long assignmentId,
            [FromForm] string? description,
            [FromForm] IFormFile? file)
        {
            var studentId = await _context.Students
                .Where(s => s.UserID == userId)
                .Select(s => s.Studentid)
                .FirstOrDefaultAsync();

            var student = await _context.Students.FindAsync(studentId);
            if (student == null) return NotFound("دانش‌آموز یافت نشد");

            var assignment = await _context.Exercises
                .Include(e => e.Course)
                .FirstOrDefaultAsync(e => e.Exerciseid == assignmentId);

            if (assignment == null) return NotFound("تکلیف یافت نشد");

            // Find existing submission
            var existing = await _context.ExerciseStuTeaches
                .FirstOrDefaultAsync(est =>
                    est.Exerciseid == assignmentId &&
                    est.Studentid == studentId);

            if (existing == null)
                return BadRequest("پاسخ قبلی یافت نشد");

            // Delete old file if it exists
            if (!string.IsNullOrEmpty(existing.Filename))
            {
                var oldFilePath = Path.Combine(
                    Directory.GetCurrentDirectory(),
                    "wwwroot", "uploads", "assignments",
                    existing.Filename);

                if (System.IO.File.Exists(oldFilePath))
                {
                    System.IO.File.Delete(oldFilePath);
                }
            }

            // Handle new file upload
            string? fileName = null;
            if (file != null)
            {
                var uploadsFolder = Path.Combine(
                    Directory.GetCurrentDirectory(),
                    "wwwroot", "uploads", "assignments");

                if (!Directory.Exists(uploadsFolder))
                    Directory.CreateDirectory(uploadsFolder);

                fileName = $"{Guid.NewGuid()}_{file.FileName}";
                var filePath = Path.Combine(uploadsFolder, fileName);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }
            }
            else if (string.IsNullOrEmpty(fileName))
            {
                // If no new file provided, keep the old filename
                fileName = existing.Filename;
            }

            // Update existing submission
            existing.Description = description ?? existing.Description;
            existing.Date = DateTime.Now.ToShamsi();
            existing.Filename = fileName;
            existing.Answerimage = fileName;

            _context.ExerciseStuTeaches.Update(existing);
            await _context.SaveChangesAsync();

            return Ok(new { message = "پاسخ با موفقیت به‌روزرسانی شد" });
        }

        // ──────────────────────────────────────────────────────────────
        // Update exam answer (replace existing submission)
        // ──────────────────────────────────────────────────────────────
        [HttpPost("update/exam/{userId}/{examId}")]
        public async Task<IActionResult> UpdateExamAnswer(
            long userId,
            long examId,
            [FromForm] string? description,
            [FromForm] IFormFile? file)
        {
            var studentId = await _context.Students
                .Where(s => s.UserID == userId)
                .Select(s => s.Studentid)
                .FirstOrDefaultAsync();

            var student = await _context.Students.FindAsync(studentId);
            if (student == null) return NotFound("دانش‌آموز یافت نشد");

            var exam = await _context.Exams
                .Include(e => e.Course)
                .FirstOrDefaultAsync(e => e.Examid == examId);

            if (exam == null) return NotFound("امتحان یافت نشد");

            // Find existing submission
            var existing = await _context.ExamStuTeaches
                .FirstOrDefaultAsync(est =>
                    est.Examid == examId &&
                    est.Studentid == studentId);

            if (existing == null)
                return BadRequest("پاسخ قبلی یافت نشد");

            // Delete old file if it exists
            if (!string.IsNullOrEmpty(existing.Filename))
            {
                var oldFilePath = Path.Combine(
                    Directory.GetCurrentDirectory(),
                    "wwwroot", "uploads", "exams",
                    existing.Filename);

                if (System.IO.File.Exists(oldFilePath))
                {
                    System.IO.File.Delete(oldFilePath);
                }
            }

            // Handle new file upload
            string? fileName = null;
            if (file != null)
            {
                var uploadsFolder = Path.Combine(
                    Directory.GetCurrentDirectory(),
                    "wwwroot", "uploads", "exams");

                if (!Directory.Exists(uploadsFolder))
                    Directory.CreateDirectory(uploadsFolder);

                fileName = $"{Guid.NewGuid()}_{file.FileName}";
                var filePath = Path.Combine(uploadsFolder, fileName);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }
            }
            else if (string.IsNullOrEmpty(fileName))
            {
                // If no new file provided, keep the old filename
                fileName = existing.Filename;
            }

            // Update existing submission
            existing.Description = description ?? existing.Description;
            existing.Date = DateTime.Now.ToShamsi();
            existing.Time = DateTime.Now.ToString("HH:mm:ss");
            existing.Filename = fileName;
            existing.Answerimage = fileName;

            _context.ExamStuTeaches.Update(existing);
            await _context.SaveChangesAsync();

            return Ok(new { message = "پاسخ با موفقیت به‌روزرسانی شد" });
        }
    }
}

public static class DateTimeExtensions
{
    public static string ToShamsi(this DateTime date)
    {
        var pc = new System.Globalization.PersianCalendar();
        return $"{pc.GetYear(date)}-{pc.GetMonth(date):D2}-{pc.GetDayOfMonth(date):D2}";
    }
}


