using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SchoolPortalAPI.Models
{
    public class Course
    {
        [Key]
        public long Courseid { get; set; }

        public string? Name { get; set; }
        public string? Finalexamdate { get; set; }
        public string? Classtime { get; set; }
        public long? Classid { get; set; }
        public long? Teacherid { get; set; }
        public string? Code { get; set; }
        public string? Location { get; set; }
        public string? Time { get; set; }

        [ForeignKey("Classid")]
        public virtual Class? Class { get; set; }

        [ForeignKey("Teacherid")]
        public virtual Teacher? Teacher { get; set; }
    }
}