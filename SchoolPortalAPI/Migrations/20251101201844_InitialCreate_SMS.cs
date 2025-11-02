using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SchoolPortalAPI.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate_SMS : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Calendars",
                columns: table => new
                {
                    Eventid = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Date = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Calendars", x => x.Eventid);
                });

            migrationBuilder.CreateTable(
                name: "ClassCourses",
                columns: table => new
                {
                    Classcourseid = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Courseid = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ClassCourses", x => x.Classcourseid);
                });

            migrationBuilder.CreateTable(
                name: "Classes",
                columns: table => new
                {
                    Classid = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Capacity = table.Column<int>(type: "int", nullable: false),
                    Grade = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Classes", x => x.Classid);
                });

            migrationBuilder.CreateTable(
                name: "Courses",
                columns: table => new
                {
                    Courseid = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Finalexamdate = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Classtime = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Classid = table.Column<long>(type: "bigint", nullable: true),
                    Teacherid = table.Column<long>(type: "bigint", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Courses", x => x.Courseid);
                });

            migrationBuilder.CreateTable(
                name: "Equipment",
                columns: table => new
                {
                    Equipmentid = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Eqcode = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Eqcatry = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Location = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Equipment", x => x.Equipmentid);
                });

            migrationBuilder.CreateTable(
                name: "Exams",
                columns: table => new
                {
                    Examid = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Image = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Startdate = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Enddate = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Starttime = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Endtime = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Courseid = table.Column<long>(type: "bigint", nullable: false),
                    Classid = table.Column<long>(type: "bigint", nullable: true),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Filename = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Exams", x => x.Examid);
                });

            migrationBuilder.CreateTable(
                name: "ExamStuTeaches",
                columns: table => new
                {
                    Estid = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Score = table.Column<int>(type: "int", nullable: true),
                    Answerimage = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Examid = table.Column<long>(type: "bigint", nullable: false),
                    Courseid = table.Column<long>(type: "bigint", nullable: false),
                    Teacherid = table.Column<long>(type: "bigint", nullable: false),
                    Date = table.Column<long>(type: "bigint", nullable: true),
                    Studentid = table.Column<long>(type: "bigint", nullable: true),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Filename = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ExamStuTeaches", x => x.Estid);
                });

            migrationBuilder.CreateTable(
                name: "Exercises",
                columns: table => new
                {
                    Exerciseid = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Image = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Startdate = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Enddate = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Starttime = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Endtime = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Courseid = table.Column<long>(type: "bigint", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Classid = table.Column<long>(type: "bigint", nullable: true),
                    Filename = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Exercises", x => x.Exerciseid);
                });

            migrationBuilder.CreateTable(
                name: "ExerciseStuTeaches",
                columns: table => new
                {
                    Exstid = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Score = table.Column<int>(type: "int", nullable: true),
                    Answerimage = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Exerciseid = table.Column<long>(type: "bigint", nullable: false),
                    Courseid = table.Column<long>(type: "bigint", nullable: false),
                    Teacherid = table.Column<long>(type: "bigint", nullable: false),
                    Studentid = table.Column<long>(type: "bigint", nullable: true),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Date = table.Column<long>(type: "bigint", nullable: true),
                    Filename = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ExerciseStuTeaches", x => x.Exstid);
                });

            migrationBuilder.CreateTable(
                name: "Managers",
                columns: table => new
                {
                    Assistantid = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Userid = table.Column<long>(type: "bigint", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Managers", x => x.Assistantid);
                });

            migrationBuilder.CreateTable(
                name: "News",
                columns: table => new
                {
                    Newsid = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Category = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Startdate = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Enddate = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Image = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_News", x => x.Newsid);
                });

            migrationBuilder.CreateTable(
                name: "Scores",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ScoreValue = table.Column<long>(type: "bigint", nullable: false),
                    Score_month = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Classid = table.Column<long>(type: "bigint", nullable: true),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    StuCode = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Courseid = table.Column<long>(type: "bigint", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Scores", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Students",
                columns: table => new
                {
                    Studentid = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Score = table.Column<int>(type: "int", nullable: true),
                    Address = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Birthdate = table.Column<long>(type: "bigint", nullable: true),
                    Registerdate = table.Column<long>(type: "bigint", nullable: true),
                    ParentNum1 = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ParentNum2 = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Debt = table.Column<long>(type: "bigint", nullable: true),
                    StuCode = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    UserID = table.Column<long>(type: "bigint", nullable: true),
                    Classeid = table.Column<long>(type: "bigint", nullable: true),
                    Score_month = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Students", x => x.Studentid);
                });

            migrationBuilder.CreateTable(
                name: "Teachers",
                columns: table => new
                {
                    Teacherid = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Userid = table.Column<long>(type: "bigint", nullable: true),
                    Courseid = table.Column<long>(type: "bigint", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Teachers", x => x.Teacherid);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Userid = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Username = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Password = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Role = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Userid);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Calendars");

            migrationBuilder.DropTable(
                name: "ClassCourses");

            migrationBuilder.DropTable(
                name: "Classes");

            migrationBuilder.DropTable(
                name: "Courses");

            migrationBuilder.DropTable(
                name: "Equipment");

            migrationBuilder.DropTable(
                name: "Exams");

            migrationBuilder.DropTable(
                name: "ExamStuTeaches");

            migrationBuilder.DropTable(
                name: "Exercises");

            migrationBuilder.DropTable(
                name: "ExerciseStuTeaches");

            migrationBuilder.DropTable(
                name: "Managers");

            migrationBuilder.DropTable(
                name: "News");

            migrationBuilder.DropTable(
                name: "Scores");

            migrationBuilder.DropTable(
                name: "Students");

            migrationBuilder.DropTable(
                name: "Teachers");

            migrationBuilder.DropTable(
                name: "Users");
        }
    }
}
