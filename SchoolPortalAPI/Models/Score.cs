using System.ComponentModel.DataAnnotations;

namespace SchoolPortalAPI.Models
{
    public class Score
    {
        [Key]
        public long Id { get; set; }

        public long ScoreValue { get; set; }
        public string Score_month { get; set; } = null!;
        public long? Classid { get; set; }
        public string? Name { get; set; }
        public string? StuCode { get; set; }
        public long? Courseid { get; set; }
    }
}