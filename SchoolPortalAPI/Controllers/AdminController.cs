using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SchoolPortalAPI.Data;
using SchoolPortalAPI.Models;

namespace SchoolPortalAPI.Controllers
{
    [ApiController]
    [Route("api/admin")]
    public class AdminController : ControllerBase
    {
        private readonly SchoolDbContext _context;

        public AdminController(SchoolDbContext context)
        {
            _context = context;
        }

        // ──────────────────────────────────────────────────────────────
        // Get average score per class and course across the entire system
        // ──────────────────────────────────────────────────────────────
        [HttpGet("progress")]
        public async Task<IActionResult> GetAdminProgress()
        {
            try
            {
                var progress = await _context.Scores
                    .Include(s => s.Course)
                    .Include(s => s.Class)
                    .Where(s => s.Course != null && s.Class != null)
                    .GroupBy(s => new { s.Classid, s.Courseid })
                    .Select(g => new
                    {
                        className = g.First().Class != null ? g.First().Class.Name : "نامشخص",
                        courseName = g.First().Course != null ? g.First().Course.Name : "نامشخص",
                        average = g.Average(s => (double?)s.ScoreValue) ?? 0.0
                    })
                    .OrderBy(x => x.className)
                    .ThenBy(x => x.courseName)
                    .ToListAsync();

                return Ok(progress);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "خطا در دریافت پیشرفت", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Get system-wide statistics for admin dashboard cards
        // ──────────────────────────────────────────────────────────────
        [HttpGet("stats")]
        public async Task<IActionResult> GetAdminStats()
        {
            try
            {
                var totalStudents = await _context.Students.CountAsync();
                var totalTeachers = await _context.Teachers.CountAsync();
                var totalClasses = await _context.Classes.CountAsync();
                var totalCourses = await _context.Courses.CountAsync();

                var stats = new[]
                {
                    new { label = "کل دانش‌آموزان",   value = totalStudents.ToString(),  subtitle = "فعال",        icon = "person",     color = "blue"    },
                    new { label = "کل معلمان",       value = totalTeachers.ToString(),  subtitle = "فعال",        icon = "school",     color = "green"   },
                    new { label = "کل کلاس‌ها",      value = totalClasses.ToString(),   subtitle = "تشکیل‌شده",   icon = "class",      color = "purple"  },
                    new { label = "کل دروس",         value = totalCourses.ToString(),   subtitle = "تعریف‌شده",   icon = "menu_book",  color = "orange"  }
                };

                return Ok(stats);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "خطا در دریافت آمار", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Get admin's full name for display in AppBar and profile
        // ──────────────────────────────────────────────────────────────
        [HttpGet("name/{userId}")]
        public async Task<IActionResult> GetAdminName(long userId)
        {
            try
            {
                var name = await _context.Managers
                    .Where(m => m.Userid == userId)
                    .Select(m => m.Name)
                    .FirstOrDefaultAsync();

                return Ok(new { name = name ?? "مدیر" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "خطا در دریافت نام", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Get all classes with their statistics
        // ──────────────────────────────────────────────────────────────
        [HttpGet("classes")]
        public async Task<IActionResult> GetAllClasses()
        {
            try
            {
                // Fetch all data first (separate queries) - select only what we need
                var allClasses = await _context.Classes
                    .Select(c => new { c.Classid, c.Name, c.Grade, c.Capacity })
                    .ToListAsync();

                var allStudents = await _context.Students
                    .Select(s => new { s.Studentid, s.Classeid })
                    .ToListAsync();

                var allScores = await _context.Scores
                    .Select(sc => new { sc.Classid, sc.ScoreValue })
                    .ToListAsync();

                // Process in memory - handle null values
                var classes = allClasses
                    .Select(c => new
                    {
                        id = c.Classid,
                        name = c.Name ?? $"کلاس {c.Classid}",
                        grade = c.Grade ?? "نامشخص",
                        capacity = c.Capacity,
                        studentCount = allStudents.Count(s => s.Classeid == c.Classid),
                        avgScore = allScores
                            .Where(sc => sc.Classid == c.Classid)
                            .Count() > 0
                            ? allScores
                                .Where(sc => sc.Classid == c.Classid)
                                .Average(sc => (double)sc.ScoreValue)
                            : 0.0,
                        passPercentage = allScores
                            .Where(sc => sc.Classid == c.Classid)
                            .Count() > 0
                            ? (int)System.Math.Round(
                                (double)allScores
                                    .Count(sc => sc.Classid == c.Classid && sc.ScoreValue >= 12) /
                                allScores
                                    .Where(sc => sc.Classid == c.Classid)
                                    .Count() * 100
                            )
                            : 0,
                    })
                    .OrderBy(c => c.name)
                    .ToList();

                return Ok(classes);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] GetAllClasses: {ex.Message}\n{ex.StackTrace}");
                return StatusCode(500, new { message = "خطا در دریافت کلاس‌ها", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Get overview statistics for all classes
        // ──────────────────────────────────────────────────────────────
        [HttpGet("overview")]
        public async Task<IActionResult> GetOverviewStatistics()
        {
            try
            {
                // Fetch all data first - select only what we need
                var allClasses = await _context.Classes
                    .Select(c => new { c.Classid, c.Name, c.Grade })
                    .ToListAsync();

                var allStudents = await _context.Students
                    .Select(s => new { s.Studentid, s.Classeid })
                    .ToListAsync();

                var allScores = await _context.Scores
                    .Select(sc => new { sc.Classid, sc.ScoreValue })
                    .ToListAsync();

                var allCourses = await _context.Courses
                    .Select(c => new { c.Courseid, c.Classid })
                    .ToListAsync();

                // Process in memory - handle null values
                var classesOverview = allClasses
                    .Select(c => new
                    {
                        id = c.Classid,
                        name = c.Name ?? $"کلاس {c.Classid}",
                        grade = c.Grade ?? "نامشخص",
                        studentCount = allStudents.Count(s => s.Classeid == c.Classid),
                        avgScore = System.Math.Round(
                            allScores
                                .Where(s => s.Classid == c.Classid)
                                .Count() > 0
                                ? allScores
                                    .Where(s => s.Classid == c.Classid)
                                    .Average(s => (double)s.ScoreValue)
                                : 0.0, 1
                        ),
                        passPercentage = allScores
                            .Where(s => s.Classid == c.Classid)
                            .Count() > 0
                            ? (int)System.Math.Round(
                                (double)allScores
                                    .Count(s => s.Classid == c.Classid && s.ScoreValue >= 12) /
                                allScores
                                    .Where(s => s.Classid == c.Classid)
                                    .Count() * 100
                            )
                            : 0,
                        totalLessons = allCourses.Count(c2 => c2.Classid == c.Classid),
                    })
                    .OrderBy(c => c.name)
                    .ToList();

                return Ok(classesOverview);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] GetOverviewStatistics: {ex.Message}\n{ex.StackTrace}");
                return StatusCode(500, new { message = "خطا در دریافت آمار کلی", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Get detailed statistics for a specific class
        // ──────────────────────────────────────────────────────────────
        [HttpGet("class/{classId}/statistics")]
        public async Task<IActionResult> GetClassStatistics(long classId)
        {
            try
            {
                var classObj = await _context.Classes
                    .FirstOrDefaultAsync(c => c.Classid == classId);

                if (classObj == null)
                    return NotFound(new { message = "کلاس یافت نشد" });

                var safeClassName = classObj.Name ?? $"کلاس {classId}";
                var safeGrade = classObj.Grade ?? "نامشخص";

                // Fetch all related data
                var students = await _context.Students
                    .Where(s => s.Classeid == classId)
                    .ToListAsync();

                var allScores = await _context.Scores
                    .Include(s => s.Course)
                    .Where(s => s.Classid == classId)
                    .ToListAsync();

                var studentIds = students.Select(s => s.Studentid).ToList();

                if (!students.Any())
                    return Ok(new
                    {
                        id = classObj.Classid,
                        name = safeClassName,
                        grade = safeGrade,
                        capacity = classObj.Capacity,
                        totalStudents = 0,
                        avgScore = 0.0,
                        passPercentage = 0,
                        scoreRanges = new List<object>(),
                        subjectScores = new List<object>(),
                        topPerformers = new List<object>(),
                    });

                if (!allScores.Any())
                    return Ok(new
                    {
                        id = classObj.Classid,
                        name = classObj.Name,
                        grade = classObj.Grade,
                        capacity = classObj.Capacity,
                        totalStudents = students.Count,
                        avgScore = 0.0,
                        passPercentage = 0,
                        scoreRanges = new List<object>(),
                        subjectScores = new List<object>(),
                        topPerformers = new List<object>(),
                    });

                // Calculate in memory
                double avgScore = allScores.Average(s => (double)s.ScoreValue);
                int passCount = allScores.Count(s => s.ScoreValue >= 12);
                int passPercentage = (int)System.Math.Round((double)passCount / allScores.Count * 100);

                // Score distribution
                var scoreRanges = new List<dynamic>
                {
                    new { range = "18-20", count = allScores.Count(s => s.ScoreValue >= 18), percentage = 0 },
                    new { range = "16-18", count = allScores.Count(s => s.ScoreValue >= 16 && s.ScoreValue < 18), percentage = 0 },
                    new { range = "14-16", count = allScores.Count(s => s.ScoreValue >= 14 && s.ScoreValue < 16), percentage = 0 },
                    new { range = "12-14", count = allScores.Count(s => s.ScoreValue >= 12 && s.ScoreValue < 14), percentage = 0 },
                    new { range = "<12", count = allScores.Count(s => s.ScoreValue < 12), percentage = 0 },
                };

                int totalScores = allScores.Count;
                foreach (var range in scoreRanges)
                {
                    range.percentage = totalScores > 0 ? (int)System.Math.Round((double)range.count / totalScores * 100) : 0;
                }

                // Subject scores
                var subjectScores = allScores
                    .GroupBy(s => new { s.Courseid, CourseName = s.Course != null ? s.Course.Name : "نامشخص" })
                    .Select(g => new
                    {
                        name = g.Key.CourseName,
                        avgScore = System.Math.Round(g.Average(s => (double)s.ScoreValue), 1),
                        totalCount = g.Count(),
                    })
                    .OrderByDescending(s => s.avgScore)
                    .ToList();

                // Top performers
                var topPerformersQuery = allScores
                    .GroupBy(s => s.Studentid)
                    .Select(g => new
                    {
                        studentId = g.Key,
                        avgScore = System.Math.Round(g.Average(s => (double)s.ScoreValue), 2),
                    })
                    .OrderByDescending(s => s.avgScore)
                    .Take(3)
                    .ToList();

                var topPerformers = new List<dynamic>();
                int rank = 1;
                foreach (var perf in topPerformersQuery)
                {
                    var student = students.FirstOrDefault(s => s.Studentid == perf.studentId);
                    topPerformers.Add(new
                    {
                        studentId = perf.studentId,
                        name = student != null ? student.Name : "نامشخص",
                        avgScore = perf.avgScore,
                        rank = rank,
                    });
                    rank++;
                }

                return Ok(new
                {
                    id = classObj.Classid,
                    name = safeClassName,
                    grade = safeGrade,
                    capacity = classObj.Capacity,
                    totalStudents = students.Count,
                    avgScore = System.Math.Round(avgScore, 1),
                    passPercentage = passPercentage,
                    scoreRanges = scoreRanges,
                    subjectScores = subjectScores,
                    topPerformers = topPerformers,
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] GetClassStatistics: {ex.Message}\n{ex.StackTrace}");
                return StatusCode(500, new { message = "خطا در دریافت آمار کلاس", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Get monthly trend for a class
        // ──────────────────────────────────────────────────────────────
        [HttpGet("class/{classId}/monthly-trend")]
        public async Task<IActionResult> GetMonthlyTrend(long classId)
        {
            try
            {
                var allScores = await _context.Scores
                    .Where(s => s.Classid == classId)
                    .ToListAsync();

                var monthlyData = allScores
                    .GroupBy(s => s.Score_month ?? "نامشخص")
                    .Select(g => new
                    {
                        month = g.Key,
                        avgScore = System.Math.Round(g.Average(s => (double)s.ScoreValue), 1),
                        count = g.Count(),
                    })
                    .OrderBy(m => m.month)
                    .ToList();

                return Ok(monthlyData);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] GetMonthlyTrend: {ex.Message}\n{ex.StackTrace}");
                return StatusCode(500, new { message = "خطا در دریافت روند ماهانه", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Get class comparison data
        // ──────────────────────────────────────────────────────────────
        [HttpGet("classes-comparison")]
        public async Task<IActionResult> GetClassesComparison()
        {
            try
            {
                var allClasses = await _context.Classes.ToListAsync();
                var allStudents = await _context.Students.ToListAsync();
                var allScores = await _context.Scores.ToListAsync();

                var comparison = allClasses
                    .Select(c => new
                    {
                        id = c.Classid,
                        name = c.Name ?? $"کلاس {c.Classid}",
                        grade = c.Grade ?? "نامشخص",
                        studentCount = allStudents.Count(s => s.Classeid == c.Classid),
                        avgScore = System.Math.Round(
                            allScores
                                .Where(s => s.Classid == c.Classid)
                                .Count() > 0
                                ? allScores
                                    .Where(s => s.Classid == c.Classid)
                                    .Average(s => (double)s.ScoreValue)
                                : 0.0, 1
                        ),
                        passPercentage = allScores
                            .Where(s => s.Classid == c.Classid)
                            .Count() > 0
                            ? (int)System.Math.Round(
                                (double)allScores
                                    .Count(s => s.Classid == c.Classid && s.ScoreValue >= 12) /
                                allScores
                                    .Where(s => s.Classid == c.Classid)
                                    .Count() * 100
                            )
                            : 0,
                    })
                    .OrderBy(c => c.name)
                    .ToList();

                return Ok(comparison);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] GetClassesComparison: {ex.Message}\n{ex.StackTrace}");
                return StatusCode(500, new { message = "خطا در مقایسه کلاس‌ها", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Get detailed student list for a class with their scores
        // ──────────────────────────────────────────────────────────────
        [HttpGet("class/{classId}/students")]
        public async Task<IActionResult> GetClassStudents(long classId)
        {
            try
            {
                var students = await _context.Students
                    .Where(s => s.Classeid == classId)
                    .ToListAsync();

                var allScores = await _context.Scores
                    .Where(s => s.Classid == classId)
                    .ToListAsync();

                var result = students
                    .Select(s => new
                    {
                        id = s.Studentid,
                        name = s.Name,
                        stuCode = s.StuCode,
                        avgScore = System.Math.Round(
                            allScores
                                .Where(sc => sc.Studentid == s.Studentid)
                                .Count() > 0
                                ? allScores
                                    .Where(sc => sc.Studentid == s.Studentid)
                                    .Average(sc => (double)sc.ScoreValue)
                                : 0.0, 1
                        ),
                        scoreCount = allScores.Count(sc => sc.Studentid == s.Studentid),
                    })
                    .OrderByDescending(s => s.avgScore)
                    .ToList();

                return Ok(result);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ERROR] GetClassStudents: {ex.Message}\n{ex.StackTrace}");
                return StatusCode(500, new { message = "خطا در دریافت دانش‌آموزان", error = ex.Message });
            }
        }
    }
}