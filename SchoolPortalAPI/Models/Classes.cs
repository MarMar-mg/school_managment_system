using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SchoolPortalAPI.Models
{
    [Table("Classes")]
    public class Class
    {
        [Key]
        public long Classid { get; set; }
        public string? Name { get; set; }
        public int Capacity { get; set; }
public string? Grade { get; set; }
    }
}