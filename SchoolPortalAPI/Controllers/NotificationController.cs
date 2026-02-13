using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SchoolPortalAPI.Data;
using SchoolPortalAPI.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SchoolPortalAPI.Controllers
{
    [ApiController]
    [Route("api/notifications")]
    public class NotificationController : ControllerBase
    {
        private readonly SchoolDbContext _context;

        public NotificationController(SchoolDbContext context)
        {
            _context = context;
        }

        // GET: api/notifications/123
        [HttpGet("{userId}")]
        public async Task<IActionResult> GetUserNotifications(long userId)
        {
            if (userId <= 0) return BadRequest("UserId نامعتبر است");

            var notifications = await _context.Notifications
                .Where(n => n.UserId == userId)
                .OrderByDescending(n => n.CreatedAt)
                .Select(n => new
                {
                    id = n.NotificationId,
                    title = n.Title,
                    body = n.Body,
                    type = n.Type,
                    createdAt = n.CreatedAt.ToString("o"),
                    isRead = n.IsRead,
                    // readAt = n.ReadAt?.ToString("o"),   // optional
                })
                .ToListAsync();

            return Ok(notifications);
        }

        // PUT: api/notifications/456/read
        [HttpPut("{id}/read")]
        public async Task<IActionResult> MarkAsRead(long id)
        {
            var n = await _context.Notifications.FindAsync(id);
            if (n == null) return NotFound();

            n.IsRead = true;
            n.ReadAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // POST: api/notifications (for creating - usually called from other controllers)
        [HttpPost]
        public async Task<ActionResult> CreateNotification([FromBody] CreateNotificationDto dto)
        {
            var notification = new Notification
            {
                UserId = dto.UserId,
                Title = dto.Title,
                Body = dto.Body ?? "",
                Type = dto.Type ?? "general",
                RelatedId = dto.RelatedId,
                RelatedType = dto.RelatedType
            };

            _context.Notifications.Add(notification);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetUserNotifications), new { userId = dto.UserId }, notification);
        }

        // Optional: mark all as read
        [HttpPut("mark-all-read")]
        public async Task<IActionResult> MarkAllAsRead([FromQuery] long userId)
        {
            if (userId <= 0)
                return BadRequest();

            var notifications = await _context.Notifications
                .Where(n => n.UserId == userId && !n.IsRead)
                .ToListAsync();

            foreach (var n in notifications)
            {
                n.IsRead = true;
                n.ReadAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/notifications/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteNotification(long id)
        {
            var notification = await _context.Notifications.FindAsync(id);
            if (notification == null)
                return NotFound();

            // Optional: Check ownership
            // if (notification.UserId != currentUserId) return Forbid();

            _context.Notifications.Remove(notification);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE ALL for a user: api/notifications/clear?userId=123
        [HttpDelete("clear")]
        public async Task<IActionResult> DeleteAllUserNotifications([FromQuery] long userId)
        {
            if (userId <= 0) return BadRequest("UserId نامعتبر است");

            var notifications = await _context.Notifications
                .Where(n => n.UserId == userId)
                .ToListAsync();

            if (!notifications.Any())
                return NoContent(); // nothing to delete

            _context.Notifications.RemoveRange(notifications);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }

    public class CreateNotificationDto
    {
        public long UserId { get; set; }
        public string Title { get; set; } = null!;
        public string? Body { get; set; }
        public string? Type { get; set; }
        public long? RelatedId { get; set; }
        public string? RelatedType { get; set; }
    }
}