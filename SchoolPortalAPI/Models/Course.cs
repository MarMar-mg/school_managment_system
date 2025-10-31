using System.ComponentModel.DataAnnotations;

namespace SchoolPortalAPI.Models
{
    public class Course
    {
        [Key]
        public long Courseid { get; set; }

        public string Name { get; set; } = null!;
        public string? Finalexamdate { get; set; }
        public string? Classtime { get; set; }
        public long? Classid { get; set; }
        public long? Teacherid { get; set; }
    }
}