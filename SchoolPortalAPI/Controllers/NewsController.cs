// Controllers/NewsController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

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
    public async Task<IActionResult> GetNews()
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
}