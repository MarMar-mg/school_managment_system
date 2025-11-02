using System.ComponentModel.DataAnnotations;

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
    }
}