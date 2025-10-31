public class Score
{
    required public long Id { get; set; }
    required public long ScoreValue { get; set; }
    required public string Score_month { get; set; }
    required public long? ClassId { get; set; }
    required public string Name { get; set; }
    required public string StuCode { get; set; }
    required public long? CourseId { get; set; }
}