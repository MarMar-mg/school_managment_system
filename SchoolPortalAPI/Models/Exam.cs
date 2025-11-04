using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SchoolPortalAPI.Models
{
    // Models/Exam.cs
    public class Exam
    {
        [Key]
        public long Examid { get; set; }

        public string Title { get; set; } = null!;
        public string? Description { get; set; }
        public string Enddate { get; set; } = null!;
        public string Starttime { get; set; } = null!;
        public string Endtime { get; set; } = null!;

        public long? Courseid { get; set; }
        public long? Classid { get; set; }  // مهم

        [ForeignKey("Courseid")]
        public virtual Course? Course { get; set; }

        [ForeignKey("Classid")]
        public virtual Class? Class { get; set; }
    }
}