// Models/ExamStuTeach.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SchoolPortalAPI.Models
{
    public class ExamStuTeach
    {
        [Key]
        public long Estid { get; set; }

        public int? Score { get; set; }
        public string? Answerimage { get; set; }
        public long Examid { get; set; }
        public long Courseid { get; set; }
        public long Teacherid { get; set; }
        public string? Date { get; set; }
        public long? Studentid { get; set; }
        public string? Description { get; set; }
        public string? Filename { get; set; }

        // NAVIGATION PROPERTIES
        [ForeignKey("Examid")]
        public virtual Exam Exam { get; set; } = null!;

        [ForeignKey("Courseid")]
        public virtual Course Course { get; set; } = null!;

        [ForeignKey("Teacherid")]
        public virtual Teacher Teacher { get; set; } = null!;

        [ForeignKey("Studentid")]
        public virtual Student Student { get; set; } = null!;
    }
}