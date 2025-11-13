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
        // Get exams for student's
        // ──────────────────────────────────────────────────────────────
        [HttpGet("exam/{studentId}")]
        public async Task<ActionResult<IEnumerable<object>>> GetAllExams(long studentId)
        {
            var studentIdd = await _context.Students
                            .Where(s => s.UserID == studentId)
                            .Select(s => s.Studentid)
                            .FirstOrDefaultAsync();

            var exams = await _context.ExamStuTeaches
            .Where(est => est.Studentid == studentId)
                    .Include(est => est.Exam)
                        .ThenInclude(e => e!.Course)
                    .Include(est => est.Exam)
                        .ThenInclude(e => e!.Class)
                    .Select(est => new
                    {
                        id            = est.Estid,

                        // Use EF.Property + ?? to safely read NULLs
                        title         = EF.Property<string>(est.Exam, nameof(Exam.Title)) ?? "بدون عنوان",
                        courseName    = EF.Property<string>(EF.Property<object>(est.Exam, nameof(Exam.Course)), nameof(Course.Name)) ?? "نامشخص",
                        className     = EF.Property<string>(EF.Property<object>(est.Exam, nameof(Exam.Class)), nameof(Class.Name)),
                        description   = EF.Property<string>(est.Exam, nameof(Exam.Description)),
                        examDate      = EF.Property<string>(est.Exam, nameof(Exam.Enddate)),
                        startDate     = EF.Property<string>(est.Exam, nameof(Exam.Startdate)),
                        startTime     = EF.Property<string>(est.Exam, nameof(Exam.Starttime)),
                        endTime       = EF.Property<string>(est.Exam, nameof(Exam.Endtime)),

                        // Direct fields (safe if nullable in model)
                        score         = est.Score,
                        answerImage   = est.Answerimage,
                        filename      = est.Filename,
                        submittedDate = est.Date
                    })
                    .OrderBy(e => e.examDate ?? "")
                    .ToListAsync();

                return Ok(exams);
            }

            // GET: api/student/my-score/123
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
                                           var gpaQuery = await _context.ExamStuTeaches
                                               .Where(e => e.Studentid == studentId && e.Score != null)
                                               .AverageAsync(e => (double?)e.Score);

                                           var gpa = gpaQuery ?? 0.0;

                                           // === 2. Stats (using ExamStuTeach) ===
                                           var totalExams = await _context.ExamStuTeaches
                                               .CountAsync(e => e.Studentid == studentId);

                                           var uniqueCourses = await _context.ExamStuTeaches
                                               .Where(e => e.Studentid == studentId && e.Examid != null)
                                               .Select(e => e.Exam!.Courseid)
                                               .Distinct()
                                               .CountAsync();

                                           // هر درس = ۳ واحد (مثال)
                                           var units = uniqueCourses * 3;

                                           // === 3. Grades per subject (using Exam.Title) ===
                                           var grades = await _context.ExamStuTeaches
                                               .Where(e => e.Studentid == studentId && e.Score != null && e.Exam != null)
                                               .GroupBy(e => e.Exam.Title ?? "نامشخص")
                                               .Select(g => new
                                               {
                                                   name = g.Key,
                                                   percent = (int)Math.Round(g.Average(x => (double)x.Score!) * 5), // 20 → 100%
                                                   isTop = g.Key == "ریاضی ۳"
                                               })
                                               .OrderByDescending(g => g.percent)
                                               .ToListAsync();

                                           // === 4. زنگ = تعداد امتحانات (مثال) ===
                                           var bells = totalExams;

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
                .Select(s => s.Score_month)
                .FirstOrDefaultAsync();

            var todayShamsi = DateTime.Now.ToShamsi(); // 1403-09-01

            var upcomingExamsCount = await _context.Exams
                .Where(e => e.Classid == student.Classeid &&
                            e.Enddate != null &&
                            string.Compare(e.Enddate, todayShamsi) >= 0)
                .CountAsync();

            var stats = new[]
            {
                new { label = "آخرین نمره",       value = lastScoreMonth ?? "ندارد", subtitle = "ماه",       icon = "event",     color = "purple" },
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


