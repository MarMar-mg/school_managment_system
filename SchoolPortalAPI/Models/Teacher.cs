using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SchoolPortalAPI.Models
{
    public class Teacher
    {

        public long? Courseid { get; set; }
        [Key]
        public long Teacherid { get; set; }

        [Required]
        [StringLength(150)]
        public string Name { get; set; } = null!;

        [Phone]
        [StringLength(20)]
        public string? Phone { get; set; }

        [StringLength(50)]
        public string? NationalCode { get; set; }   // کد ملی - often used in Iran

        [EmailAddress]
        [StringLength(100)]
        public string? Email { get; set; }

        // Link to authentication/user account (if you have separate login system)
        public long? Userid { get; set; }

        [ForeignKey(nameof(Userid))]
        public virtual User? User { get; set; }     // optional - if you have User table

        // Audit fields (very useful)
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Soft delete support (recommended)
        public bool IsDeleted { get; set; } = false;
        public DateTime? DeletedAt { get; set; }

        // Navigation property: Many-to-Many or One-to-Many relationship
        // Teachers → Courses (a teacher can teach multiple courses)
        public virtual ICollection<Course> Courses { get; set; } = new List<Course>();
    }
}