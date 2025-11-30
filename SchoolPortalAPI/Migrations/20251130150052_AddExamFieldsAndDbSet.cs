using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SchoolPortalAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddExamFieldsAndDbSet : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Name",
                table: "Scores");

            migrationBuilder.DropColumn(
                name: "Filename",
                table: "Exercises");

            migrationBuilder.DropColumn(
                name: "Image",
                table: "Exercises");

            migrationBuilder.DropColumn(
                name: "Filename",
                table: "Exams");

            migrationBuilder.DropColumn(
                name: "Image",
                table: "Exams");

            migrationBuilder.AlterColumn<long>(
                name: "StuCode",
                table: "Scores",
                type: "bigint",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Date",
                table: "ExerciseStuTeaches",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(long),
                oldType: "bigint",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Starttime",
                table: "Exercises",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Startdate",
                table: "Exercises",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Endtime",
                table: "Exercises",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Enddate",
                table: "Exercises",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);

            migrationBuilder.AlterColumn<long>(
                name: "Courseid",
                table: "Exercises",
                type: "bigint",
                nullable: true,
                oldClrType: typeof(long),
                oldType: "bigint");

            migrationBuilder.AddColumn<long>(
                name: "Score",
                table: "Exercises",
                type: "bigint",
                nullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Date",
                table: "ExamStuTeaches",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(long),
                oldType: "bigint",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Title",
                table: "Exams",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.AlterColumn<long>(
                name: "Courseid",
                table: "Exams",
                type: "bigint",
                nullable: true,
                oldClrType: typeof(long),
                oldType: "bigint");

            migrationBuilder.AddColumn<int>(
                name: "Capacity",
                table: "Exams",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Duration",
                table: "Exams",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "PossibleScore",
                table: "Exams",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Code",
                table: "Courses",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Location",
                table: "Courses",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Time",
                table: "Courses",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Date",
                table: "Calendars",
                type: "nvarchar(max)",
                nullable: false,
                oldClrType: typeof(long),
                oldType: "bigint");

            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "Calendars",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Scores_Classid",
                table: "Scores",
                column: "Classid");

            migrationBuilder.CreateIndex(
                name: "IX_Scores_Courseid",
                table: "Scores",
                column: "Courseid");

            migrationBuilder.CreateIndex(
                name: "IX_Exercises_Classid",
                table: "Exercises",
                column: "Classid");

            migrationBuilder.CreateIndex(
                name: "IX_Exercises_Courseid",
                table: "Exercises",
                column: "Courseid");

            migrationBuilder.CreateIndex(
                name: "IX_ExamStuTeaches_Courseid",
                table: "ExamStuTeaches",
                column: "Courseid");

            migrationBuilder.CreateIndex(
                name: "IX_ExamStuTeaches_Examid",
                table: "ExamStuTeaches",
                column: "Examid");

            migrationBuilder.CreateIndex(
                name: "IX_ExamStuTeaches_Studentid",
                table: "ExamStuTeaches",
                column: "Studentid");

            migrationBuilder.CreateIndex(
                name: "IX_ExamStuTeaches_Teacherid",
                table: "ExamStuTeaches",
                column: "Teacherid");

            migrationBuilder.CreateIndex(
                name: "IX_Exams_Classid",
                table: "Exams",
                column: "Classid");

            migrationBuilder.CreateIndex(
                name: "IX_Exams_Courseid",
                table: "Exams",
                column: "Courseid");

            migrationBuilder.CreateIndex(
                name: "IX_Courses_Classid",
                table: "Courses",
                column: "Classid");

            migrationBuilder.CreateIndex(
                name: "IX_Courses_Teacherid",
                table: "Courses",
                column: "Teacherid");

            migrationBuilder.AddForeignKey(
                name: "FK_Courses_Classes_Classid",
                table: "Courses",
                column: "Classid",
                principalTable: "Classes",
                principalColumn: "Classid");

            migrationBuilder.AddForeignKey(
                name: "FK_Courses_Teachers_Teacherid",
                table: "Courses",
                column: "Teacherid",
                principalTable: "Teachers",
                principalColumn: "Teacherid");

            migrationBuilder.AddForeignKey(
                name: "FK_Exams_Classes_Classid",
                table: "Exams",
                column: "Classid",
                principalTable: "Classes",
                principalColumn: "Classid");

            migrationBuilder.AddForeignKey(
                name: "FK_Exams_Courses_Courseid",
                table: "Exams",
                column: "Courseid",
                principalTable: "Courses",
                principalColumn: "Courseid");

            migrationBuilder.AddForeignKey(
                name: "FK_ExamStuTeaches_Courses_Courseid",
                table: "ExamStuTeaches",
                column: "Courseid",
                principalTable: "Courses",
                principalColumn: "Courseid",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_ExamStuTeaches_Exams_Examid",
                table: "ExamStuTeaches",
                column: "Examid",
                principalTable: "Exams",
                principalColumn: "Examid",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_ExamStuTeaches_Students_Studentid",
                table: "ExamStuTeaches",
                column: "Studentid",
                principalTable: "Students",
                principalColumn: "Studentid");

            migrationBuilder.AddForeignKey(
                name: "FK_ExamStuTeaches_Teachers_Teacherid",
                table: "ExamStuTeaches",
                column: "Teacherid",
                principalTable: "Teachers",
                principalColumn: "Teacherid",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Exercises_Classes_Classid",
                table: "Exercises",
                column: "Classid",
                principalTable: "Classes",
                principalColumn: "Classid");

            migrationBuilder.AddForeignKey(
                name: "FK_Exercises_Courses_Courseid",
                table: "Exercises",
                column: "Courseid",
                principalTable: "Courses",
                principalColumn: "Courseid");

            migrationBuilder.AddForeignKey(
                name: "FK_Scores_Classes_Classid",
                table: "Scores",
                column: "Classid",
                principalTable: "Classes",
                principalColumn: "Classid");

            migrationBuilder.AddForeignKey(
                name: "FK_Scores_Courses_Courseid",
                table: "Scores",
                column: "Courseid",
                principalTable: "Courses",
                principalColumn: "Courseid");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Courses_Classes_Classid",
                table: "Courses");

            migrationBuilder.DropForeignKey(
                name: "FK_Courses_Teachers_Teacherid",
                table: "Courses");

            migrationBuilder.DropForeignKey(
                name: "FK_Exams_Classes_Classid",
                table: "Exams");

            migrationBuilder.DropForeignKey(
                name: "FK_Exams_Courses_Courseid",
                table: "Exams");

            migrationBuilder.DropForeignKey(
                name: "FK_ExamStuTeaches_Courses_Courseid",
                table: "ExamStuTeaches");

            migrationBuilder.DropForeignKey(
                name: "FK_ExamStuTeaches_Exams_Examid",
                table: "ExamStuTeaches");

            migrationBuilder.DropForeignKey(
                name: "FK_ExamStuTeaches_Students_Studentid",
                table: "ExamStuTeaches");

            migrationBuilder.DropForeignKey(
                name: "FK_ExamStuTeaches_Teachers_Teacherid",
                table: "ExamStuTeaches");

            migrationBuilder.DropForeignKey(
                name: "FK_Exercises_Classes_Classid",
                table: "Exercises");

            migrationBuilder.DropForeignKey(
                name: "FK_Exercises_Courses_Courseid",
                table: "Exercises");

            migrationBuilder.DropForeignKey(
                name: "FK_Scores_Classes_Classid",
                table: "Scores");

            migrationBuilder.DropForeignKey(
                name: "FK_Scores_Courses_Courseid",
                table: "Scores");

            migrationBuilder.DropIndex(
                name: "IX_Scores_Classid",
                table: "Scores");

            migrationBuilder.DropIndex(
                name: "IX_Scores_Courseid",
                table: "Scores");

            migrationBuilder.DropIndex(
                name: "IX_Exercises_Classid",
                table: "Exercises");

            migrationBuilder.DropIndex(
                name: "IX_Exercises_Courseid",
                table: "Exercises");

            migrationBuilder.DropIndex(
                name: "IX_ExamStuTeaches_Courseid",
                table: "ExamStuTeaches");

            migrationBuilder.DropIndex(
                name: "IX_ExamStuTeaches_Examid",
                table: "ExamStuTeaches");

            migrationBuilder.DropIndex(
                name: "IX_ExamStuTeaches_Studentid",
                table: "ExamStuTeaches");

            migrationBuilder.DropIndex(
                name: "IX_ExamStuTeaches_Teacherid",
                table: "ExamStuTeaches");

            migrationBuilder.DropIndex(
                name: "IX_Exams_Classid",
                table: "Exams");

            migrationBuilder.DropIndex(
                name: "IX_Exams_Courseid",
                table: "Exams");

            migrationBuilder.DropIndex(
                name: "IX_Courses_Classid",
                table: "Courses");

            migrationBuilder.DropIndex(
                name: "IX_Courses_Teacherid",
                table: "Courses");

            migrationBuilder.DropColumn(
                name: "Score",
                table: "Exercises");

            migrationBuilder.DropColumn(
                name: "Capacity",
                table: "Exams");

            migrationBuilder.DropColumn(
                name: "Duration",
                table: "Exams");

            migrationBuilder.DropColumn(
                name: "PossibleScore",
                table: "Exams");

            migrationBuilder.DropColumn(
                name: "Code",
                table: "Courses");

            migrationBuilder.DropColumn(
                name: "Location",
                table: "Courses");

            migrationBuilder.DropColumn(
                name: "Time",
                table: "Courses");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "Calendars");

            migrationBuilder.AlterColumn<string>(
                name: "StuCode",
                table: "Scores",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(long),
                oldType: "bigint",
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Name",
                table: "Scores",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AlterColumn<long>(
                name: "Date",
                table: "ExerciseStuTeaches",
                type: "bigint",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Starttime",
                table: "Exercises",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.AlterColumn<string>(
                name: "Startdate",
                table: "Exercises",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.AlterColumn<string>(
                name: "Endtime",
                table: "Exercises",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.AlterColumn<string>(
                name: "Enddate",
                table: "Exercises",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.AlterColumn<long>(
                name: "Courseid",
                table: "Exercises",
                type: "bigint",
                nullable: false,
                defaultValue: 0L,
                oldClrType: typeof(long),
                oldType: "bigint",
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Filename",
                table: "Exercises",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Image",
                table: "Exercises",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AlterColumn<long>(
                name: "Date",
                table: "ExamStuTeaches",
                type: "bigint",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Title",
                table: "Exams",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);

            migrationBuilder.AlterColumn<long>(
                name: "Courseid",
                table: "Exams",
                type: "bigint",
                nullable: false,
                defaultValue: 0L,
                oldClrType: typeof(long),
                oldType: "bigint",
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Filename",
                table: "Exams",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Image",
                table: "Exams",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AlterColumn<long>(
                name: "Date",
                table: "Calendars",
                type: "bigint",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");
        }
    }
}
