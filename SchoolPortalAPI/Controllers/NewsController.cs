using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SchoolPortalAPI.Data;
using SchoolPortalAPI.Models;
using System.IO;
using System;

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

        [HttpPost]
        public async Task<IActionResult> Create([FromForm] News news, IFormFile? image)
        {
            if (string.IsNullOrEmpty(news.Title) || string.IsNullOrEmpty(news.Category))
            {
                return BadRequest("Title and Category are required.");
            }

            if (image != null && image.Length > 0)
            {
                var fileName = Guid.NewGuid().ToString() + Path.GetExtension(image.FileName);
                var filePath = Path.Combine("wwwroot/news_images", fileName);
                Directory.CreateDirectory(Path.GetDirectoryName(filePath)!);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await image.CopyToAsync(stream);
                }

                news.Image = $"/news_images/{fileName}";
            }

            _context.News.Add(news);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetById), new { id = news.Newsid }, news);
        }
    }
}