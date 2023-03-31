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
using System.Windows.Forms.VisualStyles;

namespace Client
{
    public partial class InsUpd_10cols_tcketview : Form
    {
        private NpgsqlConnection _connection;
        private NpgsqlCommand _command;
        private Tools _tool;
        private string _table;
        public int _id;

        public InsUpd_10cols_tcketview()
        {
            InitializeComponent();
        }
        public InsUpd_10cols_tcketview(NpgsqlConnection conn, NpgsqlCommand comm, string table)
        {
            InitializeComponent();
            _tool = new Tools(conn);
            _connection = conn;
            _command = comm;
            _table = table;
        }
        public void setValues(string value1, string value2, string value3, string value4,
            string value5, DateTime value6, string value7, DateTime value8, string value9,
            string value10, string value11, bool value12, bool value13)
        {
            textBoxLname.Text = value1;
            textBoxName.Text = value2;
            textBoxPatronymic.Text = value3;
            textBoxTrainnum.Text = value4;
            textBoxDeppoint.Text = value5;
            dateTimePickerDep.Value = value6;
            textBoxArrpoint.Text = value7;
            dateTimePickerArr.Value = value8;
            textBoxCarriage.Text = value9;
            textBoxSeat.Text = value10;
            textBoxPrice.Text = value11;
            checkBoxBl.Checked = value12;
            checkBoxIns.Checked = value13;
        }
        private void buttonApply_Click(object sender, EventArgs e)
        {
            if (textBoxLname.Text == "" || textBoxName.Text == "" || textBoxTrainnum.Text == "" || textBoxDeppoint.Text == "" ||
                textBoxArrpoint.Text == "" || textBoxCarriage.Text == "" || textBoxSeat.Text == "" || textBoxPrice.Text == "")
            {
                MessageBox.Show("Необходимо заполнить все поля!", "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            if (_tool.makeQuery(string.Format("UPDATE {0} " +
                "SET \"Фамилия\" = \'{1}\', \"Имя\" = \'{2}\', \"Отчество\" = \'{3}\', \"Поезд\" = \'{4}\', " +
                "\"А\" = \'{5}\', \"Отправление\" = \'{6}\', \"В\" = \'{7}\', \"Прибытие\" = \'{8}\', \"Вагон\" = \'{9}\'" +
                ", \"Место\" = \'{10}\', \"Цена\" = \'{11}\', \"Бельё\" = \'{12}\', \"Страховка\" = \'{13}\'" +
                "WHERE \"Номер билета\" = {14};",
                _table, textBoxLname.Text.Trim(), textBoxName.Text.Trim(), textBoxPatronymic.Text.Trim(), textBoxTrainnum.Text.Trim(), textBoxDeppoint.Text,
                dateTimePickerDep.Value, textBoxArrpoint.Text, dateTimePickerArr.Value, textBoxCarriage.Text.Trim(), textBoxSeat.Text.Trim(),
                textBoxPrice.Text.Trim(), checkBoxBl.Checked, checkBoxIns.Checked, _id)))
            {
                MessageBox.Show("Строка изменена!", "Успешно!", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
        }
    }
}