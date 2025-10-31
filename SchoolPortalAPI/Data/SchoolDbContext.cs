using Microsoft.EntityFrameworkCore;

public class SchoolDbContext : DbContext
{
    public SchoolDbContext(DbContextOptions<SchoolDbContext> options) : base(options) { }

    public DbSet<User> Users { get; set; }
    public DbSet<Student> Students { get; set; }
    public DbSet<Teacher> Teachers { get; set; }
    public DbSet<Course> Courses { get; set; }
    public DbSet<Classes> Classes { get; set; }
    public DbSet<Exercise> Exercises { get; set; }
    public DbSet<Exam> Exams { get; set; }
    public DbSet<News> News { get; set; }
    public DbSet<CalendarEvent> CalendarEvents { get; set; }
    public DbSet<Score> Scores { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Map table names and columns to match your database
        modelBuilder.Entity<User>().ToTable("users");
        modelBuilder.Entity<User>().HasKey(u => u.UserId);
        modelBuilder.Entity<User>().Property(u => u.UserId).HasColumnName("userid");
        modelBuilder.Entity<User>().Property(u => u.Username).HasColumnName("username");
        modelBuilder.Entity<User>().Property(u => u.Password).HasColumnName("password");
        modelBuilder.Entity<User>().Property(u => u.Role).HasColumnName("role");

        modelBuilder.Entity<Student>().ToTable("student");
        modelBuilder.Entity<Student>().HasKey(s => s.StudentId);
        modelBuilder.Entity<Student>().Property(s => s.StudentId).HasColumnName("studentid");
        modelBuilder.Entity<Student>().Property(s => s.Name).HasColumnName("name");
        modelBuilder.Entity<Student>().Property(s => s.Score).HasColumnName("score");
        modelBuilder.Entity<Student>().Property(s => s.Address).HasColumnName("address");
        modelBuilder.Entity<Student>().Property(s => s.Birthdate).HasColumnName("birthdate");
        modelBuilder.Entity<Student>().Property(s => s.Registerdate).HasColumnName("registerdate");
        modelBuilder.Entity<Student>().Property(s => s.ParentNum1).HasColumnName("parentNum1");
        modelBuilder.Entity<Student>().Property(s => s.ParentNum2).HasColumnName("parentNum2");
        modelBuilder.Entity<Student>().Property(s => s.Debt).HasColumnName("debt");
        modelBuilder.Entity<Student>().Property(s => s.StuCode).HasColumnName("stuCode");
        modelBuilder.Entity<Student>().Property(s => s.UserID).HasColumnName("userID");
        modelBuilder.Entity<Student>().Property(s => s.Classeid).HasColumnName("classeid");
        modelBuilder.Entity<Student>().Property(s => s.Score_month).HasColumnName("score_month");

        modelBuilder.Entity<Teacher>().ToTable("teacher");
        modelBuilder.Entity<Teacher>().HasKey(t => t.TeacherId);
        modelBuilder.Entity<Teacher>().Property(t => t.TeacherId).HasColumnName("teacherid");
        modelBuilder.Entity<Teacher>().Property(t => t.Name).HasColumnName("name");
        modelBuilder.Entity<Teacher>().Property(t => t.UserId).HasColumnName("userid");
        modelBuilder.Entity<Teacher>().Property(t => t.CourseId).HasColumnName("courseid");

        modelBuilder.Entity<Course>().ToTable("course");
        modelBuilder.Entity<Course>().HasKey(c => c.CourseId);
        modelBuilder.Entity<Course>().Property(c => c.CourseId).HasColumnName("courseid");
        modelBuilder.Entity<Course>().Property(c => c.Name).HasColumnName("name");
        modelBuilder.Entity<Course>().Property(c => c.FinalExamDate).HasColumnName("finalexamdate");
        modelBuilder.Entity<Course>().Property(c => c.ClassTime).HasColumnName("classtime");
        modelBuilder.Entity<Course>().Property(c => c.ClassId).HasColumnName("classid");
        modelBuilder.Entity<Course>().Property(c => c.TeacherId).HasColumnName("teacherid");

        modelBuilder.Entity<Classes>().ToTable("classes");
        modelBuilder.Entity<Classes>().HasKey(c => c.ClassId);
        modelBuilder.Entity<Classes>().Property(c => c.ClassId).HasColumnName("classid");
        modelBuilder.Entity<Classes>().Property(c => c.Name).HasColumnName("name");
        modelBuilder.Entity<Classes>().Property(c => c.Capacity).HasColumnName("capacity");
        modelBuilder.Entity<Classes>().Property(c => c.Grade).HasColumnName("grade");

        modelBuilder.Entity<Exercise>().ToTable("exercise");
        modelBuilder.Entity<Exercise>().HasKey(e => e.ExerciseId);
        modelBuilder.Entity<Exercise>().Property(e => e.ExerciseId).HasColumnName("exerciseid");
        modelBuilder.Entity<Exercise>().Property(e => e.Title).HasColumnName("title");
        modelBuilder.Entity<Exercise>().Property(e => e.Image).HasColumnName("image");
        modelBuilder.Entity<Exercise>().Property(e => e.StartDate).HasColumnName("startdate");
        modelBuilder.Entity<Exercise>().Property(e => e.EndDate).HasColumnName("enddate");
        modelBuilder.Entity<Exercise>().Property(e => e.StartTime).HasColumnName("starttime");
        modelBuilder.Entity<Exercise>().Property(e => e.EndTime).HasColumnName("endtime");
        modelBuilder.Entity<Exercise>().Property(e => e.CourseId).HasColumnName("courseid");
        modelBuilder.Entity<Exercise>().Property(e => e.Description).HasColumnName("description");
        modelBuilder.Entity<Exercise>().Property(e => e.ClassId).HasColumnName("classid");
        modelBuilder.Entity<Exercise>().Property(e => e.FileName).HasColumnName("filename");

        modelBuilder.Entity<Exam>().ToTable("exam");
        modelBuilder.Entity<Exam>().HasKey(e => e.ExamId);
        modelBuilder.Entity<Exam>().Property(e => e.ExamId).HasColumnName("examid");

        modelBuilder.Entity<News>().ToTable("news");
        modelBuilder.Entity<News>().HasKey(n => n.NewsId);
        modelBuilder.Entity<News>().Property(n => n.NewsId).HasColumnName("newsid");

        modelBuilder.Entity<CalendarEvent>().ToTable("calender");
        modelBuilder.Entity<CalendarEvent>().HasKey(c => c.EventId);
        modelBuilder.Entity<CalendarEvent>().Property(c => c.EventId).HasColumnName("eventid");

        modelBuilder.Entity<Score>().ToTable("score");
        modelBuilder.Entity<Score>().HasKey(s => s.Id);
        modelBuilder.Entity<Score>().Property(s => s.Id).HasColumnName("id");
        modelBuilder.Entity<Score>().Property(s => s.ScoreValue).HasColumnName("score");
        modelBuilder.Entity<Score>().Property(s => s.Score_month).HasColumnName("score_month");
    }
}