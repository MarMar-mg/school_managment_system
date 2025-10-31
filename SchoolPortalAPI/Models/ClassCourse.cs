using System.ComponentModel.DataAnnotations;

namespace SchoolPortalAPI.Models
{
    public class ClassCourse
    {
        [Key]
        public long Classcourseid { get; set; }

        public long Courseid { get; set; }
    }
}