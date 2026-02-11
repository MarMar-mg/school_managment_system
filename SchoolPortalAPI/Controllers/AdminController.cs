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
        public async Task<IActionResult> GetClassStatistics(string classId)
        {
            try
            {
                // Parse classId
                if (!long.TryParse(classId, out long parsedClassId))
                {
                    return BadRequest(new { message = "شناسه کلاس نامعتبر است" });
                }

                // Get class
                var classObj = await _context.Classes
                    .FirstOrDefaultAsync(c => c.Classid == parsedClassId);

                if (classObj == null)
                    return NotFound(new { message = "کلاس یافت نشد" });

                // Get all students in this class with their IDs
                var studentsInClass = await _context.Students
                    .Where(s => s.Classeid == parsedClassId)
                    .Select(s => new { s.Studentid, s.Name, s.StuCode })
                    .ToListAsync();

                if (!studentsInClass.Any())
                    return Ok(new
                    {
                        id = classObj.Classid,
                        name = classObj.Name ?? "نامشخص",
                        grade = classObj.Grade ?? "نامشخص",
                        capacity = classObj.Capacity,
                        totalStudents = 0,
                        avgScore = 0.0,
                        passPercentage = 0,
                        scoreRanges = new List<object>(),
                        subjectScores = new List<object>(),
                        topPerformers = new List<object>(),
                    });

                // Get all scores for these students in this class
                var studentIds = studentsInClass.Select(s => s.Studentid).ToList();

                var allScores = await _context.Scores
                    .Where(s => studentIds.Contains(s.Studentid ?? 0) && s.Classid == parsedClassId)
                    .Include(s => s.Course)
                    .ToListAsync();

                Console.WriteLine($"[DEBUG] Class: {parsedClassId}, Students: {studentsInClass.Count}, Scores: {allScores.Count}");

                if (!allScores.Any())
                {
                    return Ok(new
                    {
                        id = classObj.Classid,
                        name = classObj.Name ?? "نامشخص",
                        grade = classObj.Grade ?? "نامشخص",
                        capacity = classObj.Capacity,
                        totalStudents = studentsInClass.Count,
                        avgScore = 0.0,
                        passPercentage = 0,
                        scoreRanges = new List<object>
                        {
                            new { range = "18-20", count = 0, percentage = 0 },
                            new { range = "16-18", count = 0, percentage = 0 },
                            new { range = "14-16", count = 0, percentage = 0 },
                            new { range = "12-14", count = 0, percentage = 0 },
                            new { range = "<12", count = 0, percentage = 0 },
                        },
                        subjectScores = new List<object>(),
                        topPerformers = new List<object>(),
                    });
                }

                // Calculate statistics
                double avgScore = allScores.Average(s => (double)s.ScoreValue);
                int passCount = allScores.Count(s => s.ScoreValue >= 12);
                int passPercentage = (int)System.Math.Round((double)passCount / allScores.Count * 100);

                // Score ranges
                var scoreRanges = new List<ScoreRangeDto>
                {
                    new ScoreRangeDto { Range = "18-20", Count = allScores.Count(s => s.ScoreValue >= 18) },
                    new ScoreRangeDto { Range = "16-18", Count = allScores.Count(s => s.ScoreValue >= 16 && s.ScoreValue < 18) },
                    new ScoreRangeDto { Range = "14-16", Count = allScores.Count(s => s.ScoreValue >= 14 && s.ScoreValue < 16) },
                    new ScoreRangeDto { Range = "12-14", Count = allScores.Count(s => s.ScoreValue >= 12 && s.ScoreValue < 14) },
                    new ScoreRangeDto { Range = "<12", Count = allScores.Count(s => s.ScoreValue < 12) },
                };

                int totalScores = allScores.Count;
                foreach (var range in scoreRanges)
                {
                    range.Percentage = (int)System.Math.Round((double)range.Count / totalScores * 100);
                }

                // Subject scores
                var subjectScores = allScores
                    .GroupBy(s => s.Course != null ? s.Course.Name : "نامشخص")
                    .Select(g => new
                    {
                        name = g.Key,
                        avgScore = System.Math.Round(g.Average(s => (double)s.ScoreValue), 1),
                        totalCount = g.Count(),
                    })
                    .OrderByDescending(s => s.avgScore)
                    .ToList();

                // Group by Studentid and calculate average
                var groupedScores = allScores
                    .GroupBy(s => s.Studentid ?? 0)
                    .Select(g => new
                    {
                        studentId = g.Key,
                        avgScore = System.Math.Round(g.Average(s => (double)s.ScoreValue), 2),
                    })
                    .OrderByDescending(s => s.avgScore)
                    .Take(3)
                    .ToList();

                Console.WriteLine($"[DEBUG] Grouped Scores: {groupedScores.Count}");
                foreach (var gs in groupedScores)
                {
                    Console.WriteLine($"[DEBUG] StudentId: {gs.studentId}, AvgScore: {gs.avgScore}");
                }

                var topPerformers = new List<object>();
                int rank = 1;

                foreach (var perf in groupedScores)
                {
                    // Find student in our list
                    var studentInfo = studentsInClass.FirstOrDefault(s => s.Studentid == perf.studentId);
                    var studentName = studentInfo?.Name ?? "نامشخص";

                    Console.WriteLine($"[DEBUG] Rank {rank}: StudentId={perf.studentId}, Name={studentName}");

                    topPerformers.Add(new
                    {
                        studentId = perf.studentId,
                        studentName = studentName,
                        stuCode = studentInfo?.StuCode ?? "نامشخص",
                        avgScore = perf.avgScore,
                        rank = rank,
                    });
                    rank++;
                }

                return Ok(new
                {
                    id = classObj.Classid,
                    name = classObj.Name ?? "نامشخص",
                    grade = classObj.Grade ?? "نامشخص",
                    capacity = classObj.Capacity,
                    totalStudents = studentsInClass.Count,
                    avgScore = System.Math.Round(avgScore, 1),
                    passPercentage = passPercentage,
                    scoreRanges = scoreRanges,
                    subjectScores = subjectScores,
                    topPerformers = topPerformers,
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[GET CLASS STATISTICS] Error: {ex.Message}");
                Console.WriteLine($"[GET CLASS STATISTICS] StackTrace: {ex.StackTrace}");
                return StatusCode(500, new { message = "خطای سرور", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Get monthly trend for a class
        // ──────────────────────────────────────────────────────────────
        [HttpGet("class/{classId}/monthly-trend")]
        public async Task<IActionResult> GetMonthlyTrend(string classId)
        {
            try
            {
                if (!long.TryParse(classId, out long parsedClassId))
                {
                    return BadRequest(new { message = "شناسه کلاس نامعتبر است" });
                }

                var monthlyData = await _context.Scores
                    .Where(s => s.Classid == parsedClassId)
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
                Console.WriteLine($"[GET MONTHLY TREND] Error: {ex.Message}");
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
        public async Task<IActionResult> GetClassStudents(string classId)
        {
            try
            {
                if (!long.TryParse(classId, out long parsedClassId))
                {
                    return BadRequest(new { message = "شناسه کلاس نامعتبر است" });
                }

                var students = await _context.Students
                    .Where(s => s.Classeid == parsedClassId)
                    .Select(s => new
                    {
                        id = s.Studentid,
                        name = s.Name,
                        stuCode = s.StuCode,
                        avgScore = System.Math.Round(
                            _context.Scores
                                .Where(sc => sc.Studentid == s.Studentid && sc.Classid == parsedClassId)
                                .Average(sc => (double?)sc.ScoreValue) ?? 0, 1
                        ),
                        scoreCount = _context.Scores
                            .Count(sc => sc.Studentid == s.Studentid && sc.Classid == parsedClassId),
                    })
                    .OrderByDescending(s => s.avgScore)
                    .ToListAsync();

                return Ok(students);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[GET CLASS STUDENTS] Error: {ex.Message}");
                return StatusCode(500, new { message = "خطا در دریافت دانش‌آموزان", error = ex.Message });
            }
        }

//        // ──────────────────────────────────────────────────────────────
//        // Get all students with pagination
//        // ──────────────────────────────────────────────────────────────
//        [HttpGet("students")]
//        public async Task<IActionResult> GetAllStudents(
//            [FromQuery] int page = 1,
//            [FromQuery] int pageSize = 50)
//        {
//            try
//            {
//                var skip = (page - 1) * pageSize;
//
//                var students = await _context.Students
//                    .Skip(skip)
//                    .Take(pageSize)
//                    .Select(s => new
//                    {
//                        id = s.Studentid,
//                        name = s.Name ?? "نامشخص",
//                        studentCode = s.StuCode,
//                        classs = s.Classeid,
//                        phone = s.ParentNum1,
//                        parentPhone = s.ParentNum2,
//                        birthDate = s.Birthdate,
//                        address = s.Address,
//                        debt = s.Debt ?? 0,
//                        registerDate = s.Registerdate,
//                        userId = s.UserID,
//                    })
//                    .OrderByDescending(s => s.registerDate)
//                    .ToListAsync();
//
//                //  RETURN ARRAY DIRECTLY - NOT wrapped in pagination object
//                return Ok(students);
//            }
//            catch (Exception ex)
//            {
//                return StatusCode(500, new { message = "خطا در دریافت دانش‌آموزان", error = ex.Message });
//            }
//        }

        // ──────────────────────────────────────────────────────────────
        // Alternative: If you want pagination info, use different endpoint
        // ──────────────────────────────────────────────────────────────
        [HttpGet("students/paginated")]
        public async Task<IActionResult> GetAllStudentsPaginated(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 50)
        {
            try
            {
                var skip = (page - 1) * pageSize;

                var students = await _context.Students
                    .Skip(skip)
                    .Take(pageSize)
                    .Select(s => new
                    {
                        id = s.Studentid,
                        name = s.Name ?? "نامشخص",
                        studentCode = s.StuCode,
                        classs = s.Classeid,
                        phone = s.ParentNum1,
                        parentPhone = s.ParentNum2,
                        birthDate = s.Birthdate,
                        address = s.Address,
                        debt = s.Debt ?? 0,
                        registerDate = s.Registerdate,
                        userId = s.UserID,
                    })
                    .OrderByDescending(s => s.registerDate)
                    .ToListAsync();

                var totalCount = await _context.Students.CountAsync();

                return Ok(new
                {
                    data = students,  // Array of students
                    pagination = new
                    {
                        page,
                        pageSize,
                        totalCount,
                        totalPages = (totalCount + pageSize - 1) / pageSize,
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "خطا در دریافت دانش‌آموزان", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Get student by ID
        // ──────────────────────────────────────────────────────────────
        [HttpGet("students/{studentId}")]
        public async Task<IActionResult> GetStudentById(long studentId)
        {
            try
            {
                var student = await _context.Students.FindAsync(studentId);

                if (student == null)
                    return NotFound(new { message = "دانش‌آموز یافت نشد" });

                return Ok(new
                {
                    id = student.Studentid,
                    name = student.Name,
                    studentCode = student.StuCode,
                    classs = student.Classeid,
                    phone = student.ParentNum1,
                    parentPhone = student.ParentNum2,
                    birthDate = student.Birthdate,
                    address = student.Address,
                    debt = student.Debt ?? 0,
                    registerDate = student.Registerdate,
                    userId = student.UserID,
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "خطا در دریافت اطلاعات", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Get all students with user data
        // ──────────────────────────────────────────────────────────────
        [HttpGet("students")]
        public async Task<IActionResult> GetAllStudents(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 50)
        {
            try
            {
                var skip = (page - 1) * pageSize;

                var students = await _context.Students
                    .Skip(skip)
                    .Take(pageSize)
                    .Select(s => new
                    {
                        id = s.Studentid,
                        name = s.Name ?? "نامشخص",
                        studentCode = s.StuCode,
                        classs = s.Classeid,
                        phone = s.ParentNum1,
                        parentPhone = s.ParentNum2,
                        birthDate = s.Birthdate,
                        address = s.Address,
                        debt = s.Debt ?? 0,
                        registerDate = s.Registerdate,
                        userId = s.UserID,
                        // Get username and password from User table
                        username = _context.Users
                            .Where(u => u.Userid == s.UserID)
                            .Select(u => u.Username)
                            .FirstOrDefault(),
                        password = _context.Users
                            .Where(u => u.Userid == s.UserID)
                            .Select(u => u.Password)
                            .FirstOrDefault()
                    })
                    .OrderByDescending(s => s.registerDate)
                    .ToListAsync();

                return Ok(students);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "خطا در دریافت دانش‌آموزان", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Create new student with user account
        // ──────────────────────────────────────────────────────────────
        [HttpPost("students")]
        public async Task<IActionResult> CreateStudent([FromBody] CreateStudentDto model)
        {
            try
            {
                if (string.IsNullOrEmpty(model.Name) || string.IsNullOrEmpty(model.StudentCode))
                    return BadRequest(new { message = "نام و کد دانش‌آموز الزامی است" });

                long? classId = null;
                if (!string.IsNullOrEmpty(model.ClassId) &&
                    long.TryParse(model.ClassId, out var parsedClassId))
                {
                    classId = parsedClassId;
                }

                // Check if student code already exists
                var existingStudent = await _context.Students
                    .FirstOrDefaultAsync(s => s.StuCode == model.StudentCode);

                if (existingStudent != null)
                    return BadRequest(new { message = "این کد دانش‌آموز قبلا ثبت شده است" });

                // CREATE USER ACCOUNT
                var username = model.StudentCode; // Use student code as username
                var password = model.StudentCode; // Default password = student code

                // Check if username already exists
                var existingUser = await _context.Users
                    .FirstOrDefaultAsync(u => u.Username == username);

                if (existingUser != null)
                    return BadRequest(new { message = "نام کاربری قبلا استفاده شده است" });

                // Create user
                var user = new User
                {
                    Username = username,
                    Password = password,
                    Role = "student"
                };

                _context.Users.Add(user);
                await _context.SaveChangesAsync();

                Console.WriteLine($"[CREATE STUDENT] User created: {user.Userid} - {user.Username}");

                // Create student with user ID
                var student = new Student
                {
                    Name = model.Name,
                    StuCode = model.StudentCode,
                    Classeid = classId,
                    ParentNum1 = model.Phone,
                    ParentNum2 = model.ParentPhone,
                    Address = model.Address,
                    Debt = model.Debt,
                    Registerdate = DateTime.Now.ToShamsi(),
                    Birthdate = model.BirthDate,
                    UserID = user.Userid //LINK USER TO STUDENT
                };

                _context.Students.Add(student);
                await _context.SaveChangesAsync();

                Console.WriteLine($"[CREATE STUDENT] New student created: {student.Studentid}");

                return Ok(new
                {
                    message = "دانش‌آموز با موفقیت ایجاد شد",
                    id = student.Studentid,
                    name = student.Name,
                    userId = user.Userid,
                    username = user.Username,
                    password = user.Password // Return so manager knows initial credentials
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[CREATE STUDENT] Error: {ex.Message}");
                return StatusCode(500, new { message = "خطا در ایجاد دانش‌آموز", error = ex.Message });
            }
        }


        // ──────────────────────────────────────────────────────────────
        // Update student
        // ──────────────────────────────────────────────────────────────
        [HttpPut("students/{studentId}")]
        public async Task<IActionResult> UpdateStudent(
            long studentId,
            [FromBody] UpdateStudentDto model)
        {
            try
            {
                var student = await _context.Students.FindAsync(studentId);

                if (student == null)
                    return NotFound(new { message = "دانش‌آموز یافت نشد" });

                // Check if new code is unique (if changed)
                if (!string.IsNullOrEmpty(model.StudentCode) && model.StudentCode != student.StuCode)
                {
                    var existingStudent = await _context.Students
                        .FirstOrDefaultAsync(s => s.StuCode == model.StudentCode);

                    if (existingStudent != null)
                        return BadRequest(new { message = "این کد دانش‌آموز قبلا ثبت شده است" });
                }

                if (!string.IsNullOrEmpty(model.ClassId))
                {
                    if (long.TryParse(model.ClassId, out var parsedClassId))
                    {
                        student.Classeid = parsedClassId;
                    }
                }

                // Update fields
                if (!string.IsNullOrEmpty(model.Name))
                    student.Name = model.Name;
                if (!string.IsNullOrEmpty(model.StudentCode))
                    student.StuCode = model.StudentCode;
                if (!string.IsNullOrEmpty(model.Phone))
                    student.ParentNum1 = model.Phone;
                if (!string.IsNullOrEmpty(model.ParentPhone))
                    student.ParentNum2 = model.ParentPhone;
                if (!string.IsNullOrEmpty(model.Address))
                    student.Address = model.Address;
                if (model.Debt.HasValue)
                    student.Debt = model.Debt;
                if (!string.IsNullOrEmpty(model.BirthDate))
                    student.Birthdate = model.BirthDate;

                _context.Students.Update(student);
                await _context.SaveChangesAsync();

                Console.WriteLine($"[UPDATE STUDENT] Student updated: {studentId}");

                return Ok(new
                {
                    message = "دانش‌آموز با موفقیت به‌روزرسانی شد",
                    id = student.Studentid,
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[UPDATE STUDENT] Error: {ex.Message}");
                return StatusCode(500, new { message = "خطا در به‌روزرسانی", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Delete student
        // ──────────────────────────────────────────────────────────────
        [HttpDelete("students/{studentId}/{userId}")]
        public async Task<IActionResult> DeleteStudent(long studentId, long userId)
        {
            try
            {
                var student = await _context.Students.FindAsync(studentId);
                var user = await _context.Users.FindAsync(student.UserID);

                if (student == null)
                    return NotFound(new { message = "دانش‌آموز یافت نشد" });

                _context.Students.Remove(student);
                _context.Users.Remove(user);
                await _context.SaveChangesAsync();

                Console.WriteLine($"[DELETE STUDENT] Student deleted: {studentId}");

                return Ok(new { message = "دانش‌آموز با موفقیت حذف شد" });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[DELETE STUDENT] Error: {ex.Message}");
                return StatusCode(500, new { message = "خطا در حذف دانش‌آموز", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Search students
        // ──────────────────────────────────────────────────────────────
        [HttpGet("students/search")]
        public async Task<IActionResult> SearchStudents([FromQuery] string query)
        {
            try
            {
                if (string.IsNullOrEmpty(query))
                    return await GetAllStudents();

                var students = await _context.Students
                    .Where(s =>
                        s.Name.Contains(query) ||
                        s.StuCode.Contains(query) ||
                        s.ParentNum1.Contains(query))
                    .Select(s => new
                    {
                        id = s.Studentid,
                        name = s.Name,
                        studentCode = s.StuCode,
                        classs = s.Classeid,
                        phone = s.ParentNum1,
                        parentPhone = s.ParentNum2,
                        birthDate = s.Birthdate,
                        address = s.Address,
                        debt = s.Debt ?? 0,
                        registerDate = s.Registerdate,
                    })
                    .ToListAsync();

                return Ok(students);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "خطا در جستجو", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Get student statistics
        // ──────────────────────────────────────────────────────────────
        [HttpGet("students-stats")]
        public async Task<IActionResult> GetStudentStats()
        {
            try
            {
                var totalStudents = await _context.Students.CountAsync();
                var studentsWithDebt = await _context.Students
                    .Where(s => s.Debt > 0)
                    .CountAsync();
                var totalDebt = await _context.Students
                    .SumAsync(s => s.Debt ?? 0);

                return Ok(new
                {
                    totalStudents,
                    studentsWithDebt,
                    studentsWithoutDebt = totalStudents - studentsWithDebt,
                    totalDebt,
                    avgDebt = totalStudents > 0 ? totalDebt / totalStudents : 0,
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "خطا در دریافت آمار", error = ex.Message });
            }
        }

        // ──────────────────────────────────────────────────────────────
        // Bulk delete students
        // ──────────────────────────────────────────────────────────────
        [HttpPost("students/bulk-delete")]
        public async Task<IActionResult> BulkDeleteStudents([FromBody] List<long> studentIds)
        {
            try
            {
                var students = await _context.Students
                    .Where(s => studentIds.Contains(s.Studentid))
                    .ToListAsync();

                if (!students.Any())
                    return NotFound(new { message = "دانش‌آموزی یافت نشد" });

                _context.Students.RemoveRange(students);
                await _context.SaveChangesAsync();

                return Ok(new
                {
                    message = $"{students.Count} دانش‌آموز با موفقیت حذف شدند",
                    deletedCount = students.Count,
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "خطا در حذف", error = ex.Message });
            }
        }

    }

    public class ScoreRangeDto
    {
        public string Range { get; set; }
        public int Count { get; set; }
        public int Percentage { get; set; }
    }

    public static class DateTimeExtensions
    {
        public static string ToShamsi(this DateTime date)
        {
            var pc = new System.Globalization.PersianCalendar();
            return $"{pc.GetYear(date)}-{pc.GetMonth(date):D2}-{pc.GetDayOfMonth(date):D2}";
        }
    }

    // ──────────────────────────────────────────────────────────────
    // DTOs
    // ──────────────────────────────────────────────────────────────
    public class CreateStudentDto
    {
        public string Name { get; set; } = null!;
        public string StudentCode { get; set; } = null!;
        public string? ClassId { get; set; }
        public string Phone { get; set; } = null!;
        public string ParentPhone { get; set; } = null!;
        public string BirthDate { get; set; } = null!;
        public string Address { get; set; } = null!;
        public long Debt { get; set; } = 0;
    }

    public class UpdateStudentDto
    {
        public string? Name { get; set; }
        public string? StudentCode { get; set; }
        public string? ClassId { get; set; }
        public string? Phone { get; set; }
        public string? ParentPhone { get; set; }
        public string? BirthDate { get; set; }
        public string? Address { get; set; }
        public long? Debt { get; set; }
    }
}

