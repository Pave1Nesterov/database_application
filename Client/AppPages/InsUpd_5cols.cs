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
using static System.Windows.Forms.VisualStyles.VisualStyleElement.Button;

namespace Client
{
    public partial class InsUpd_5cols : Form
    {
        private NpgsqlConnection _connection;
        private NpgsqlCommand _command;
        private Tools _tool;
        private string _table;
        private string _cur_event;
        public int _id;
        public InsUpd_5cols()
        {
            InitializeComponent();
        }
        public InsUpd_5cols(NpgsqlConnection conn, NpgsqlCommand comm, string table, string event_)
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

        public void setValues(string value1, string value2, bool value3, bool value4, string value5)
        {
            comboBoxDescription.Text = value1;
            comboBoxClass.Text = value2;
            checkBoxBl.Checked = value3;
            checkBoxIns.Checked = value4;
            comboBoxDisccat.Text = value5;
        }
        private void buttonApply_Click(object sender, EventArgs e)
        {
            if (comboBoxDescription.Text == "" || comboBoxClass.Text == "" || comboBoxDisccat.Text == "")
            {
                MessageBox.Show("Необходимо заполнить все поля!", "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            int fk_1 = Convert.ToInt32(_tool.displayQuery(string.Format("SELECT id FROM tariff_description WHERE description = \'{0}\';",
                comboBoxDescription.Text)).Rows[0][0]);
            int fk_2 = Convert.ToInt32(_tool.displayQuery(string.Format("SELECT id FROM service_class WHERE class = \'{0}\';",
                comboBoxClass.Text)).Rows[0][0]);
            int fk_3 = Convert.ToInt32(_tool.displayQuery(string.Format("SELECT id FROM discount_category WHERE category = \'{0}\';",
                comboBoxDisccat.Text)).Rows[0][0]);
            if (_cur_event == "INSERT")
            {
                if (_tool.makeQuery(string.Format("SELECT insert_{0} (\'{1}\', \'{2}\', \'{3}\', \'{4}\', \'{5}\');",
                    _table, fk_1, fk_2, checkBoxBl.Checked, checkBoxIns.Checked, fk_3)))
                {
                    MessageBox.Show("Строка добавлена!", "Успешно!", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    comboBoxDescription.SelectedIndex = -1;
                    comboBoxClass.SelectedIndex = -1;
                    comboBoxDisccat.SelectedIndex = -1;
                }
            }
            else
            {
                if (_tool.makeQuery(string.Format("SELECT update_{0} (\'{1}\', \'{2}\', \'{3}\', \'{4}\', \'{5}\', \'{6}\');",
                    _table, _id, fk_1, fk_2, checkBoxBl.Checked, checkBoxIns.Checked, fk_3)))
                {
                    MessageBox.Show("Строка изменена!", "Успешно!", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            }
        }

        private void InsUpd_5cols_Load(object sender, EventArgs e)
        {
            foreach (DataRow row in _tool.displayQuery("SELECT * FROM tariff_description;").Rows)
            {
                comboBoxDescription.Items.Add(row[1]);
            }
            foreach (DataRow row in _tool.displayQuery("SELECT * FROM service_class;").Rows)
            {
                comboBoxClass.Items.Add(row[1]);
            }
            foreach (DataRow row in _tool.displayQuery("SELECT * FROM discount_category;").Rows)
            {
                comboBoxDisccat.Items.Add(row[1]);
            }
        }
    }
}