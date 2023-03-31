using Npgsql;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Client
{
    public partial class FormMain : Form
    {
        public string query;
        private string table;
        private NpgsqlConnection _connection;
        private NpgsqlCommand _command;
        private InsUpd_2cols f_InsUpd_2;
        private InsUpd_2cols_Rt f_InsUpd_2_Rt;
        private InsUpd_5cols f_InsUpd_5;
        private InsUpd_9cols f_InsUpd_9;
        private InsUpd_10cols_pass f_InsUpd_10_pass;
        private InsUpd_10cols_ticket f_InsUpd_10_ticket;
        private Tools _tool;
        private static string username;
        private int dgTabPageIdx;
        private int rowIdx = -1;
        private int id_delete;
        private int privelege_lvl;
        private string _event;
        public FormMain()
        {
            InitializeComponent();
        }
        public FormMain(NpgsqlConnection conn, NpgsqlCommand comm, string _username)
        {
            _tool = new Tools(conn);
            _connection = conn;
            _command = comm;
            username = _username;
            privelege_lvl = _tool.checkPrivileges(username);
            InitializeComponent();
            label1.Text = "user: " + _username;
        }
        private void tabControl_Selected(object sender, TabControlEventArgs e)
        {
            switch (e.TabPageIndex)
            {
                case 0:
                    query = "SELECT * FROM ticket_view_main;";
                    dgTabPageIdx = e.TabPageIndex;
                    if (dataGridView1.DataSource != null)
                    {
                        rowIdx = 0;
                        id_delete = (int)dataGridView1.SelectedRows[0].Cells[0].Value;
                    }
                    break;
                case 1:
                    query = "SELECT * FROM passenger_view;";
                    dgTabPageIdx = e.TabPageIndex;
                    if (dataGridView1.DataSource != null)
                    {
                        rowIdx = 0;
                        id_delete = (int)dataGridView1.SelectedRows[0].Cells[0].Value;
                    }
                    break;
                case 2:
                    query = "SELECT * FROM railway_trip_view;";
                    dgTabPageIdx = e.TabPageIndex;
                    if (dataGridView1.DataSource != null)
                    {
                        rowIdx = 0;
                        id_delete = (int)dataGridView1.SelectedRows[0].Cells[0].Value;
                    }
                    break;
                case 3:
                    query = "SELECT * FROM tariff_view;";
                    dgTabPageIdx = e.TabPageIndex;
                    if (dataGridView1.DataSource != null)
                    {
                        rowIdx = 0;
                        id_delete = (int)dataGridView1.SelectedRows[0].Cells[0].Value;
                    }
                    break;
                case 4:
                    query = "SELECT * FROM train_view;";
                    dgTabPageIdx = e.TabPageIndex;
                    if (dataGridView1.DataSource != null)
                    {
                        rowIdx = 0;
                        id_delete = (int)dataGridView1.SelectedRows[0].Cells[0].Value;
                    }
                    break;
                case 5:
                    query = "SELECT * FROM train_designation_view;";
                    dgTabPageIdx = e.TabPageIndex;
                    if (dataGridView1.DataSource != null)
                    {
                        rowIdx = 0;
                        id_delete = (int)dataGridView1.SelectedRows[0].Cells[0].Value;
                    }
                    break;
                case 6:
                    query = "SELECT * FROM tariff_description_view;";
                    dgTabPageIdx = e.TabPageIndex;
                    if (dataGridView1.DataSource != null)
                    {
                        rowIdx = 0;
                        id_delete = (int)dataGridView1.SelectedRows[0].Cells[0].Value;
                    }
                    break;
                case 7:
                    query = "SELECT * FROM service_class_view;";
                    dgTabPageIdx = e.TabPageIndex;
                    if (dataGridView1.DataSource != null)
                    {
                        rowIdx = 0;
                        id_delete = (int)dataGridView1.SelectedRows[0].Cells[0].Value;
                    }
                    break;
                case 8:
                    query = "SELECT * FROM discount_category_view;";
                    dgTabPageIdx = e.TabPageIndex;
                    if (dataGridView1.DataSource != null)
                    {
                        rowIdx = 0;
                        id_delete = (int)dataGridView1.SelectedRows[0].Cells[0].Value;
                    }
                    break;
            }
            dataGridView1.Parent = e.TabPage;

            dataGridView1.DataSource = _tool.displayQuery(query);
            if (dataGridView1.DataSource == null) return;
            if (dataGridView1.Columns[0].HeaderText == "id") dataGridView1.Columns[0].Visible = false;
        }
        private void FormMain_Load(object sender, EventArgs e)
        {
            query = "SELECT * FROM ticket_view_main;";
            dataGridView1.DataSource = _tool.displayQuery(query);
            if (dataGridView1.DataSource == null) return;
        }

        private void FormMain_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (_command != null)
            {
                _command.Dispose();
            }
            if (_connection != null)
            {
                _connection.Close();
            }
            Application.Exit();
        }

        private void buttonQueries_Click(object sender, EventArgs e)
        {
            if (privelege_lvl <= 2)
            {
                FormQueries fm = new FormQueries(_connection, _command, this);
                fm.ShowDialog();
            }
            else MessageBox.Show("У вас недостаточно прав для данной функции!", "Предупреждение",
                MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }

        private void dataGridView1_ParentChanged(object sender, EventArgs e)
        {
            string _query = query;
            dataGridView1.DataSource = _tool.displayQuery(_query);
            if (dataGridView1.DataSource == null) return;
        }

        private void buttonInsert_Click(object sender, EventArgs e)
        {
            if (privelege_lvl <= 2)
            {
                _event = "INSERT";
                switch (tabControl1.SelectedIndex)
                {
                    case 0:
                        table = "ticket";
                        f_InsUpd_10_ticket = new InsUpd_10cols_ticket(_connection, _command, table, _event);
                        f_InsUpd_10_ticket.setButtonText(_event);
                        f_InsUpd_10_ticket.ShowDialog();
                        buttonRefresh_Click(buttonRefresh, e);
                        break;
                    case 1:
                        table = "passenger";
                        f_InsUpd_10_pass = new InsUpd_10cols_pass(_connection, _command, table, _event);
                        f_InsUpd_10_pass.setButtonText(_event);
                        f_InsUpd_10_pass.ShowDialog();
                        buttonRefresh_Click(buttonRefresh, e);
                        break;
                    case 2:
                        table = "railway_trip";
                        f_InsUpd_2_Rt = new InsUpd_2cols_Rt(_connection, _command, table, _event);
                        f_InsUpd_2_Rt.setButtonText(_event);
                        f_InsUpd_2_Rt.ShowDialog();
                        buttonRefresh_Click(buttonRefresh, e);
                        break;
                    case 3:
                        table = "tariff";
                        f_InsUpd_5 = new InsUpd_5cols(_connection, _command, table, _event);
                        f_InsUpd_5.setButtonText(_event);
                        f_InsUpd_5.ShowDialog();
                        buttonRefresh_Click(buttonRefresh, e);
                        break;
                    case 4:
                        table = "train";
                        f_InsUpd_9 = new InsUpd_9cols(_connection, _command, table, _event);
                        f_InsUpd_9.setButtonText(_event);
                        f_InsUpd_9.ShowDialog();
                        buttonRefresh_Click(buttonRefresh, e);
                        break;
                    case 5:
                        if (privelege_lvl <= 1)
                        {
                            table = "train_designation";
                            f_InsUpd_2 = new InsUpd_2cols(_connection, _command, table, _event);
                            f_InsUpd_2.setLabelTitleText(tabControl1.TabPages[tabControl1.SelectedIndex].Text);
                            f_InsUpd_2.setLabelColumn1Text(dataGridView1.Columns[1].HeaderText);
                            f_InsUpd_2.setButtonText(_event);
                            f_InsUpd_2.ShowDialog();
                            buttonRefresh_Click(buttonRefresh, e);
                        }
                        else MessageBox.Show("У вас недостаточно прав для данной функции!", "Предупреждение",
                            MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        break;
                    case 6:
                        if (privelege_lvl <= 1)
                        {
                            table = "tariff_description";
                            f_InsUpd_2 = new InsUpd_2cols(_connection, _command, table, _event);
                            f_InsUpd_2.setLabelTitleText(tabControl1.TabPages[tabControl1.SelectedIndex].Text);
                            f_InsUpd_2.setLabelColumn1Text(dataGridView1.Columns[1].HeaderText);
                            f_InsUpd_2.setButtonText(_event);
                            f_InsUpd_2.ShowDialog();
                            buttonRefresh_Click(buttonRefresh, e);
                        }
                        else MessageBox.Show("У вас недостаточно прав для данной функции!", "Предупреждение",
                            MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        break;
                    case 7:
                        if (privelege_lvl <= 1)
                        {
                            table = "service_class";
                            f_InsUpd_2 = new InsUpd_2cols(_connection, _command, table, _event);
                            f_InsUpd_2.setLabelTitleText(tabControl1.TabPages[tabControl1.SelectedIndex].Text);
                            f_InsUpd_2.setLabelColumn1Text(dataGridView1.Columns[1].HeaderText);
                            f_InsUpd_2.setButtonText(_event);
                            f_InsUpd_2.ShowDialog();
                            buttonRefresh_Click(buttonRefresh, e);
                        }
                        else MessageBox.Show("У вас недостаточно прав для данной функции!", "Предупреждение",
                            MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        break;
                    case 8:
                        if (privelege_lvl <= 1)
                        {
                            table = "discount_category";
                            f_InsUpd_2 = new InsUpd_2cols(_connection, _command, table, _event);
                            f_InsUpd_2.setLabelTitleText(tabControl1.TabPages[tabControl1.SelectedIndex].Text);
                            f_InsUpd_2.setLabelColumn1Text(dataGridView1.Columns[1].HeaderText);
                            f_InsUpd_2.setButtonText(_event);
                            f_InsUpd_2.ShowDialog();
                            buttonRefresh_Click(buttonRefresh, e);
                        }
                        else MessageBox.Show("У вас недостаточно прав для данной функции!", "Предупреждение",
                            MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        break;
                }
            }
            else MessageBox.Show("У вас недостаточно прав для данной функции!", "Предупреждение",
                MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }

        private void buttonUpdate_Click(object sender, EventArgs e)
        {
            if (privelege_lvl <= 2)
            {
                _event = "UPDATE";
                switch (tabControl1.SelectedIndex)
                {
                    case 0:
                        table = "ticket";
                        f_InsUpd_10_ticket = new InsUpd_10cols_ticket(_connection, _command, table, _event);
                        f_InsUpd_10_ticket.setButtonText(_event);
                        f_InsUpd_10_ticket._id = int.Parse(dataGridView1.SelectedRows[0].Cells[0].Value.ToString());
                        f_InsUpd_10_ticket.setValues(
                            dataGridView1.SelectedRows[0].Cells["Фамилия"].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells["Имя"].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells["Отчество"].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells["Поезд"].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells["Кол-во вагонов"].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells["Кол-во пассажиров"].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells["Тариф"].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells["Класс"].Value.ToString(),
                            Convert.ToBoolean(dataGridView1.SelectedRows[0].Cells["Бельё"].Value.ToString()),
                            Convert.ToBoolean(dataGridView1.SelectedRows[0].Cells["Страховка"].Value.ToString()),
                            dataGridView1.SelectedRows[0].Cells["Категория льготы"].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells["А"].Value.ToString(),
                            DateTime.Parse(dataGridView1.SelectedRows[0].Cells["Отправление"].Value.ToString()),
                            dataGridView1.SelectedRows[0].Cells["В"].Value.ToString(),
                            DateTime.Parse(dataGridView1.SelectedRows[0].Cells["Прибытие"].Value.ToString()),
                            dataGridView1.SelectedRows[0].Cells["Вагон"].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells["Место"].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells["Цена"].Value.ToString()
                        );
                        f_InsUpd_10_ticket.ShowDialog();
                        buttonRefresh_Click(buttonRefresh, e);
                        break;
                    case 1:
                        table = "passenger";
                        f_InsUpd_10_pass = new InsUpd_10cols_pass(_connection, _command, table, _event);
                        f_InsUpd_10_pass.setButtonText(_event);
                        f_InsUpd_10_pass._id = int.Parse(dataGridView1.SelectedRows[0].Cells[0].Value.ToString());
                        f_InsUpd_10_pass.setValues(
                            dataGridView1.SelectedRows[0].Cells["Фамилия"].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells["Имя"].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells["Отчество"].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells["Пол"].Value.ToString(),
                            DateTime.Parse(dataGridView1.SelectedRows[0].Cells["Дата рождения"].Value.ToString()),
                            dataGridView1.SelectedRows[0].Cells["Паспорт"].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells["Код страны выдачи"].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells["Почта"].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells["Телефон"].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells["Свидетельство о рождении"].Value.ToString()
                            );
                        f_InsUpd_10_pass.ShowDialog();
                        buttonRefresh_Click(buttonRefresh, e);
                        break;
                    case 2:
                        table = "railway_trip";
                        f_InsUpd_2_Rt = new InsUpd_2cols_Rt(_connection, _command, table, _event);
                        f_InsUpd_2_Rt.setButtonText(_event);
                        f_InsUpd_2_Rt._id = int.Parse(dataGridView1.SelectedRows[0].Cells[0].Value.ToString());
                        f_InsUpd_2_Rt.setValues(dataGridView1.SelectedRows[0].Cells[1].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells[2].Value.ToString());
                        f_InsUpd_2_Rt.ShowDialog();
                        buttonRefresh_Click(buttonRefresh, e);
                        break;
                    case 3:
                        table = "tariff";
                        f_InsUpd_5 = new InsUpd_5cols(_connection, _command, table, _event);
                        f_InsUpd_5.setButtonText(_event);
                        f_InsUpd_5._id = int.Parse(dataGridView1.SelectedRows[0].Cells[0].Value.ToString());
                        f_InsUpd_5.setValues(
                            dataGridView1.SelectedRows[0].Cells[1].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells[2].Value.ToString(),
                            Convert.ToBoolean(dataGridView1.SelectedRows[0].Cells[3].Value.ToString()),
                            Convert.ToBoolean(dataGridView1.SelectedRows[0].Cells[4].Value.ToString()),
                            dataGridView1.SelectedRows[0].Cells[5].Value.ToString()
                            );
                        f_InsUpd_5.ShowDialog();
                        buttonRefresh_Click(buttonRefresh, e);
                        break;
                    case 4:
                        table = "train";
                        f_InsUpd_9 = new InsUpd_9cols(_connection, _command, table, _event);
                        f_InsUpd_9.setButtonText(_event);
                        f_InsUpd_9._id = int.Parse(dataGridView1.SelectedRows[0].Cells[0].Value.ToString());
                        f_InsUpd_9.setValues(
                            dataGridView1.SelectedRows[0].Cells[1].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells[2].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells[3].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells[4].Value.ToString(),
                            DateTime.Parse(dataGridView1.SelectedRows[0].Cells[5].Value.ToString()),
                            DateTime.Parse(dataGridView1.SelectedRows[0].Cells[6].Value.ToString()),
                            dataGridView1.SelectedRows[0].Cells[7].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells[8].Value.ToString(),
                            dataGridView1.SelectedRows[0].Cells[9].Value.ToString()
                            );
                        f_InsUpd_9.ShowDialog();
                        buttonRefresh_Click(buttonRefresh, e);
                        break;
                    case 5:
                        if (privelege_lvl <= 1)
                        {
                            table = "train_designation";
                            f_InsUpd_2 = new InsUpd_2cols(_connection, _command, table, _event);
                            f_InsUpd_2.setLabelTitleText(tabControl1.TabPages[tabControl1.SelectedIndex].Text);
                            f_InsUpd_2.setLabelColumn1Text(dataGridView1.Columns[1].HeaderText);
                            f_InsUpd_2.setButtonText(_event);
                            f_InsUpd_2._id = int.Parse(dataGridView1.SelectedRows[0].Cells[0].Value.ToString());
                            f_InsUpd_2.setTextBox1Text(dataGridView1.SelectedRows[0].Cells[1].Value.ToString());
                            f_InsUpd_2.ShowDialog();
                            buttonRefresh_Click(buttonRefresh, e);
                        }
                        else MessageBox.Show("У вас недостаточно прав для данной функции!", "Предупреждение",
                            MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        break;
                    case 6:
                        if (privelege_lvl <= 1)
                        {
                            table = "tariff_description";
                            f_InsUpd_2 = new InsUpd_2cols(_connection, _command, table, _event);
                            f_InsUpd_2.setLabelTitleText(tabControl1.TabPages[tabControl1.SelectedIndex].Text);
                            f_InsUpd_2.setLabelColumn1Text(dataGridView1.Columns[1].HeaderText);
                            f_InsUpd_2.setButtonText(_event);
                            f_InsUpd_2._id = int.Parse(dataGridView1.SelectedRows[0].Cells[0].Value.ToString());
                            f_InsUpd_2.setTextBox1Text(dataGridView1.SelectedRows[0].Cells[1].Value.ToString());
                            f_InsUpd_2.ShowDialog();
                            buttonRefresh_Click(buttonRefresh, e);
                        }
                        else MessageBox.Show("У вас недостаточно прав для данной функции!", "Предупреждение",
                            MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        break;
                    case 7:
                        if (privelege_lvl <= 1)
                        {
                            table = "service_class";
                            f_InsUpd_2 = new InsUpd_2cols(_connection, _command, table, _event);
                            f_InsUpd_2.setLabelTitleText(tabControl1.TabPages[tabControl1.SelectedIndex].Text);
                            f_InsUpd_2.setLabelColumn1Text(dataGridView1.Columns[1].HeaderText);
                            f_InsUpd_2.setButtonText(_event);
                            f_InsUpd_2._id = int.Parse(dataGridView1.SelectedRows[0].Cells[0].Value.ToString());
                            f_InsUpd_2.setTextBox1Text(dataGridView1.SelectedRows[0].Cells[1].Value.ToString());
                            f_InsUpd_2.ShowDialog();
                            buttonRefresh_Click(buttonRefresh, e);
                        }
                        else MessageBox.Show("У вас недостаточно прав для данной функции!", "Предупреждение",
                            MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        break;
                    case 8:
                        if (privelege_lvl <= 1)
                        {
                            table = "discount_category";
                            f_InsUpd_2 = new InsUpd_2cols(_connection, _command, table, _event);
                            f_InsUpd_2.setLabelTitleText(tabControl1.TabPages[tabControl1.SelectedIndex].Text);
                            f_InsUpd_2.setLabelColumn1Text(dataGridView1.Columns[1].HeaderText);
                            f_InsUpd_2.setButtonText(_event);
                            f_InsUpd_2._id = int.Parse(dataGridView1.SelectedRows[0].Cells[0].Value.ToString());
                            f_InsUpd_2.setTextBox1Text(dataGridView1.SelectedRows[0].Cells[1].Value.ToString());
                            f_InsUpd_2.ShowDialog();
                            buttonRefresh_Click(buttonRefresh, e);
                        }
                        else MessageBox.Show("У вас недостаточно прав для данной функции!", "Предупреждение",
                            MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        break;
                }
            }
            else MessageBox.Show("У вас недостаточно прав для данной функции!", "Предупреждение",
            MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }

        private void buttonDelete_Click(object sender, EventArgs e)
        {
            if (dataGridView1.DataSource == null) return;
            if (privelege_lvl <= 2)
            {
                string _query = string.Empty;
                if (rowIdx < 0)
                {
                    MessageBox.Show("Выберите строки для удаления!", "Предупреждение!",
                        MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
                else
                {
                    switch (dgTabPageIdx)
                    {
                        case 0:
                            _query = string.Format("SELECT delete_ticket({0});", id_delete);
                            break;
                        case 1:
                            _query = string.Format("SELECT delete_passenger({0});", id_delete);
                            break;
                        case 2:
                            _query = string.Format("SELECT delete_railway_trip({0});", id_delete);
                            break;
                        case 3:
                            _query = string.Format("SELECT delete_tariff({0});", id_delete);
                            break;
                        case 4:
                            _query = string.Format("SELECT delete_train({0});", id_delete);
                            break;
                        case 5:
                            _query = string.Format("SELECT delete_train_designation({0});", id_delete);
                            break;
                        case 6:
                            _query = string.Format("SELECT delete_tariff_description({0});", id_delete);
                            break;
                        case 7:
                            _query = string.Format("SELECT delete_service_class({0});", id_delete);
                            break;
                        case 8:
                            _query = string.Format("SELECT delete_discount_category({0});", id_delete);
                            break;
                    }
                    if (privelege_lvl <= 2)
                    {
                        _tool.displayQuery(_query);
                        dataGridView1.DataSource = _tool.displayQuery(query);
                    }
                    else MessageBox.Show("У вас недостаточно прав для данной функции!", "Предупреждение",
                        MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    if (dataGridView1.DataSource == null) return;
                    id_delete = (int)dataGridView1.SelectedRows[0].Cells[0].Value;
                }
            }
            else MessageBox.Show("У вас недостаточно прав для данной функции!", "Предупреждение",
                MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }

        private void dataGridView1_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            rowIdx = e.RowIndex;
            id_delete = (int)dataGridView1.SelectedRows[0].Cells[0].Value;
        }

        private void buttonRefresh_Click(object sender, EventArgs e) => dataGridView1.DataSource = _tool.displayQuery(query);

        private void buttonLogout_Click(object sender, EventArgs e)
        {
            _connection.Close();
            _command.Dispose();
            FormLogin fl = new FormLogin();
            this.Hide();
            fl.ShowDialog();
        }
    }
}