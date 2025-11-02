using System.ComponentModel.DataAnnotations;

namespace SchoolPortalAPI.Models
{
    public class Calender
    {
        [Key]
        public long Eventid { get; set; }

        public string Title { get; set; } = null!;
        public long Date { get; set; }
        public string? Description { get; set; }
    }
}