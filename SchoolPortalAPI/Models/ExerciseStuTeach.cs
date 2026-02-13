using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SchoolPortalAPI.Models
{
    public class ExerciseStuTeach
    {
        [Key]
        public long Exstid { get; set; }

        public int? Score { get; set; }
        public string? Answerimage { get; set; }
        public long Exerciseid { get; set; }
        public long Courseid { get; set; }
        public long Teacherid { get; set; }
        public long? Studentid { get; set; }
        public string? Description { get; set; }
        public string? Date { get; set; }
        public string? Time { get; set; }
        public string? Filename { get; set; }

        [ForeignKey(nameof(Exerciseid))]
        public virtual Exercise? Exercise { get; set; }

    }
}