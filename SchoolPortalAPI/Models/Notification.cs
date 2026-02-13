// Models/Notification.cs
using System;
using System.ComponentModel.DataAnnotations;

namespace SchoolPortalAPI.Models
{
    public class Notification
    {
        [Key]
        public long NotificationId { get; set; }

        public long UserId { get; set; }           // who receives it

        [Required]
        [StringLength(200)]
        public string Title { get; set; } = null!;

        [StringLength(500)]
        public string Body { get; set; } = string.Empty;

        public string Type { get; set; } = "general";   // grade, assignment, announcement, event, system, ...

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public bool IsRead { get; set; } = false;

        public DateTime? ReadAt { get; set; }

        // Optional: reference to related entity
        public long? RelatedId { get; set; }     // e.g. ExamId, AssignmentId, NewsId
        public string? RelatedType { get; set; } // "exam", "assignment", "news"
    }
}