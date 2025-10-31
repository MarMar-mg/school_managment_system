using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace SchoolSystemAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EventsController : ControllerBase
    {
        private readonly SchoolDbContext _context;

        public EventsController(SchoolDbContext context)
        {
            _context = context;
        }

        // GET: api/events
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var events = await _context.CalendarEvents
                .OrderByDescending(e => e.Date)
                .Select(e => new
                {
                    eventId = e.EventId,
                    title = e.Title,
                    date = e.Date
                })
                .Take(20)
                .ToListAsync();

            return Ok(events);
        }

        // GET: api/events/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(long id)
        {
            var evt = await _context.CalendarEvents.FindAsync(id);
            if (evt == null)
                return NotFound();

            return Ok(evt);
        }

        // POST: api/events
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CalendarEvent evt)
        {
            _context.CalendarEvents.Add(evt);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetById), new { id = evt.EventId }, evt);
        }

        // PUT: api/events/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(long id, [FromBody] CalendarEvent evt)
        {
            if (id != evt.EventId)
                return BadRequest();

            _context.Entry(evt).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!await _context.CalendarEvents.AnyAsync(e => e.EventId == id))
                    return NotFound();
                throw;
            }

            return NoContent();
        }

        // DELETE: api/events/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(long id)
        {
            var evt = await _context.CalendarEvents.FindAsync(id);
            if (evt == null)
                return NotFound();

            _context.CalendarEvents.Remove(evt);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
