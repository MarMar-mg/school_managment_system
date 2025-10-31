using System.ComponentModel.DataAnnotations;

namespace SchoolPortalAPI.Models
{
    public class Equipment
    {
        [Key]
        public long Equipmentid { get; set; }

        public string Eqcode { get; set; } = null!;
        public string? Eqcatry { get; set; }
        public string? Location { get; set; }
    }
}