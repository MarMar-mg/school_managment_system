using Microsoft.EntityFrameworkCore;
using SchoolPortalAPI.Data;

var builder = WebApplication.CreateBuilder(args);

// CORS — کامل
builder.Services.AddCors(options =>
{
    options.AddPolicy("FlutterWebPolicy", policy =>
    {
        policy.WithOrigins("http://localhost:55295", "http://127.0.0.1:55295")
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

builder.Services.AddControllers();
builder.Services.AddDbContext<SchoolDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

var app = builder.Build();

// ترتیب مهم!
app.UseCors("FlutterWebPolicy"); // قبل از MapControllers
app.UseHttpsRedirection();
app.MapControllers();

app.Run();