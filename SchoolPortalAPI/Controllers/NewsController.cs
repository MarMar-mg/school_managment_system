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

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(long id)
        {
            var newsItem = await _context.News.FindAsync(id);
            if (newsItem == null)
            {
                return NotFound();
            }

            // Optional: delete the image file from disk
            if (!string.IsNullOrEmpty(newsItem.Image))
            {
                var imageFullPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot",
                    newsItem.Image.TrimStart('/'));

                if (System.IO.File.Exists(imageFullPath))
                {
                    try
                    {
                        System.IO.File.Delete(imageFullPath);
                    }
                    catch (Exception ex)
                    {
                        // Log but don't fail the operation
                        Console.WriteLine($"Could not delete image file: {ex.Message}");
                    }
                }
            }

            _context.News.Remove(newsItem);
            await _context.SaveChangesAsync();

            return NoContent();  // 204 - success
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(long id, [FromForm] UpdateNewsDto dto, IFormFile? image)
        {
            var news = await _context.News.FindAsync(id);
            if (news == null)
            {
                return NotFound();
            }

            // Update fields
            news.Title = dto.Title ?? news.Title;
            news.Category = dto.Category ?? news.Category;
            news.Startdate = dto.Startdate ?? news.Startdate;
            news.Enddate = dto.Enddate ?? news.Enddate;
            news.Description = dto.Description ?? news.Description;

            // Handle new image upload
            if (image != null && image.Length > 0)
            {
                // Delete old image if exists
                if (!string.IsNullOrEmpty(news.Image))
                {
                    var oldImagePath = Path.Combine("wwwroot", news.Image.TrimStart('/'));
                    if (System.IO.File.Exists(oldImagePath))
                    {
                        try { System.IO.File.Delete(oldImagePath); } catch { }
                    }
                }

                // Save new image
                var fileName = $"{Guid.NewGuid()}{Path.GetExtension(image.FileName)}";
                var filePath = Path.Combine("wwwroot/news_images", fileName);
                Directory.CreateDirectory(Path.GetDirectoryName(filePath)!);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await image.CopyToAsync(stream);
                }

                news.Image = $"/news_images/{fileName}";
            }

            _context.News.Update(news);
            await _context.SaveChangesAsync();

            return NoContent(); // 204
        }

        // DTO for update (add this class in Models or in the controller file)
        public class UpdateNewsDto
        {
            public string? Title { get; set; }
            public string? Category { get; set; }
            public string? Startdate { get; set; }
            public string? Enddate { get; set; }
            public string? Description { get; set; }
        }
    }
}