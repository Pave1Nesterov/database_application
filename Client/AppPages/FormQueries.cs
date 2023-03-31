using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Npgsql;

namespace Client
{
    public partial class FormQueries : Form
    {
        private NpgsqlConnection _connection;
        private NpgsqlCommand _command;
        private Tools _tool;
        private string query;
        private string message;
        FormMain _fm;
        private string table;
        private InsUpd_10cols_tcketview f_InsUpd_10_ticketview;

        public FormQueries()
        {
            InitializeComponent();
        }
        public FormQueries(NpgsqlConnection conn, NpgsqlCommand comm, FormMain fm)
        {
            _tool = new Tools(conn);
            _connection = conn;
            _command = comm;
            _fm = fm;
            message = "Составной многотабличный запрос с CASE-выражением\n" +
                        "Определение позиции вагона в составе";
            InitializeComponent();
        }

        private void FormQueries_Load(object sender, EventArgs e)
        {
            dataGridView1.DataSource = _tool.displayQuery("select * from q1_view;");
            if (dataGridView1.DataSource == null) return;
        }

        private void tabControl1_Selected(object sender, TabControlEventArgs e)
        {
            switch (e.TabPageIndex)
            {
                case 0:
                    buttonUpdate.Visible = false;
                    query = "SELECT * FROM q1_view;";
                    message = "Составной многотабличный запрос с CASE-выражением\n" +
                        "Определение позиции вагона в составе";
                    dataGridView1.Parent = e.TabPage;
                    break;
                case 1:
                    buttonUpdate.Visible = true;
                    query = "SELECT * FROM ticket_view;";
                    message = "Многотабличный view с возможностью его обновления";
                    dataGridView1.Parent = e.TabPage;
                    break;
                case 2:
                    buttonUpdate.Visible = false;
                    query = "SELECT * FROM q3_1_view;";
                    message = "Пассажиры, имеющие билет с отправлением из Санкт-Петербурга (подзапрос в SELECT)";
                    dataGridView1.Parent = e.TabPage;
                    break;
                case 3:
                    buttonUpdate.Visible = false;
                    query = "SELECT * FROM q3_2_view;";
                    message = "Пассажиры, чьи билеты стоят дешевле 3000р (подзапрос в FROM)";
                    dataGridView1.Parent = e.TabPage;
                    break;
                case 4:
                    buttonUpdate.Visible = false;
                    query = "SELECT * FROM q3_3_view;";
                    message = "Пассажиры, оплатившие страховку при покупке билета (подзапрос в WHERE)";
                    dataGridView1.Parent = e.TabPage;
                    break;
                case 5:
                    buttonUpdate.Visible = false;
                    query = "SELECT * FROM q4_1_view;";
                    message = "Пассажиры, у которых есть бесплатный билет";
                    dataGridView1.Parent = e.TabPage;
                    break;
                case 6:
                    buttonUpdate.Visible = false;
                    query = "SELECT * FROM q4_2_view;";
                    message = "Пассажиры, которые имеют билеты на определённую дату";
                    dataGridView1.Parent = e.TabPage;
                    break;
                case 7:
                    buttonUpdate.Visible = false;
                    query = "SELECT * FROM q4_3_view;";
                    message = "Поезда, которые входят в категори \"Скоростные\"";
                    dataGridView1.Parent = e.TabPage;
                    break;
                case 8:
                    buttonUpdate.Visible = false;
                    query = "SELECT * FROM q5_view;";
                    message = "Пассажиры, которые потратили на билеты больше 3000р";
                    dataGridView1.Parent = e.TabPage;
                    break;
                case 9:
                    buttonUpdate.Visible = false;
                    query = "SELECT * FROM q6_1_view;";
                    message = "Пассажиры и их траты на билеты с ненулевой ценой (предикат ANY)";
                    dataGridView1.Parent = e.TabPage;
                    break;
                case 10:
                    buttonUpdate.Visible = false;
                    query = "SELECT * FROM q6_2_view;";
                    message = "Поезда, которые не входят в категорю \"Скорые круглогодичного обращения\"";
                    dataGridView1.Parent = e.TabPage;
                    break;
            }
        }

        private void dataGridView1_ParentChanged(object sender, EventArgs e)
        {
            dataGridView1.DataSource = _tool.displayQuery(query);
            if (dataGridView1.DataSource == null) return;
        }
        private void buttonClose_Click(object sender, EventArgs e) => this.Close();
        private void buttonQuestion_Click(object sender, EventArgs e) => MessageBox.Show(message, "Информация");
        private void buttonUpdate_Click(object sender, EventArgs e)
        {
            table = "ticket_view";
            f_InsUpd_10_ticketview = new InsUpd_10cols_tcketview(_connection, _command, table);
            f_InsUpd_10_ticketview._id = int.Parse(dataGridView1.SelectedRows[0].Cells[0].Value.ToString());
            f_InsUpd_10_ticketview.setValues(
                dataGridView1.SelectedRows[0].Cells["Фамилия"].Value.ToString(),
                dataGridView1.SelectedRows[0].Cells["Имя"].Value.ToString(),
                dataGridView1.SelectedRows[0].Cells["Отчество"].Value.ToString(),
                dataGridView1.SelectedRows[0].Cells["Поезд"].Value.ToString(),
                dataGridView1.SelectedRows[0].Cells["А"].Value.ToString(),
                DateTime.Parse(dataGridView1.SelectedRows[0].Cells["Отправление"].Value.ToString()),
                dataGridView1.SelectedRows[0].Cells["В"].Value.ToString(),
                DateTime.Parse(dataGridView1.SelectedRows[0].Cells["Прибытие"].Value.ToString()),
                dataGridView1.SelectedRows[0].Cells["Вагон"].Value.ToString(),
                dataGridView1.SelectedRows[0].Cells["Место"].Value.ToString(),
                dataGridView1.SelectedRows[0].Cells["Цена"].Value.ToString(),
                Convert.ToBoolean(dataGridView1.SelectedRows[0].Cells["Бельё"].Value.ToString()),
                Convert.ToBoolean(dataGridView1.SelectedRows[0].Cells["Страховка"].Value.ToString())
                );
            f_InsUpd_10_ticketview.ShowDialog();
            dataGridView1.DataSource = _tool.displayQuery(query);
            if (dataGridView1.DataSource == null) return;
        }
    }
}