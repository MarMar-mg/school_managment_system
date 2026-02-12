using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SchoolPortalAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddSpecialtyToTeacher : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Specialty",
                table: "Teachers",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Specialty",
                table: "Teachers");
        }
    }
}
