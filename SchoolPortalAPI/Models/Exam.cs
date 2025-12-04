using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SchoolPortalAPI.Models
{
    public class Exam
    {
        [Key]
        public long Examid { get; set; }

        public string? Title { get; set; }
        public string? Description { get; set; }
        public string? Enddate { get; set; }  // Consider using DateTime? for better handling
        public string? Startdate { get; set; }
        public string? Starttime { get; set; }
        public string? Endtime { get; set; }

        public string? Filename { get; set; }
        public string? File { get; set; }

        public int? Capacity { get; set; }
        public int? Duration { get; set; }      // (in minutes)
        public int? PossibleScore { get; set; } // (max score)

        public long? Courseid { get; set; }
        public long? Classid { get; set; }

        [ForeignKey("Courseid")]
        public virtual Course? Course { get; set; }

        [ForeignKey("Classid")]
        public virtual Class? Class { get; set; }

        public virtual ICollection<ExamStuTeach> ExamStuTeachs { get; set; } = new List<ExamStuTeach>();
    }
}