using System.ComponentModel.DataAnnotations;

namespace SchoolPortalAPI.Models
{
    public class Calender
    {
        [Key]
        public long Eventid { get; set; }

        public string Title { get; set; } = null!;
        public string Date { get; set; } = null!;
        public string? Description { get; set; }
    }
}