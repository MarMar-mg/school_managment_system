// Controllers/EventController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SchoolPortalAPI.Data;
using SchoolPortalAPI.Models;

namespace SchoolPortalAPI.Controllers
{
    [ApiController]
    [Route("api/calender")]
    public class EventController : ControllerBase
    {
        private readonly SchoolDbContext _context;

        public EventController(SchoolDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var events = await _context.Calendars
                .Select(e => new
                {
                    e.Eventid,
                    e.Title,
                    e.Date
                })
                .ToListAsync();

            return Ok(events);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] Calender calender)
        {
            _context.Calendars.Add(calender);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetAll), new { id = calender.Eventid }, calender);
        }
    }
}