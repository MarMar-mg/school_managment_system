using System.ComponentModel.DataAnnotations;

namespace SchoolPortalAPI.Models
{
    public class Teacher
    {
        [Key]
        public long Teacherid { get; set; }

        public string Name { get; set; } = null!;
        public long? Userid { get; set; }
        public long? Courseid { get; set; }
    }
}