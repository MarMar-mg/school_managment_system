//using Microsoft.EntityFrameworkCore;
//using SchoolPortalAPI.Data;
//
//var builder = WebApplication.CreateBuilder(args);
//
//// CORS — کامل
//builder.Services.AddCors(options =>
//{
//    options.AddPolicy("FlutterWebPolicy", policy =>
//    {
//        policy.WithOrigins("http://localhost:55295", "http://127.0.0.1:55295")
//              .AllowAnyHeader()
//              .AllowAnyMethod()
//              .AllowCredentials();
//    });
//});
//
//builder.Services.AddControllers();
//builder.Services.AddDbContext<SchoolDbContext>(options =>
//    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
//
//var app = builder.Build();
//
//// ترتیب مهم!
//app.UseCors("FlutterWebPolicy"); // قبل از MapControllers
//app.UseHttpsRedirection();
//app.MapControllers();
//
//app.Run();
using Microsoft.EntityFrameworkCore;
using SchoolPortalAPI.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();

// ==================== CORS CONFIGURATION ====================
// This allows your Flutter web app to communicate with the API
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterWeb", policy =>
    {
        policy.AllowAnyOrigin()      // Allows requests from any origin (for development)
              .AllowAnyMethod()      // Allows any HTTP method (GET, POST, PUT, DELETE, etc.)
              .AllowAnyHeader();     // Allows any headers
    });
});

// Add Swagger/OpenAPI for API documentation
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configure Database Context
builder.Services.AddDbContext<SchoolDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// ==================== ENABLE CORS ====================
// IMPORTANT: This must be called BEFORE UseAuthorization
app.UseCors("AllowFlutterWeb");

// Serve static files (for uploaded files like PDFs, images)
app.UseStaticFiles();

app.UseAuthorization();

app.MapControllers();

app.Run();