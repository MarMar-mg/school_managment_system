// Controllers/NewsController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SchoolPortalAPI.Data;
using SchoolPortalAPI.Models;

namespace SchoolPortalAPI.Controllers
{
    [ApiController]
    [Route("api/news")]
    public class NewsController : ControllerBase
    {
        private readonly SchoolDbContext _context;

        public NewsController(SchoolDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var news = await _context.News
                .Select(n => new
                {
                    n.Newsid,
                    n.Title,
                    n.Category,
                    n.Startdate,
                    n.Enddate,
                    n.Image
                })
                .ToListAsync();

            return Ok(news);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(long id)
        {
            var news = await _context.News.FindAsync(id);
            if (news == null) return NotFound();
            return Ok(news);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] News news)
        {
            _context.News.Add(news);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetById), new { id = news.Newsid }, news);
        }
    }
}