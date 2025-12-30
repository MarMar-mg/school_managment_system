using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SchoolPortalAPI.Migrations
{
    /// <inheritdoc />
    public partial class SyncStudentidColumnn : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "StuCode",
                table: "Scores",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Scores_Studentid",
                table: "Scores",
                column: "Studentid");

            migrationBuilder.AddForeignKey(
                name: "FK_Scores_Students_Studentid",
                table: "Scores",
                column: "Studentid",
                principalTable: "Students",
                principalColumn: "Studentid");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Scores_Students_Studentid",
                table: "Scores");

            migrationBuilder.DropIndex(
                name: "IX_Scores_Studentid",
                table: "Scores");

            migrationBuilder.DropColumn(
                name: "StuCode",
                table: "Scores");
        }
    }
}
