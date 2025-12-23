// Controllers/AdminController.cs
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
            var progress = await _context.Scores
                .Include(s => s.Course)
                .Include(s => s.Class)
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

        // ──────────────────────────────────────────────────────────────
        // Get system-wide statistics for admin dashboard cards
        // - Total students
        // - Total teachers
        // - Total classes
        // - Total courses
        // ──────────────────────────────────────────────────────────────
        [HttpGet("stats")]
        public async Task<IActionResult> GetAdminStats()
        {
            var totalStudents = await _context.Students.CountAsync();
            var totalTeachers = await _context.Teachers.CountAsync();
            var totalClasses  = await _context.Classes.CountAsync();
            var totalCourses  = await _context.Courses.CountAsync();

            var stats = new[]
            {
                new { label = "کل دانش‌آموزان",   value = totalStudents.ToString(),  subtitle = "فعال",        icon = "person",     color = "blue"    },
                new { label = "کل معلمان",       value = totalTeachers.ToString(),  subtitle = "فعال",        icon = "school",     color = "green"   },
                new { label = "کل کلاس‌ها",      value = totalClasses.ToString(),   subtitle = "تشکیل‌شده",   icon = "class",      color = "purple"  },
                new { label = "کل دروس",         value = totalCourses.ToString(),   subtitle = "تعریف‌شده",   icon = "menu_book",  color = "orange"  }
            };

            return Ok(stats);
        }

        // ──────────────────────────────────────────────────────────────
        // Get admin's full name for display in AppBar and profile
        // ──────────────────────────────────────────────────────────────
        [HttpGet("name/{userId}")]
        public async Task<IActionResult> GetAdminName(long userId)
        {
            var name = await _context.Managers
                .Where(m => m.Userid == userId)
                .Select(m => m.Name)
                .FirstOrDefaultAsync();

            return Ok(new { name = name ?? "مدیر" });
        }

        // ──────────────────────────────────────────────────────────────
        // Get all classes with their statistics
        // ──────────────────────────────────────────────────────────────
        [HttpGet("classes")]
        public async Task<IActionResult> GetAllClasses()
        {
            try
            {
                var classes = await _context.Classes
                    .Select(c => new
                    {
                        id = c.Classid,
                        name = c.Name,
                        grade = c.Grade,
                        capacity = c.Capacity,
                        studentCount = _context.Students.Count(s => s.Classeid == c.Classid),
                        avgScore = _context.Scores
                            .Where(sc => sc.Classid == c.Classid)
                            .Average(sc => (double?)sc.ScoreValue) ?? 0,
                        passPercentage = _context.Scores.Where(sc => sc.Classid == c.Classid).Count() > 0 ?
                            (int)System.Math.Round(
                                (double)_context.Scores
                                    .Count(sc => sc.Classid == c.Classid && sc.ScoreValue >= 12) /
                                _context.Scores.Where(sc => sc.Classid == c.Classid).Count() * 100
                            ) : 0,
                    })
                    .OrderBy(c => c.name)
                    .ToListAsync();

                return Ok(classes);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "خطا در دریافت کلاس‌ها", error = ex.Message });
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
                var classObj = await _context.Classes.FindAsync(classId);
                if (classObj == null)
                    return NotFound(new { message = "کلاس یافت نشد" });

                // Get all students in this class
                var students = await _context.Students
                    .Where(s => s.Classeid == classId)
                    .Select(s => s.Studentid)
                    .ToListAsync();

                if (!students.Any())
                    return Ok(new
                    {
                        name = classObj.Name,
                        grade = classObj.Grade,
                        totalStudents = 0,
                        avgScore = 0,
                        passPercentage = 0,
                        scoreRanges = new List<object>(),
                        subjectScores = new List<object>(),
                        topPerformers = new List<object>(),
                    });

                // Get all scores for students in this class
                var allScores = await _context.Scores
                    .Where(s => students.Contains(s.Studentid ?? 0) && s.Classid == classId)
                    .Include(s => s.Course)
                    .ToListAsync();

                if (!allScores.Any())
                    return Ok(new
                    {
                        name = classObj.Name,
                        grade = classObj.Grade,
                        totalStudents = students.Count,
                        avgScore = 0,
                        passPercentage = 0,
                        scoreRanges = new List<object>(),
                        subjectScores = new List<object>(),
                        topPerformers = new List<object>(),
                    });

                // Calculate average score
                double avgScore = allScores.Average(s => s.ScoreValue);

                // Calculate pass percentage (score >= 12)
                int passCount = allScores.Count(s => s.ScoreValue >= 12);
                int passPercentage = (int)System.Math.Round((double)passCount / allScores.Count * 100);

                // Get score distribution
                var scoreRanges = new List<dynamic>
                {
                    new { range = "18-20", count = allScores.Count(s => s.ScoreValue >= 18), percentage = 0 },
                    new { range = "16-18", count = allScores.Count(s => s.ScoreValue >= 16 && s.ScoreValue < 18), percentage = 0 },
                    new { range = "14-16", count = allScores.Count(s => s.ScoreValue >= 14 && s.ScoreValue < 16), percentage = 0 },
                    new { range = "12-14", count = allScores.Count(s => s.ScoreValue >= 12 && s.ScoreValue < 14), percentage = 0 },
                    new { range = "<12", count = allScores.Count(s => s.ScoreValue < 12), percentage = 0 },
                };

                // Calculate percentages for score ranges
                int totalScores = allScores.Count;
                foreach (var range in scoreRanges)
                {
                    range.percentage = totalScores > 0 ? (int)System.Math.Round((double)range.count / totalScores * 100) : 0;
                }

                // Get subject scores
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

                // Get top performers - using raw student IDs and calculating averages
                var topPerformersQuery = await _context.Scores
                    .Where(s => students.Contains(s.Studentid ?? 0) && s.Classid == classId)
                    .GroupBy(s => s.Studentid)
                    .Select(g => new
                    {
                        studentId = g.Key,
                        avgScore = System.Math.Round(g.Average(s => (double)s.ScoreValue), 2),
                    })
                    .OrderByDescending(s => s.avgScore)
                    .Take(3)
                    .ToListAsync();

                // Now get the student names
                var topPerformers = new List<dynamic>();
                int rank = 1;
                foreach (var perf in topPerformersQuery)
                {
                    var student = await _context.Students.FindAsync(perf.studentId);
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
                    name = classObj.Name,
                    grade = classObj.Grade,
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
                return StatusCode(500, new { message = "خطا در دریافت آمار کلاس", error = ex.Message });
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
                var classesOverview = await _context.Classes
                    .Select(c => new
                    {
                        id = c.Classid,
                        name = c.Name,
                        grade = c.Grade,
                        capacity = c.Capacity,
                        studentCount = _context.Students.Count(s => s.Classeid == c.Classid),
                        avgScore = System.Math.Round(
                            _context.Scores
                                .Where(s => s.Classid == c.Classid)
                                .Average(s => (double?)s.ScoreValue) ?? 0, 1
                        ),
                        passPercentage = _context.Scores.Where(s => s.Classid == c.Classid).Count() > 0 ?
                            (int)System.Math.Round(
                                (double)_context.Scores
                                    .Count(s => s.Classid == c.Classid && s.ScoreValue >= 12) /
                                _context.Scores.Where(s => s.Classid == c.Classid).Count() * 100
                            ) : 0,
                        totalLessons = _context.Courses.Count(c2 => c2.Classid == c.Classid),
                    })
                    .OrderBy(c => c.name)
                    .ToListAsync();

                return Ok(classesOverview);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "خطا در دریافت آمار کلی", error = ex.Message });
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
                var monthlyData = await _context.Scores
                    .Where(s => s.Classid == classId)
                    .GroupBy(s => s.Score_month ?? "نامشخص")
                    .Select(g => new
                    {
                        month = g.Key,
                        avgScore = System.Math.Round(g.Average(s => (double)s.ScoreValue), 1),
                        count = g.Count(),
                    })
                    .OrderBy(m => m.month)
                    .ToListAsync();

                return Ok(monthlyData);
            }
            catch (Exception ex)
            {
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
                var comparison = await _context.Classes
                    .Select(c => new
                    {
                        id = c.Classid,
                        name = c.Name,
                        grade = c.Grade,
                        studentCount = _context.Students.Count(s => s.Classeid == c.Classid),
                        avgScore = System.Math.Round(
                            _context.Scores
                                .Where(s => s.Classid == c.Classid)
                                .Average(s => (double?)s.ScoreValue) ?? 0, 1
                        ),
                        passPercentage = _context.Scores.Where(s => s.Classid == c.Classid).Count() > 0 ?
                            (int)System.Math.Round(
                                (double)_context.Scores
                                    .Count(s => s.Classid == c.Classid && s.ScoreValue >= 12) /
                                _context.Scores.Where(s => s.Classid == c.Classid).Count() * 100
                            ) : 0,
                    })
                    .OrderBy(c => c.name)
                    .ToListAsync();

                return Ok(comparison);
            }
            catch (Exception ex)
            {
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
                    .Select(s => new
                    {
                        id = s.Studentid,
                        name = s.Name,
                        stuCode = s.StuCode,
                        avgScore = System.Math.Round(
                            _context.Scores
                                .Where(sc => sc.Studentid == s.Studentid && sc.Classid == classId)
                                .Average(sc => (double?)sc.ScoreValue) ?? 0, 1
                        ),
                        scoreCount = _context.Scores
                            .Count(sc => sc.Studentid == s.Studentid && sc.Classid == classId),
                    })
                    .OrderByDescending(s => s.avgScore)
                    .ToListAsync();

                return Ok(students);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "خطا در دریافت دانش‌آموزان", error = ex.Message });
            }
        }
    }
}