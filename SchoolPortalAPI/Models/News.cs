using System.ComponentModel.DataAnnotations;

namespace SchoolPortalAPI.Models
{
    public class News
    {
        [Key]
        public long Newsid { get; set; }

        public string Title { get; set; } = null!;
        public string Category { get; set; } = null!;
        public string Startdate { get; set; } = null!;
        public string Enddate { get; set; } = null!;
        public string? Description { get; set; }
        public string? Image { get; set; }
    }
}