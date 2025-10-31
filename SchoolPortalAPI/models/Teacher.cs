public class Teacher
{
    required public long TeacherId { get; set; }
    required public string Name { get; set; }
    required public long? UserId { get; set; }
    required public long? CourseId { get; set; }
}