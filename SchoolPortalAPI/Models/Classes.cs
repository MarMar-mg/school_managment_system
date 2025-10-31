using System.ComponentModel.DataAnnotations;

namespace SchoolPortalAPI.Models
{
    public class Classes
    {
        [Key]
        public long Classid { get; set; }

        public string Name { get; set; } = null!;
        public int Capacity { get; set; }
        public string Grade { get; set; } = null!;
    }
}