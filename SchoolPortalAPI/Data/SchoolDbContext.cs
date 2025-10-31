using Microsoft.EntityFrameworkCore;
using SchoolPortalAPI.Models;

namespace SchoolPortalAPI.Data
{
    public class SchoolDbContext : DbContext
    {
        public SchoolDbContext(DbContextOptions<SchoolDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; } = null!;
        public DbSet<Classes> Classes { get; set; } = null!;
        public DbSet<Course> Courses { get; set; } = null!;
        public DbSet<Teacher> Teachers { get; set; } = null!;
        public DbSet<Student> Students { get; set; } = null!;
        public DbSet<Manager> Managers { get; set; } = null!;
        public DbSet<Calender> Calendars { get; set; } = null!;
        public DbSet<News> News { get; set; } = null!;
        public DbSet<Exercise> Exercises { get; set; } = null!;
        public DbSet<Exam> Exams { get; set; } = null!;
        public DbSet<Equipment> Equipment { get; set; } = null!;
        public DbSet<ClassCourse> ClassCourses { get; set; } = null!;
        public DbSet<ExamStuTeach> ExamStuTeaches { get; set; } = null!;
        public DbSet<ExerciseStuTeach> ExerciseStuTeaches { get; set; } = null!;
        public DbSet<Score> Scores { get; set; } = null!;
    }
}