// Models/Score.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using SchoolPortalAPI.Models; // این خط حتماً باشد

namespace SchoolPortalAPI.Models
{
   // Models/Score.cs
   public class Score
   {
       [Key]
       public long Id { get; set; }

       public long ScoreValue { get; set; }
       public string Score_month { get; set; } = null!;

       [Column("StuCode")]
       public string StuCode { get; set; } = null!;

       public long? Courseid { get; set; }
       public long? Classid { get; set; }

       [ForeignKey("Courseid")]
       public virtual Course? Course { get; set; }

       [ForeignKey("Classid")]
       public virtual Class? Class { get; set; }
   }
}