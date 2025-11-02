using System.ComponentModel.DataAnnotations;

namespace SchoolPortalAPI.Models
{
    // Models/Exercise.cs
    public class Exercise
    {
        [Key]
        public long Exerciseid { get; set; }

        public string Title { get; set; } = null!;
        public string? Description { get; set; }
        public string Duedate { get; set; } = null!;

        public long? Courseid { get; set; }
        public long? Classid { get; set; }  // مهم

        [ForeignKey("Courseid")]
        public virtual Course? Course { get; set; }

        [ForeignKey("Classid")]
        public virtual Class? Class { get; set; }
    }
}