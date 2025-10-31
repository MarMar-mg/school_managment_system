using System.ComponentModel.DataAnnotations;

namespace SchoolPortalAPI.Models
{
    public class Student
    {
        [Key]
        public long Studentid { get; set; }

        public string Name { get; set; } = null!;
        public int? Score { get; set; }
        public string? Address { get; set; }
        public long? Birthdate { get; set; }
        public long? Registerdate { get; set; }
        public string? ParentNum1 { get; set; }
        public string? ParentNum2 { get; set; }
        public long? Debt { get; set; }
        public string StuCode { get; set; } = null!;
        public long? UserID { get; set; }
        public long? Classeid { get; set; }
        public string? Score_month { get; set; }
    }
}