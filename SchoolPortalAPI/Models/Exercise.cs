using System.ComponentModel.DataAnnotations;

namespace SchoolPortalAPI.Models
{
    public class Exercise
    {
        [Key]
        public long Exerciseid { get; set; }

        public string Title { get; set; } = null!;
        public string? Image { get; set; }
        public string? Startdate { get; set; }
        public string? Enddate { get; set; }
        public string? Starttime { get; set; }
        public string? Endtime { get; set; }
        public long Courseid { get; set; }
        public string? Description { get; set; }
        public long? Classid { get; set; }
        public string? Filename { get; set; }
    }
}