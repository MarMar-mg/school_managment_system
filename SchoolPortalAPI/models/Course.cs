public class Course
{
    required public long CourseId { get; set; }
    required public string Name { get; set; }
    required public string FinalExamDate { get; set; }
    required public string ClassTime { get; set; }
    required public long? ClassId { get; set; }
    required public long TeacherId { get; set; }
}