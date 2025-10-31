public class Exercise
{
    required public long ExerciseId { get; set; }
    required public string Title { get; set; }
    required public string Image { get; set; }
    required public string StartDate { get; set; }
    required public string EndDate { get; set; }
    required public string StartTime { get; set; }
    required public string EndTime { get; set; }
    required public long CourseId { get; set; }
    required public string Description { get; set; }
    required public long? ClassId { get; set; }
    required public string FileName { get; set; }
}