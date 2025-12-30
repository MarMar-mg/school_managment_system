// Models/Score.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using SchoolPortalAPI.Models;

namespace SchoolPortalAPI.Models
{
    public class Score
    {
        [Key]
        public long Id { get; set; }

        public long ScoreValue { get; set; }
        public string Score_month { get; set; } = null!;

        // Keep StuCode for backward compatibility
        [Column("StuCode")]
        public string? StuCode { get; set; }

        // Add Studentid as proper foreign key
        public long? Studentid { get; set; }

        public long? Courseid { get; set; }
        public long? Classid { get; set; }

        // Navigation properties
        [ForeignKey("Studentid")]
        public virtual Student? Student { get; set; }

        [ForeignKey("Courseid")]
        public virtual Course? Course { get; set; }

        [ForeignKey("Classid")]
        public virtual Class? Class { get; set; }
    }
}