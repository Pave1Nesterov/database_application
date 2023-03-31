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
    public partial class InsUpd_9cols : Form
    {
        private NpgsqlConnection _connection;
        private NpgsqlCommand _command;
        private Tools _tool;
        private string _table;
        private string _cur_event;
        public int _id;
        public InsUpd_9cols()
        {
            InitializeComponent();
        }
        public InsUpd_9cols(NpgsqlConnection conn, NpgsqlCommand comm, string table, string event_)
        {
            InitializeComponent();
            _tool = new Tools(conn);
            _connection = conn;
            _command = comm;
            _table = table;
            _cur_event = event_;
        }
        private void timeSet_Auto()
        {
            DateTime dt1 = dateTimePickerDep.Value;
            DateTime dt2 = dateTimePickerArr.Value;

            if (dt2 < dt1) dt2 = dt2.AddDays(1);
            var z = (dt1 - dt2).Duration();
            int h = z.Hours;
            int m = z.Minutes;

            textBoxHour.Text = h.ToString();
            textBoxMinute.Text = m.ToString();
        }
        public void setValues(string value1, string value2, string value3, string value4,
            DateTime value5, DateTime value6, string value7, string value8, string value9)
        {
            textBoxNumber.Text = value1;
            comboBoxDesignation.Text = value2;
            textBoxDeppoint.Text = value3;
            textBoxArrpoint.Text = value4;
            dateTimePickerDep.Value = value5;
            dateTimePickerArr.Value = value6;
            textBoxDay.Text = value7;
            textBoxHour.Text = value8;
            textBoxMinute.Text = value9;
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
        private void buttonApply_Click(object sender, EventArgs e)
        {
            int fk_1;
            if (textBoxNumber.Text == "" || comboBoxDesignation.Text == "" ||
                textBoxDeppoint.Text == "" || textBoxArrpoint.Text == "" ||
                dateTimePickerDep.Text == "" || dateTimePickerArr.Text == "" ||
                textBoxDay.Text == "" || textBoxHour.Text == "" || textBoxMinute.Text == "")
            {
                MessageBox.Show("Необходимо заполнить все поля!", "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            fk_1 = Convert.ToInt32(_tool.displayQuery(string.Format("SELECT id FROM train_designation WHERE designation = \'{0}\';",
                comboBoxDesignation.Text)).Rows[0][0]);
            if (_cur_event == "INSERT")
            {
                if (_tool.makeQuery(string.Format("SELECT insert_{0} (\'{1}\', \'{2}\', \'{3}\', \'{4}\', \'{5}\', " +
                    "\'{6}\', \'{7}\', \'{8}\', \'{9}\');", _table, textBoxNumber.Text, fk_1, textBoxDeppoint.Text, textBoxArrpoint.Text,
                    dateTimePickerDep.Text, dateTimePickerArr.Text, textBoxDay.Text.Trim(), textBoxHour.Text.Trim(), textBoxMinute.Text.Trim())))
                {
                    MessageBox.Show("Строка добавлена!", "Успешно!", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    textBoxNumber.Clear();
                    comboBoxDesignation.SelectedIndex = -1;
                    textBoxDeppoint.Clear();
                    textBoxArrpoint.Clear();
                    textBoxDay.Clear();
                    textBoxHour.Clear();
                    textBoxMinute.Clear();
                }
            }
            else
            {
                if (_tool.makeQuery(string.Format("SELECT update_{0} (\'{1}\', \'{2}\', \'{3}\', \'{4}\', \'{5}\', " +
                    "\'{6}\', \'{7}\', \'{8}\', \'{9}\', \'{10}\');", _table, _id, textBoxNumber.Text, fk_1, textBoxDeppoint.Text,
                    textBoxArrpoint.Text, dateTimePickerDep.Text, dateTimePickerArr.Text, textBoxDay.Text.Trim(), textBoxHour.Text.Trim(), textBoxMinute.Text.Trim())))
                {
                    MessageBox.Show("Строка изменена!", "Успешно!", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            }
        }

        private void buttonAuto_Click(object sender, EventArgs e) => checkBoxAuto.Checked = !checkBoxAuto.Checked;
        private void checkBoxAuto_CheckedChanged(object sender, EventArgs e)
        {
            if (checkBoxAuto.Checked) timeSet_Auto();
            else
            {
                textBoxHour.Clear();
                textBoxMinute.Clear();
            }
        }
        private void dateTimePickerArr_ValueChanged(object sender, EventArgs e)
        {
            if (checkBoxAuto.Checked) timeSet_Auto();
        }
        private void dateTimePickerDep_ValueChanged(object sender, EventArgs e)
        {
            if (checkBoxAuto.Checked) timeSet_Auto();
        }
        private void InsUpd_9cols_Load(object sender, EventArgs e)
        {
            timeSet_Auto();
            foreach (DataRow row in _tool.displayQuery("SELECT * FROM train_designation;").Rows)
            {
                comboBoxDesignation.Items.Add(row[1]);
            }
        }
    }
}