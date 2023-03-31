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
    public partial class InsUpd_2cols_Rt : Form
    {
        private NpgsqlConnection _connection;
        private NpgsqlCommand _command;
        private Tools _tool;
        private string _table;
        private string _cur_event;
        public int _id;
        public InsUpd_2cols_Rt()
        {
            InitializeComponent();
        }
        public InsUpd_2cols_Rt(NpgsqlConnection conn, NpgsqlCommand comm, string table, string event_)
        {
            InitializeComponent();
            _tool = new Tools(conn);
            _connection = conn;
            _command = comm;
            _table = table;
            _cur_event = event_;
        }
        public void setButtonText(string _text)
        {
            if (_cur_event == "INSERT")
            {
                buttonApply.Text = "Добавить строку";
            }
            else if (_cur_event == "UPDATE")
            {
                buttonApply.Text = "Изменить строку";
            }
        }
        public void setValues(string value1, string value2)
        {
            comboBoxTrainnum.Text = value1;
            textBoxCarrCount.Text = value2;
        }

        private void InsUpd_2cols_Rt_Load(object sender, EventArgs e)
        {
            foreach (DataRow row in _tool.displayQuery("SELECT * FROM train;").Rows)
            {
                comboBoxTrainnum.Items.Add(row[1]);
            }
        }

        private void buttonApply_Click(object sender, EventArgs e)
        {
            if (comboBoxTrainnum.Text == "" || textBoxCarrCount.Text == "")
            {
                MessageBox.Show("Необходимо заполнить все поля!", "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            int fk_1 = Convert.ToInt32(_tool.displayQuery(string.Format("SELECT id FROM train WHERE number = \'{0}\';",
                comboBoxTrainnum.Text.Trim())).Rows[0][0]);
            if (_cur_event == "INSERT")
            {
                if (_tool.makeQuery(string.Format("SELECT insert_{0} (\'{1}\', \'{2}\');",
                    _table, fk_1, textBoxCarrCount.Text.Trim())))
                {
                    MessageBox.Show("Строка добавлена!", "Успешно!", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    comboBoxTrainnum.SelectedIndex = -1;
                    textBoxCarrCount.Clear();
                }
            }
            else
            {
                if (_tool.makeQuery(string.Format("SELECT update_{0} (\'{1}\', \'{2}\', \'{3}\');",
                    _table, _id, fk_1, textBoxCarrCount.Text.Trim())))
                {
                    MessageBox.Show("Строка изменена!", "Успешно!", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            }
        }
    }
}