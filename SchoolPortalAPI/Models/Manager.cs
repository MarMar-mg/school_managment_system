using System.ComponentModel.DataAnnotations;

namespace SchoolPortalAPI.Models
{
    public class Manager
    {
        [Key]
        public long Assistantid { get; set; }

        public long Userid { get; set; }
        public string Name { get; set; } = null!;
    }
}